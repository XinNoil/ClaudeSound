#!/usr/bin/env zsh

# 真实终端测试 - 模拟完整的交互流程

echo "=== 真实终端交互测试 ==="
echo ""
echo "这个脚本会模拟 install-claude-sounds.sh 的交互流程"
echo ""

# 步骤 1: 测试环境
echo "步骤 1: 检查终端环境"
if [ -t 0 ]; then
    echo "✓ stdin 是终端"
else
    echo "✗ stdin 不是终端"
    echo "请在真实终端中运行此脚本"
    exit 1
fi
echo ""

# 步骤 2: 测试第一个 read
echo "步骤 2: 测试读取 y/n"
print_info() {
    echo -e "\033[0;34m[INFO]\033[0m $1"
}

print_info "是否使用交互式配置？(y/n，默认: n)"
read -r use_interactive

echo "读取到: '$use_interactive'"
echo ""

# 步骤 3: 如果输入 y，进入交互式菜单测试
if [[ "$use_interactive" =~ ^[Yy]$ ]]; then
    echo "步骤 3: 进入交互式菜单测试"
    echo "现在会清空输入缓冲区并设置终端..."

    # 保存终端设置
    local stty_old=$(stty -g 2>/dev/null)
    echo "保存的终端设置: $stty_old"

    # 清空输入缓冲区
    echo "清空输入缓冲区..."
    local count=0
    while read -t 0.1 -k 1 2>/dev/null; do
        ((count++))
    done
    echo "清空了 $count 个字符"

    # 设置终端
    echo "设置终端为非阻塞模式..."
    stty -echo -icanon min 0 time 0 2>/dev/null
    echo "终端设置完成"

    # 测试读取
    echo ""
    echo "现在测试读取按键（请按任意键，或等待 3 秒）..."
    local key=""
    if read -t 3 -rk1 key 2>/dev/null; then
        echo "读取到字符: '$key' (ASCII: $(printf '%d' "'$key"))"
        case "$key" in
            A) echo "→ 上键";;
            B) echo "→ 下键";;
            C) echo "→ 右键";;
            D) echo "→ 左键";;
            $'\r'|$'\n') echo "→ 回车键";;
            q|Q) echo "→ Q 键";;
            *) echo "→ 其他键";;
        esac
    else
        echo "超时：3秒内没有按键"
    fi

    # 恢复终端设置
    echo ""
    echo "恢复终端设置..."
    stty "$stty_old" 2>/dev/null
    echo "终端已恢复"
else
    echo "跳过交互式菜单测试"
fi

echo ""
echo "=== 测试完成 ==="
echo ""
echo "如果你能看到这个测试正常读取按键，说明交互式菜单应该可以工作"
