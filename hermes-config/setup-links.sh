#!/bin/bash
# Hermes 配置同步 — 软链接切换脚本
# 在 Hermes 未运行时执行
# 用法: bash hermes-config/setup-links.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

echo "项目路径: $PROJECT_DIR"
echo ""

# --- SOUL.md ---
if [ -L ~/.hermes/SOUL.md ]; then
    echo "✓ SOUL.md 已是软链接"
else
    [ -f ~/.hermes/SOUL.md ] && mv ~/.hermes/SOUL.md ~/.hermes/SOUL.md.bak
    ln -s "$PROJECT_DIR/hermes-config/SOUL.md" ~/.hermes/SOUL.md
    echo "✓ SOUL.md 已链接"
fi

# --- config.yaml ---
if [ -L ~/.hermes/config.yaml ]; then
    echo "✓ config.yaml 已是软链接"
else
    [ -f ~/.hermes/config.yaml ] && mv ~/.hermes/config.yaml ~/.hermes/config.yaml.bak
    ln -s "$PROJECT_DIR/hermes-config/config.yaml" ~/.hermes/config.yaml
    echo "✓ config.yaml 已链接"
fi

# --- skills ---
if [ -L ~/.hermes/skills ]; then
    echo "✓ skills 已是软链接"
else
    [ -d ~/.hermes/skills ] && mv ~/.hermes/skills ~/.hermes/skills.bak
    ln -s "$PROJECT_DIR/hermes-config/skills" ~/.hermes/skills
    echo "✓ skills 已链接"
fi

echo ""
echo "全部完成。state.db（memory）不同步，各电脑独立。"
