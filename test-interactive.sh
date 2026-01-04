#!/usr/bin/env zsh

# 测试方向键读取的简单脚本

echo "测试方向键读取..."
echo "请按方向键，然后按 q 退出"
echo ""

while true; do
    echo -n "等待输入... "

    # 方法1: 使用 read -s -k 1
    local key=""
    read -s -k 1 key 2>/dev/null || key=""

    echo "读取到: '$key' (ASCII: $(printf '%d' "'$key"))"

    if [ "$key" = $'\e' ]; then
        echo "  -> 检测到 ESC，读取后续字符..."

        local key2=""
        read -s -k 1 key2 2>/dev/null || key2=""
        echo "  key2: '$key2'"

        if [ "$key2" = "[" ]; then
            local key3=""
            read -s -k 1 key3 2>/dev/null || key3=""
            echo "  key3: '$key3'"

            case "$key3" in
                A) echo "  -> 上键!" ;;
                B) echo "  -> 下键!" ;;
                C) echo "  -> 右键!" ;;
                D) echo "  -> 左键!" ;;
            esac
        fi
    elif [ "$key" = "q" ]; then
        echo "退出..."
        break
    fi

    echo ""
done
