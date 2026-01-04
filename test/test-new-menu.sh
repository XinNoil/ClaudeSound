#!/usr/bin/env zsh

# 简单的交互式菜单测试（基于 ArrowKeysMenu 的实现）

# 颜色定义
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo "=== 测试新的交互式菜单实现 ==="
echo ""
echo "基于以下真实项目的正确实现："
echo "- ArrowKeysMenu (portobanco51)"
echo "- selector (joknarf)"
echo ""

# 检查环境
if [ ! -t 0 ]; then
    echo -e "${RED}错误：stdin 不是终端${NC}"
    echo "请在真实终端中运行此测试"
    exit 1
fi

echo -e "${GREEN}✓ stdin 是终端${NC}"
echo ""

# 简单的菜单测试
options=("选项 1" "选项 2" "选项 3" "退出")
selected=0
total=4

# 保存终端设置
stty_old=$(stty -g 2>/dev/null)

# 设置终端
stty -echo -icanon 2>/dev/null || true
tput civis 2>/dev/null || true

echo -e "${CYAN}使用方向键上下移动，回车选择${NC}"
echo ""

while true; do
    # 清屏并显示菜单
    printf "\033[H\033[J"

    echo -e "${CYAN}=== 简单菜单测试 ===${NC}"
    echo ""

    local i=0
    while [ $i -lt $total ]; do
        if [ $i -eq $selected ]; then
            echo -e "${YELLOW}→ ${options[$i+1]}${NC}"
        else
            echo "  ${options[$i+1]}"
        fi
        ((i++))
    done

    echo ""
    echo -e "${CYAN}按 ↑↓ 选择，回车确认，q 退出${NC}"

    # 读取按键
    local key=""
    read -rsk1 key 2>/dev/null || key=""

    # 处理按键
    case "$key" in
        A)  # 上键
            if [ $selected -gt 0 ]; then
                ((selected--))
            else
                selected=$((total - 1))
            fi
            ;;
        B)  # 下键
            if [ $selected -lt $((total - 1)) ]; then
                ((selected++))
            else
                selected=0
            fi
            ;;
        '')  # 回车
            if [ $selected -eq $((total - 1)) ]; then
                break
            fi
            echo ""
            echo -e "${GREEN}你选择了：${options[$selected+1]}${NC}"
            echo ""
            echo "按任意键继续..."
            read -rsk1
            ;;
        q|Q)  # 退出
            break
            ;;
    esac
done

# 恢复终端设置
stty "$stty_old" 2>/dev/null || true
tput cnorm 2>/dev/null || true

printf "\033[H\033[J"
echo -e "${GREEN}=== 测试完成 ===${NC}"
echo ""
echo "如果菜单能正常响应方向键，说明实现正确！"
echo ""
echo "现在可以运行 ./install-claude-sounds.sh 测试完整安装"
