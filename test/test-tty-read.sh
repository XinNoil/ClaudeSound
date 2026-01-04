#!/usr/bin/env zsh

# 测试修复：验证 /dev/tty 重定向是否有效
echo "=== 测试 /dev/tty 修复 ==="
echo ""

# 测试1：验证 /dev/tty 可访问
echo "测试 1: 检查 /dev/tty"
if [ -c /dev/tty ]; then
    echo "✓ /dev/tty 存在且是字符设备"
else
    echo "✗ /dev/tty 不可用"
    exit 1
fi

echo ""

# 测试2：测试从 /dev/tty 读取（模拟交互式菜单的 read 命令）
echo "测试 2: 测试从 /dev/tty 读取单字符"
echo "请按任意键（测试将在 5 秒后超时）..."

local key=""
if read -s -k 1 -t 5 key 2>/dev/null < /dev/tty; then
    echo ""
    echo "✓ 成功从 /dev/tty 读取字符: '$key'"
else
    echo ""
    echo "✗ 从 /dev/tty 读取失败或超时"
fi

echo ""

# 测试3：测试方向键读取（ESC 序列）
echo "测试 3: 测试方向键读取"
echo "请按方向键（测试将在 5 秒后超时）..."

local key=""
if read -s -k 1 -t 5 key 2>/dev/null < /dev/tty; then
    if [ "$key" = $'\e' ]; then
        local key2=""
        read -s -k 1 -t 1 key2 2>/dev/null < /dev/tty || key2=""

        if [ "$key2" = "[" ]; then
            local key3=""
            read -s -k 1 -t 1 key3 2>/dev/null < /dev/tty || key3=""

            case "$key3" in
                A) echo "✓ 检测到上键" ;;
                B) echo "✓ 检测到下键" ;;
                C) echo "✓ 检测到右键" ;;
                D) echo "✓ 检测到左键" ;;
                *) echo "✓ 检测到其他方向键字符: '$key3'" ;;
            esac
        else
            echo "✓ 检测到 ESC 键"
        fi
    else
        echo "✓ 读取到字符: '$key'"
    fi
else
    echo "✗ 方向键读取超时"
fi

echo ""
echo "=== 测试完成 ==="
echo ""
echo "结论："
echo "如果上述测试全部通过，说明 /dev/tty 读取功能正常。"
echo "交互式菜单现在应该能够正常工作了。"
