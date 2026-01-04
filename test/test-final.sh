#!/usr/bin/env zsh

# 完整的交互式菜单测试 - 包含缓冲区清空
echo "=== 完整交互式菜单测试 ==="
echo ""
echo "这个脚本完全模拟 install-claude-sounds.sh 的流程"
echo ""

# 检查环境
if [ ! -t 0 ]; then
    echo "错误：请在真实终端中运行此脚本"
    exit 1
fi

print_info() {
    echo -e "\033[0;34m[INFO]\033[0m $1"
}

# 步骤 1: 询问是否进入交互式模式
print_info "是否使用交互式配置？(y/n，默认: n)"
read -r use_interactive
echo "你输入了: '$use_interactive'"
echo ""

if [[ "$use_interactive" =~ ^[Yy]$ ]]; then
    print_info "进入交互式菜单..."
    echo ""

    # 步骤 2: 清空输入缓冲区
    echo "步骤 1: 清空输入缓冲区"
    local dummy=""
    local count=0
    while read -t 0.1 -k 1 dummy 2>/dev/null; do
        ((count++))
    done
    echo "  清空了 $count 个残留字符"
    echo ""

    # 步骤 3: 交互式菜单循环
    echo "步骤 2: 进入菜单循环（按 q 退出）"
    echo ""

    local items=("选项 1" "选项 2" "选项 3")
    local selected=0
    local total=3

    # 简单的菜单循环
    while true; do
        printf "\033[H\033[J"  # 清屏

        echo "=== 测试菜单 ==="
        echo ""

        local i=0
        while [ $i -lt $total ]; do
            if [ $i -eq $selected ]; then
                echo -e "\033[1;33m→ ${items[$i+1]}\033[0m"
            else
                echo "  ${items[$i+1]}"
            fi
            ((i++))
        done

        echo ""
        echo "使用 ↑↓ 选择，回车确认，q 退出"
        echo ""

        # 读取按键 - ArrowKeysMenu 的方式
        local input=""
        read -rsk1 input 2>/dev/null || input=""

        echo "调试：读取到 '$input' (长度: ${#input})"

        # 处理按键
        case $input in
            A)
                if [ $selected -gt 0 ]; then
                    ((selected--))
                else
                    selected=$((total - 1))
                fi
                ;;
            B)
                if [ $selected -lt $((total - 1)) ]; then
                    ((selected++))
                else
                    selected=0
                fi
                ;;
            "")
                echo "你选择了: ${items[$selected+1]}"
                echo ""
                echo "按任意键继续..."
                read -rsk1
                ;;
            q|Q)
                echo "退出菜单"
                break
                ;;
        esac
    done
fi

echo ""
echo "=== 测试完成 ==="
