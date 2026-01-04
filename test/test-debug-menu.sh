#!/usr/bin/env zsh

# 调试版交互式菜单 - 显示按键信息

echo "=== 调试版交互式菜单 ==="
echo ""

# 初始化
local hook_names=("任务完成提示音" "用户提交提示音" "用户询问提示音")
local hook_enabled=(1 1 1)
local selected=0
local total=3

while true; do
    printf "\033[H\033[J"  # 清屏

    echo "=== 调试菜单 ==="
    echo ""
    echo "使用 ↑↓ 选择，回车切换，q 退出"
    echo ""

    # 显示菜单
    local i=0
    while [ $i -lt $total ]; do
        local status="[✓]"
        [ "${hook_enabled[$i]}" -eq 0 ] && status="[✗]"

        if [ $i -eq $selected ]; then
            echo -e "\033[1;33m→${NC} ${status} ${hook_names[$i]}"
        else
            echo "  ${status} ${hook_names[$i]}"
        fi
        ((i++))
    done

    echo ""
    echo "等待按键..."

    # 读取按键
    local input=""
    read -rsk1 input 2>/dev/null || input=""

    # 显示调试信息
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "调试信息："
    echo "  读取到: '$input'"
    echo "  长度: ${#input}"
    echo "  ASCII: $(printf '%d' "'$input" 2>/dev/null || echo 'N/A')"
    echo "  十六进制: $(printf '%x' "'$input" 2>/dev/null || echo 'N/A')"

    # 检测按键类型
    echo "  按键识别:"
    case "$input" in
        "")
            echo "    → 空字符串（可能是回车）"
            ;;
        $'\r')
            echo "    → 回车符 \\r (ASCII 13)"
            ;;
        $'\n')
            echo "    → 换行符 \\n (ASCII 10)"
            ;;
        $'\x0d')
            echo "    → 回车符 \\x0d"
            ;;
        "A")
            echo "    → 上键"
            ;;
        "B")
            echo "    → 下键"
            ;;
        "C")
            echo "    → 右键"
            ;;
        "D")
            echo "    → 左键"
            ;;
        "q"|"Q")
            echo "    → Q 键"
            ;;
        *)
            echo "    → 其他字符"
            ;;
    esac
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "按任意键继续..."
    read -rsk1

    # 处理按键
    case "$input" in
        "A")
            ((selected > 0)) && ((selected--))
            ;;
        "B")
            ((selected < total - 1)) && ((selected++))
            ;;
        $'\r'|$'\n'|"")  # 尝试匹配回车
            echo "切换 $selected 的启用状态..."
            if [ "${hook_enabled[$selected]}" -eq 1 ]; then
                hook_enabled[$selected]=0
            else
                hook_enabled[$selected]=1
            fi
            echo "按任意键继续..."
            read -rsk1
            ;;
        "q"|"Q")
            echo "退出"
            break
            ;;
    esac
done

echo ""
echo "=== 测试完成 ==="
