# 多机 Hermes 配置同步（软链接 + Git）

两台电脑之间同步 `~/.hermes/SOUL.md` 和 `~/.hermes/config.yaml`，使用软链接将用户级配置纳入 Git 管理。

## 适用场景

- 工作电脑 + 家用电脑，需要在两台机器间保持 Hermes 配置一致
- 修改 SOUL.md（system prompt 规则）或 config.yaml（MCP 服务器等）后自动同步

## 架构原理

```
~/.hermes/SOUL.md    ──软链接──▶  项目/hermes-config/SOUL.md
~/.hermes/config.yaml ──软链接──▶  项目/hermes-config/config.yaml
                                     │
                              git push / pull
                                     │
                              GitHub 远程仓库
```

Hermes 读取 `~/.hermes/SOUL.md` 和 `~/.hermes/config.yaml` 时，实际读的是 Git 仓库中的文件。修改仓库中的文件即修改 Hermes 配置。

## 关键分层

| 层 | 位置 | Git 管理？ | 同步方式 |
|----|------|:---:|------|
| **项目级** | `项目/.hermes/skills/`、`AGENTS.md` | ✅ | git clone 自动获取 |
| **用户级配置** | `~/.hermes/SOUL.md`、`~/.hermes/config.yaml` | ✅（通过软链接） | 本方案 |
| **密钥** | `~/.hermes/.env` | ❌ | 每台电脑手动配置 |
| **用户级 skills** | `~/.hermes/skills/` | ❌ | 需要时手动复制 |

## 搭建步骤

### 第一台电脑（已有配置的）

```bash
# 在项目根目录
mkdir -p hermes-config
cp ~/.hermes/SOUL.md hermes-config/
cp ~/.hermes/config.yaml hermes-config/

# 创建软链接（备份原文件）
mv ~/.hermes/SOUL.md ~/.hermes/SOUL.md.bak
mv ~/.hermes/config.yaml ~/.hermes/config.yaml.bak
ln -s "$(pwd)/hermes-config/SOUL.md" ~/.hermes/SOUL.md
ln -s "$(pwd)/hermes-config/config.yaml" ~/.hermes/config.yaml

# 提交到 Git
git add hermes-config/
git commit -m "feat: Hermes配置同步"
git push
```

### 后续电脑

```bash
git clone <repo-url>
cd <project>

# 备份 + 创建软链接
mv ~/.hermes/SOUL.md ~/.hermes/SOUL.md.bak 2>/dev/null
mv ~/.hermes/config.yaml ~/.hermes/config.yaml.bak 2>/dev/null
ln -s "$(pwd)/hermes-config/SOUL.md" ~/.hermes/SOUL.md
ln -s "$(pwd)/hermes-config/config.yaml" ~/.hermes/config.yaml

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

### 路径适配

config.yaml 中的绝对路径（如 MCP 服务器的 Python 路径、脚本路径）需要在每台电脑上调整。建议：
- 使用 `~/.hermes/hermes-agent/.venv/bin/python3`（Hermes 自带 Python）
- 使用 `./scripts/xxx.py`（相对于项目根目录）
- 在 config.yaml 中用注释标记需要调整的路径

### .env 安全

`.env` 文件包含 API 密钥，**绝不能**纳入 Git。确保 `.gitignore` 包含 `.env`。每台电脑单独配置 `.env`。

### 用户级 Skills

`~/.hermes/skills/` 下的用户级 skills 不在此方案管理范围内。如需同步：
- 使用 `hermes skills install <id>` 在每台电脑上分别安装（通过 skills hub）
- 或手动复制 skills 目录

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
