#!/usr/bin/env zsh

# 调试脚本：测试交互式菜单
echo "=== 调试交互式菜单 ==="
echo ""

# 检查环境
echo "1. 环境检查:"
if [ -t 0 ]; then
    echo "  ✓ stdin 是终端"
else
    echo "  ✗ stdin 不是终端（通过管道或重定向）"
fi

echo ""
echo "2. 模拟用户输入 'y' + 回车"

# 测试主流程
echo ""
echo "3. 测试主流程的 read 命令:"
echo -n "是否使用交互式配置？(y/n，默认: n): "

# 模拟 read 命令
if read -t 1 -r use_interactive <<< "y"; then
    echo "读取到: '$use_interactive'"
else
    echo "读取超时"
fi

echo ""
echo "4. 检查 is_interactive 函数:"
is_interactive() {
    [ -t 0 ]
}

if is_interactive; then
    echo "  ✓ is_interactive 返回 true"
else
    echo "  ✗ is_interactive 返回 false"
fi

echo ""
echo "5. 测试 read -rk1:"
echo "请按任意键（1秒超时）..."
if read -t 1 -rk1 key; then
    echo "  读取到: '$key' (ASCII: $(printf '%d' "'$key"))"
else
    echo "  超时或无输入"
fi

echo ""
echo "=== 结论 ==="
echo "如果 stdin 不是终端，交互式菜单无法正常工作"
