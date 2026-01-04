#!/usr/bin/env zsh

# 真实终端测试 - 模拟完整流程
echo "=== 真实终端测试 ==="
echo ""
echo "这个脚本需要你在真实终端中运行"
echo ""

echo "步骤 1: 询问是否进入交互式模式"
read -r "resp?是否使用交互式配置？"
echo "你输入了: '$resp'"
echo ""

if [[ "$resp" =~ ^[Yy]$ ]]; then
    echo "步骤 2: 进入交互式菜单"
    echo ""
    echo "现在测试 read -rsk1 的行为..."
    echo ""

    # 测试读取 5 个按键（超时 10 秒）
    local count=0
    while [ $count -lt 5 ]; do
        echo "请按按键 #$((count+1)) (或等待 10 秒超时)..."

        local input=""
        if read -t 10 -rsk1 input 2>/dev/null; then
            echo "  读取到: '$input' (长度: ${#input}, ASCII: $(printf '%d' "'$input"))"

            case "$input" in
                A) echo "  → 上键";;
                B) echo "  → 下键";;
                C) echo "  → 右键";;
                D) echo "  → 左键";;
                "") echo "  → 空字符串（可能是回车）";;
                $'\n') echo "  → 换行符";;
                $'\r') echo "  → 回车符";;
                *) echo "  → 其他字符";;
            esac
        else
            echo "  超时"
            break
        fi

        ((count++))
    done

    echo ""
    echo "测试完成"
else
    echo "跳过交互式测试"
fi

echo ""
echo "=== 测试结束 ==="
