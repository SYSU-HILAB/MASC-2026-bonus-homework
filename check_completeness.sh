#!/bin/bash

echo "--------------------------------"
echo "正在检查最终提交格式..."
echo "--------------------------------"
echo ""

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

errors=0
warnings=0

pass() {
    echo -e "${GREEN}✓${NC} $1"
}

fail() {
    echo -e "${RED}✗${NC} $1"
    errors=$((errors + 1))
}

warn() {
    echo -e "${YELLOW}警告：${NC}$1"
    warnings=$((warnings + 1))
}

echo "【必需文件检查】"
required_files=(
    "results/report.pdf"
    "results/demo.gif"
)

for file in "${required_files[@]}"; do
    if [ -f "$file" ]; then
        pass "$file 存在"
        if [ ! -s "$file" ]; then
            fail "$file 为空文件"
        fi
    else
        fail "$file 缺失"
    fi
done
echo ""

echo "【Git 提交检查】"
if [ -d ".git" ]; then
    pass ".git 文件夹存在"

    if git rev-parse --verify HEAD >/dev/null 2>&1; then
        pass "已存在 Git commit 记录"
    else
        fail "未发现 Git commit 记录，请在提交前至少完成一次 commit"
    fi

    if [ -n "$(git status --porcelain)" ]; then
        warn "当前工作区存在未提交修改，请在最终压缩前完成 commit"
    else
        pass "工作区无未提交修改"
    fi
else
    fail ".git 文件夹缺失，请不要删除 Git 版本记录"
fi
echo ""

echo "【编译产物检查】"
generated_dirs=(
    "build"
    "devel"
    "logs"
    ".catkin_tools"
)

found_generated=false
for dir in "${generated_dirs[@]}"; do
    if [ -d "$dir" ]; then
        warn "发现 $dir，压缩提交前建议删除该编译产物目录"
        found_generated=true
    fi
done

if [ "$found_generated" = false ]; then
    pass "未发现常见编译产物目录"
fi
echo ""

echo "--------------------------------"
if [ "$errors" -eq 0 ]; then
    if [ "$warnings" -eq 0 ]; then
        echo -e "${GREEN}所有检查均通过，可以压缩并提交。${NC}"
    else
        echo -e "${YELLOW}未发现错误，但仍有 $warnings 个警告。请确认后再压缩提交。${NC}"
    fi
    echo ""
    echo "示例压缩命令："
    echo "cd .. && zip -r 姓名-学号.zip MASC-2026-bonus-homework"
    exit 0
else
    echo -e "${RED}检查未通过，共发现 $errors 个错误。请修正后重新运行脚本。${NC}"
    exit 1
fi
