# 多机 Hermes 配置同步（软链接 + Git）

两台电脑之间同步 `~/.hermes/` 下的全部配置——SOUL.md、config.yaml、skills、state.db（memory）。使用软链接将用户级配置纳入 Git 管理，通过 `git pull/push` 实现双向同步。

## 适用场景

- 工作电脑 + 家用电脑，需要在两台机器间保持 Hermes 配置完全一致
- 修改 SOUL.md（system prompt 规则）、config.yaml（MCP 服务器等）、安装新 skill、memory 积累后自动同步
- 适合每日手动 pull/push 的场景（非实时同步）

## 架构原理

```
~/.hermes/SOUL.md    ──🔗──▶  hermes-config/SOUL.md
~/.hermes/config.yaml ──🔗──▶  hermes-config/config.yaml
~/.hermes/skills/    ──🔗──▶  hermes-config/skills/
~/.hermes/state.db   ──🔗──▶  hermes-config/state.db
                                     │
                              git push / pull
                                     │
                              GitHub 远程仓库
```

Hermes 读取 `~/.hermes/` 下的文件时，实际读的是 Git 仓库中的文件。修改仓库中的文件即修改 Hermes 配置。另一端 `git pull` 后自动生效。

## 关键分层

| 层 | 位置 | Git 管理？ | 同步方式 |
|----|------|:---:|------|
| **项目级** | `项目/.hermes/skills/`、`AGENTS.md` | ✅ | git clone 自动获取 |
| **用户级全部** | `~/.hermes/SOUL.md`、`config.yaml`、`skills/`、`state.db` | ✅（通过软链接） | 本方案 |
| **密钥** | `~/.hermes/.env` | ❌ | 每台电脑手动配置 |

## 搭建步骤

### 第一台电脑（已有配置的）

```bash
# 在项目根目录
mkdir -p hermes-config

# 复制全部用户级配置到仓库
cp ~/.hermes/SOUL.md hermes-config/
cp ~/.hermes/config.yaml hermes-config/
cp -r ~/.hermes/skills hermes-config/
cp ~/.hermes/state.db hermes-config/

# 创建 .gitattributes 避免二进制 diff
echo "hermes-config/state.db binary" >> .gitattributes

# 创建自动化软链接脚本（见下方 setup-links.sh）

# 提交到 Git
git add hermes-config/ .gitattributes
git commit -m "feat: Hermes配置同步（含skills和memory）"
git push
```

### 创建 setup-links.sh（一次性，随后提交到仓库）

```bash
#!/bin/bash
# 在 projects/hermes-config/setup-links.sh
set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

for item in SOUL.md config.yaml state.db; do
  if [ ! -L ~/.hermes/"$item" ]; then
    [ -f ~/.hermes/"$item" ] && mv ~/.hermes/"$item" ~/.hermes/"$item".bak
    ln -s "$PROJECT_DIR/hermes-config/$item" ~/.hermes/"$item"
    echo "✓ $item 已链接"
  else
    echo "✓ $item 已是软链接"
  fi
done

if [ ! -L ~/.hermes/skills ]; then
  [ -d ~/.hermes/skills ] && mv ~/.hermes/skills ~/.hermes/skills.bak
  ln -s "$PROJECT_DIR/hermes-config/skills" ~/.hermes/skills
  echo "✓ skills 已链接"
else
  echo "✓ skills 已是软链接"
fi
```

### 后续电脑

```bash
git clone <repo-url>
cd <project>

# 关闭 Hermes 后执行
bash hermes-config/setup-links.sh

# 配置 API 密钥（不同步）
nano ~/.hermes/.env
```

## 日常操作

| 场景 | 操作 |
|------|------|
| 修改 SOUL.md 或 config.yaml | 直接编辑 `hermes-config/` 下的文件，`git commit -m "..." && git push` |
| 换电脑后获取最新配置 | `git pull` — 因为是软链接，Hermes 自动读到最新内容 |
| 两台电脑都改了配置 | 先 `git pull` 合并，处理冲突后再 `git push` |

## 注意事项

### state.db 的体积与 Git

`state.db` 是 SQLite 数据库（通常 70-100 MB），存储跨会话 memory 和会话记录。纳入 Git 时需注意：

- **体积**：每次 commit 都存储完整副本，仓库会膨胀。约 76 MB/次，100 次 commit 约 7.6 GB
- **缓解措施**：加 `.gitattributes` 标记 `binary` 避免 diff；定期 `git gc`；接受仓库偏大
- **替代方案**：如果体积不可接受，可以不同步 state.db，接受两台电脑独立 memory；或使用 Hermes 的 profile export 偶尔手动同步
- **推送速度**：国内网络下推送 76 MB 约需几十秒到几分钟，建议在良好网络时推送

### 软链接执行时机

`setup-links.sh` 需要 Hermes **关闭时**执行。原因：
- `state.db` 被 Hermes 进程持有文件描述符，mv+ln 不会影响当前会话
- `skills/` 目录在 Hermes 启动时加载，运行中替换可能不会生效
- 最安全的做法：退出 Hermes → 执行脚本 → 重新启动

### 自动推送 Hook

可选：配置 post-commit hook 实现 git commit 后自动 push，省去手动 `git push`：

```bash
# .git/hooks/post-commit
#!/bin/bash
git push origin main &
chmod +x .git/hooks/post-commit
```

注意：`&` 让推送在后台运行，不阻塞终端。只在 commit 频率不高的场景使用——每次 commit 都推 76 MB 会很慢。

### 路径适配

config.yaml 中的绝对路径（如 MCP 服务器的 Python 路径、脚本路径）需要在每台电脑上调整。建议：
- 使用 `~/.hermes/hermes-agent/.venv/bin/python3`（Hermes 自带 Python）
- 使用 `./scripts/xxx.py`（相对于项目根目录）
- 在 config.yaml 中用注释标记需要调整的路径

### .env 安全

`.env` 文件包含 API 密钥，**绝不能**纳入 Git。确保 `.gitignore` 包含 `.env`。每台电脑单独配置 `.env`。

### Git 冲突处理

如果两台电脑几乎同时修改了同一个配置文件：
1. `git pull` 会提示冲突
2. 手动编辑冲突标记，保留需要的版本
3. `git add && git commit && git push`

## 与 Profile Export/Import 的比较

| 方案 | 优点 | 缺点 |
|------|------|------|
| 软链接 + Git | 实时同步，修改即生效；不用导出导入 | 初次搭建需手动创建软链接；路径可能需适配 |
| `hermes profile export/import` | 一键打包；包含 skills | 修改后需要重新导出导入；工作流不自然 |

日常高频修改（SOUL.md、config.yaml）推荐软链接方案；低频大规模迁移（全新电脑）可用 profile export 补充。
