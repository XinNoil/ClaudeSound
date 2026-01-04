#!/usr/bin/env zsh

# 测试修复后的流程
echo "=== 测试输入缓冲区修复 ==="
echo ""

echo "步骤 1: 模拟 read 读取 y/n"
print_info() {
    echo -e "\033[0;34m[INFO]\033[0m $1"
}
print_info "是否使用交互式配置？(y/n，默认: n)"

# 模拟用户输入 "y\n"
read -r use_interactive <<< "y"
echo "读取到: '$use_interactive'"
echo ""

if [[ "$use_interactive" =~ ^[Yy]$ ]]; then
    echo "步骤 2: 清空输入缓冲区"
    local dummy=""
    local count=0
    while read -t 0.1 -k 1 dummy 2>/dev/null; do
        ((count++))
        echo "  清空字符: '$dummy'"
    done
    echo "  清空了 $count 个字符"
    echo ""

    echo "步骤 3: 测试 read -rsk1（3秒超时）"
    echo "现在请按方向键或其他键..."

    local input=""
    if read -t 3 -rsk1 input 2>/dev/null; then
        echo "读取到: '$input' (长度: ${#input})"

        case "$input" in
            A) echo "→ 上键";;
            B) echo "→ 下键";;
            C) echo "→ 右键";;
            D) echo "→ 左键";;
            "") echo "→ 空字符串（回车）";;
            *) echo "→ 其他键: '$input'";;
        esac
    else
        echo "超时：3秒内没有按键（说明缓冲区已清空，等待输入）"
    fi
fi

echo ""
echo "=== 测试完成 ==="
echo ""
echo "如果看到'超时'说明清空缓冲区有效"
echo "如果看到按键被正确识别说明 read -rsk1 工作正常"
