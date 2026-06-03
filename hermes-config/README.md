# Hermes 配置同步说明

两台电脑通过 Git 同步 `~/.hermes/SOUL.md` 和 `~/.hermes/config.yaml`。

## 工作原理

```
~/.hermes/SOUL.md    ──软链接──▶  项目/hermes-config/SOUL.md
~/.hermes/config.yaml ──软链接──▶  项目/hermes-config/config.yaml
```

修改项目中的文件 → git push → 另一台 git pull → 自动生效。

## 另一台电脑搭建步骤

### 1. 安装 Hermes + 克隆项目
```bash
curl -fsSL https://raw.githubusercontent.com/NousResearch/hermes-agent/main/scripts/install.sh | bash
git clone git@github.com:wm724796434/financial-data-reporting.git
cd financial-data-reporting
```

### 2. 创建软链接
```bash
# 备份原文件（如果存在）
mv ~/.hermes/SOUL.md ~/.hermes/SOUL.md.bak 2>/dev/null
mv ~/.hermes/config.yaml ~/.hermes/config.yaml.bak 2>/dev/null

# 创建软链接（用实际的项目路径替换 <PROJECT_PATH>）
ln -s <PROJECT_PATH>/hermes-config/SOUL.md ~/.hermes/SOUL.md
ln -s <PROJECT_PATH>/hermes-config/config.yaml ~/.hermes/config.yaml
```

### 3. 配置 API 密钥
```bash
nano ~/.hermes/.env
# 填入：
# DEEPSEEK_API_KEY=sk-xxx
```

### 4. 验证
```bash
hermes doctor
```

## 日常使用

| 场景 | 操作 |
|------|------|
| 修改 SOUL.md 或 config.yaml 后 | `git add hermes-config/ && git commit && git push` |
| 上班 / 回家后 | `git pull origin main` |
| 安装新 skill（项目级） | `hermes skills install xxx`，skill 自动在 `.hermes/skills/` 下，已在 Git 中 |
| 安装新 skill（用户级） | 需要在一台电脑安装后手动复制到另一台 |

## 注意事项

- `.env`（API 密钥）不在 Git 中，每台电脑需单独配置
- MCP 服务器路径（config.yaml 中）可能需要根据实际路径调整
- 用户级 skills（`~/.hermes/skills/`）暂未纳入同步，需要时手动复制
