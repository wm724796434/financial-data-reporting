# Hermes 配置同步

两台电脑通过 Git + 软链接同步 Hermes 用户配置。

## 同步内容

| 文件 | 内容 | 大小 |
|------|------|------|
| `SOUL.md` | System prompt 行为规则 | ~2 KB |
| `config.yaml` | 模型/工具集/MCP 配置 | ~300 B |
| `skills/` | 全部 26 个 skills | ~12 MB |

> state.db（跨会话记忆，~76 MB）不同步——太大，GitHub 不友好。两台电脑各自积累 memory。

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
| 修改 SOUL.md / config.yaml | `git add hermes-config/ && git commit && git push` |
| 安装/更新 skill | skill 自动反映在仓库中，`git commit && git push` |
| 换电脑 | `git pull` → 自动生效（软链接） |

## 注意事项

- `.env`（API 密钥）和 `state.db`（memory）不在 Git 中，每台电脑单独配置
- 只在 Hermes 关闭时运行 `setup-links.sh`
- MCP 服务器路径（config.yaml）可能需要根据实际路径调整
