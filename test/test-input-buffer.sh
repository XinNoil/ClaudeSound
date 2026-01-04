#!/usr/bin/env zsh

# 测试输入缓冲区问题
echo "=== 测试输入缓冲区问题 ==="
echo ""

echo "步骤 1: 读取 y/n"
read -r use_interactive
echo "读取到: '$use_interactive'"
echo ""

echo "步骤 2: 检查缓冲区中是否还有字符"
echo "缓冲区中的字符:"
while read -t 0.5 -k 1 ch 2>/dev/null; do
    echo "  读取到: '$ch' (ASCII: $(printf '%d' "'$ch"))"
done
echo "  (缓冲区已清空)"
echo ""

echo "步骤 3: 测试 read -rsk1（3秒超时）"
echo "请按任意键..."
read -t 3 -rsk1 key
echo "读取到: '$key'"
