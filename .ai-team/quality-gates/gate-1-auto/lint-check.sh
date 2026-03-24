#!/bin/bash
# 品質閘門自動化檢查腳本
# Gate 1: 自動化檢查

set -e

echo "🔍 執行品質閘門第一層：自動化檢查"
echo "================================"

# 顏色定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 計數器
PASSED=0
FAILED=0
WARNINGS=0

# 檢查函數
check_pass() {
    echo -e "${GREEN}✓${NC} $1"
    ((PASSED++))
}

check_fail() {
    echo -e "${RED}✗${NC} $1"
    ((FAILED++))
}

check_warn() {
    echo -e "${YELLOW}⚠${NC} $1"
    ((WARNINGS++))
}

# ========== 語法檢查 ==========
echo ""
echo "📋 語法檢查"
echo "-----------"

# Python 檢查
if command -v python3 &> /dev/null; then
    if [ -f "requirements.txt" ] || [ -f "pyproject.toml" ]; then
        echo "檢查 Python 語法..."
        if python3 -m py_compile $(find . -name "*.py" -not -path "./venv/*" -not -path "./.git/*" 2>/dev/null) 2>/dev/null; then
            check_pass "Python 語法檢查"
        else
            check_fail "Python 語法檢查"
        fi
    fi
fi

# JavaScript/TypeScript 檢查
if [ -f "package.json" ]; then
    if command -v npx &> /dev/null; then
        echo "檢查 JavaScript/TypeScript 語法..."
        if npx tsc --noEmit 2>/dev/null; then
            check_pass "TypeScript 語法檢查"
        else
            check_warn "TypeScript 語法檢查 (未配置或存在錯誤)"
        fi
    fi
fi

# ========== 格式檢查 ==========
echo ""
echo "🎨 格式檢查"
echo "-----------"

# Prettier 檢查
if [ -f ".prettierrc" ] || [ -f ".prettierrc.json" ]; then
    if command -v npx &> /dev/null; then
        if npx prettier --check . 2>/dev/null; then
            check_pass "Prettier 格式檢查"
        else
            check_fail "Prettier 格式檢查"
        fi
    fi
fi

# ========== 測試檢查 ==========
echo ""
echo "🧪 測試檢查"
echo "-----------"

# Python 測試
if [ -f "pytest.ini" ] || [ -d "tests" ]; then
    if command -v pytest &> /dev/null; then
        if pytest --tb=short -q 2>/dev/null; then
            check_pass "Python 單元測試"
        else
            check_fail "Python 單元測試"
        fi
    fi
fi

# Node.js 測試
if [ -f "package.json" ]; then
    if npm test 2>/dev/null; then
        check_pass "Node.js 測試"
    else
        check_warn "Node.js 測試 (未配置或存在失敗)"
    fi
fi

# ========== 安全檢查 ==========
echo ""
echo "🔒 安全檢查"
echo "-----------"

# npm audit
if [ -f "package.json" ]; then
    if npm audit --audit-level=moderate 2>/dev/null; then
        check_pass "npm 安全審計"
    else
        check_warn "npm 安全審計 (發現問題)"
    fi
fi

# 檢查敏感檔案
if [ -f ".env" ] && ! grep -q ".env" .gitignore 2>/dev/null; then
    check_fail ".env 未加入 .gitignore"
else
    check_pass "敏感檔案保護"
fi

# ========== 文件檢查 ==========
echo ""
echo "📚 文件檢查"
echo "-----------"

# 檢查必要文件
for file in "README.md" "AGENTS.md" "SOUL.md"; do
    if [ -f "$file" ]; then
        check_pass "$file 存在"
    else
        check_warn "$file 不存在"
    fi
done

# ========== 總結 ==========
echo ""
echo "================================"
echo "📊 檢查結果總結"
echo "================================"
echo -e "${GREEN}通過: $PASSED${NC}"
echo -e "${RED}失敗: $FAILED${NC}"
echo -e "${YELLOW}警告: $WARNINGS${NC}"
echo ""

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}✅ 第一層閘門通過！${NC}"
    exit 0
else
    echo -e "${RED}❌ 第一層閘門未通過，請修正後重試${NC}"
    exit 1
fi
