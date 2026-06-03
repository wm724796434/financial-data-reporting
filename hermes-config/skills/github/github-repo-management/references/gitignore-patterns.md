# .gitignore Patterns by Project Type

Quick reference for common project types. Pick the closest match, then tailor.

## SQL / Database / DDL Projects

```gitignore
# System
Thumbs.db
.DS_Store
Desktop.ini

# IDE
.vscode/
.idea/
*.swp
*.swo

# Temp / build artifacts
*.tmp
*.log
*.bak
__pycache__/
*.py[cod]

# Data exports (never commit actual data)
*.csv
*.xlsx
*.dmp
*.dump
*.sql.gz

# Large binary backups
备份/
backup/
```

## Python Projects

```gitignore
# OS
Thumbs.db
.DS_Store

# IDE
.vscode/
.idea/

# Python
__pycache__/
*.py[cod]
*.egg-info/
dist/
build/
*.egg
.venv/
venv/
env/

# Notebook output
.ipynb_checkpoints/
*.ipynb - Checkpoints/

# Testing
.pytest_cache/
.coverage
htmlcov/

# Environment
.env
.env.local
*.env
```

## Node.js / JavaScript Projects

```gitignore
# OS
Thumbs.db
.DS_Store

# IDE
.vscode/
.idea/

# Dependencies
node_modules/
.pnp/
yarn-error.log*

# Build
dist/
build/
.next/
out/

# Environment
.env
.env.local
.env.*.local

# Logs
npm-debug.log*
yarn-debug.log*
```

## Jupyter / Data Science Projects

```gitignore
# OS
Thumbs.db
.DS_Store

# IDE
.vscode/
.idea/

# Notebook
.ipynb_checkpoints/
*/.ipynb_checkpoints/*

# Python
__pycache__/
*.py[cod]
.venv/
venv/

# Data (never commit raw data or large datasets)
data/raw/
data/processed/
*.csv
*.parquet
*.h5
*.hdf5
*.pkl
*.joblib

# Results
output/
results/
figures/

# Environment
.env
```

## Mixed Documentation / Specification Projects

```gitignore
# System
Thumbs.db
.DS_Store
Desktop.ini

# IDE
.vscode/
.idea/
*.swp
*.swo

# Temp
*.tmp
*.log
*.bak

# Build artifacts (if any)
__pycache__/
```

## General Principles

1. **Never commit**: credentials, private keys, tokens, env files
2. **Never commit**: large generated files, binaries, archives
3. **Never commit**: IDE/editor metadata and per-user settings
4. **Prefer broad patterns**: `*.tmp` catches everything, `logs/` catches all logs
5. **Keep it simple**: a 10-line .gitignore is better than a 50-line one for most projects
