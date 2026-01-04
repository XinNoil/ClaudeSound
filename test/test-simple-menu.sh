#!/usr/bin/env zsh

# 简化的交互式菜单测试脚本

clear
echo "============================================"
echo "交互式菜单测试"
echo "============================================"
echo ""
echo "使用 ↑↓ 键移动，q 键退出"
echo ""

local current_selection=0
local items=("选项 1" "选项 2" "选项 3")

while true; do
    clear
    echo "============================================"
    echo "交互式菜单测试"
    echo "============================================"
    echo ""
    echo "使用 ↑↓ 键移动，q 键退出"
    echo ""

    # 显示选项
    local i=0
    while [ $i -lt 3 ]; do
        local cursor="  "
        if [ $i -eq $current_selection ]; then
            cursor="→ "
        fi
        echo "${cursor}${items[$i + 1]}"
        ((i++))
    done

    echo ""
    echo -n "等待输入..."

    # 读取单字符
    local key=""
    read -s -k 1 key 2>/dev/null || key=""

    # 调试：显示读取到的字符
    if [ -n "$key" ]; then
        echo " 读取到: '$key' (ASCII: $(printf '%d' "'$key"))"
    else
        echo " 读取到: 空"
    fi

    # 处理输入
    case "$key" in
        $'\e')  # ESC 字符
            echo "  -> 检测到 ESC"
            local key2=""
            read -s -k 1 key2 2>/dev/null || key2=""
            echo "  -> key2: '$key2'"

            if [ "$key2" = "[" ]; then
                local key3=""
                read -s -k 1 key3 2>/dev/null || key3=""
                echo "  -> key3: '$key3'"

                case "$key3" in
                    A)
                        echo "  -> 上键!"
                        if [ $current_selection -gt 0 ]; then
                            ((current_selection--))
                        fi
                        ;;
                    B)
                        echo "  -> 下键!"
                        if [ $current_selection -lt 2 ]; then
                            ((current_selection++))
                        fi
                        ;;
                esac
            fi
            ;;
        q|Q)
            echo ""
            echo "退出..."
            break
            ;;
    esac

    # 短暂延迟，让用户看到输出
    sleep 0.3
done

echo ""
echo "测试完成！"
