#!/usr/bin/env zsh

# 诊断脚本 - 检测 stdin/stdout/stderr 是否是终端

echo "=== TTY 诊断脚本 ==="
echo ""

# 检查 stdin (fd 0)
if [ -t 0 ]; then
    echo "✓ stdin (fd 0) 是终端: $(tty 2>/dev/null || echo 'unknown')"
else
    echo "✗ stdin (fd 0) 不是终端（可能是管道或重定向）"
fi

# 检查 stdout (fd 1)
if [ -t 1 ]; then
    echo "✓ stdout (fd 1) 是终端: $(tty 2>/dev/null || echo 'unknown')"
else
    echo "✗ stdout (fd 1) 不是终端（可能是管道或重定向）"
fi

# 检查 stderr (fd 2)
if [ -t 2 ]; then
    echo "✓ stderr (fd 2) 是终端: $(tty 2>/dev/null || echo 'unknown')"
else
    echo "✗ stderr (fd 2) 不是终端（可能是管道或重定向）"
fi

echo ""
echo "=== 检查 /dev/tty ==="
if [ -c /dev/tty ]; then
    echo "✓ /dev/tty 存在且是字符设备"

    # 测试能否从 /dev/tty 读取
    echo ""
    echo "测试从 stdin 读取（按 Enter 继续）..."
    local test_input=""
    if read -t 2 -r test_input 2>/dev/null; then
        echo "✓ 从 stdin 读取成功: '$test_input'"
    else
        echo "✗ 从 stdin 读取失败或超时"
    fi

    echo ""
    echo "测试从 /dev/tty 读取（按 Enter 继续）..."
    test_input=""
    if read -t 2 -r test_input < /dev/tty 2>/dev/null; then
        echo "✓ 从 /dev/tty 读取成功: '$test_input'"
    else
        echo "✗ 从 /dev/tty 读取失败或超时"
    fi
else
    echo "✗ /dev/tty 不存在或不可访问"
fi

echo ""
echo "=== 测试 read -s -k 1 ==="
echo "从 stdin 读取单字符（按任意键）..."
local key=""
if read -s -k 1 -t 2 key 2>/dev/null; then
    echo "✓ 从 stdin 读取成功: '$key'"
else
    echo "✗ 从 stdin 读取失败或超时"
    echo "   这就是交互式菜单直接退出的原因！"
fi

echo ""
echo "从 /dev/tty 读取单字符（按任意键）..."
key=""
if read -s -k 1 -t 2 key < /dev/tty 2>/dev/null; then
    echo "✓ 从 /dev/tty 读取成功: '$key'"
else
    echo "✗ 从 /dev/tty 读取失败或超时"
fi

echo ""
echo "=== 结论 ==="
echo "如果 stdin 不是终端，read 命令会立即返回而不等待输入。"
echo "解决方案：使用 'read ... < /dev/tty' 强制从终端读取。"
