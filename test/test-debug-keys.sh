#!/usr/bin/env zsh

# 测试按键识别
echo "=== 测试按键识别 ==="
echo ""
echo "请按以下键测试（每个键按一次）："
echo "1. 回车键"
echo "2. q 键"
echo "3. 方向键上"
echo "4. 方向键下"
echo ""

local test_count=0
while [ $test_count -lt 4 ]; do
    echo "等待按键... (当前测试 $((test_count + 1))/4)"

    local input=""
    read -rsk1 input 2>/dev/null || input=""

    echo "读取到: '$input'"
    echo "ASCII 码: $(printf '%d' "'$input")"
    echo "长度: ${#input}"

    case "$input" in
        "")
            echo "→ 这是空字符串（回车键）"
            ;;
        $'\n')
            echo "→ 这是换行符 \\n"
            ;;
        $'\r')
            echo "→ 这是回车符 \\r"
            ;;
        "q")
            echo "→ 这是 q 键"
            ;;
        "Q")
            echo "→ 这是 Q 键"
            ;;
        "A")
            echo "→ 这是上键"
            ;;
        "B")
            echo "→ 这是下键"
            ;;
        *)
            echo "→ 其他字符"
            ;;
    esac

    echo ""
    ((test_count++))
done

echo "=== 测试完成 ==="
