# Hermes 配置同步

两台电脑通过 Git + 软链接同步 Hermes 全部用户配置。

## 同步内容

| 文件 | 内容 | 大小 |
|------|------|------|
| `SOUL.md` | System prompt 行为规则 | ~2 KB |
| `config.yaml` | 模型/工具集/MCP 配置 | ~300 B |
| `skills/` | 全部 26 个 skills | ~12 MB |
| `state.db` | 跨会话记忆 + 会话记录 | ~76 MB |

## 另一台电脑搭建

```bash
# 1. 安装 Hermes + 克隆
curl -fsSL https://raw.githubusercontent.com/NousResearch/hermes-agent/main/scripts/install.sh | bash
git clone git@github.com:wm724796434/financial-data-reporting.git
cd financial-data-reporting

# 2. 创建软链接（Hermes 关闭时执行）
bash hermes-config/setup-links.sh

# 3. 配置 API 密钥
nano ~/.hermes/.env   # 填入 DEEPSEEK_API_KEY=sk-xxx
```

## 日常使用

| 场景 | 操作 |
|------|------|
| 修改配置/skills 后 | 自动反映在仓库中，`git commit && git push` |
| 换电脑 | `git pull` → 自动生效（软链接） |
| memory 变化 | state.db 已被 Hermes 更新，`git commit && git push` 同步 |

## 注意事项

- `.env`（API 密钥）不在 Git 中，每台电脑单独配置
- `state.db` 约 76 MB，push/pull 较慢，建议在网络好时操作
- 脚本 `setup-links.sh` 需在 Hermes 关闭时运行
