#!/usr/bin/env zsh

# 测试交互式修复：验证智能读取函数
echo "=== 测试智能读取函数 ==="
echo ""

# 定义测试函数（与 install-claude-sounds.sh 中的实现相同）
is_interactive() {
    # 如果 stdin 是终端，返回成功
    [ -t 0 ] && return 0

    # 否则检查 /dev/tty 是否真正可用（尝试打开但不实际读取）
    if [ -c /dev/tty ]; then
        # 尝试以只读模式打开 /dev/tty（0.1秒超时）
        # 使用 exec 和重定向测试是否可打开
        if { read -t 0.1 < /dev/tty } 2>/dev/null; then
            return 0
        fi
    fi

    return 1
}

safe_read_key() {
    local timeout="${2:-0}"
    local var_name="$1"

    if [ -t 0 ]; then
        # stdin 是终端，直接从 stdin 读取
        if [ "$timeout" -gt 0 ]; then
            read -s -k 1 -t "$timeout" "$var_name" 2>/dev/null
        else
            read -s -k 1 "$var_name" 2>/dev/null
        fi
    elif [ -c /dev/tty ]; then
        # stdin 不是终端，尝试从 /dev/tty 读取（静默失败）
        if [ "$timeout" -gt 0 ]; then
            read -s -k 1 -t "$timeout" "$var_name" 2>/dev/null < /dev/tty
        else
            read -s -k 1 "$var_name" 2>/dev/null < /dev/tty
        fi
    else
        # 两者都不可用
        return 1
    fi
}

# 测试1：环境检测
echo "测试 1: 环境检测"
echo "----------------------------------------"
echo "检查 stdin (fd 0):"
if [ -t 0 ]; then
    echo "  ✓ stdin 是终端: $(tty 2>/dev/null || echo 'unknown')"
    STDIN_IS_TTY=1
else
    echo "  ✗ stdin 不是终端"
    STDIN_IS_TTY=0
fi

echo ""
echo "检查 /dev/tty:"
if [ -c /dev/tty ]; then
    echo "  ✓ /dev/tty 存在且是字符设备"
    TTY_EXISTS=1
else
    echo "  ✗ /dev/tty 不存在"
    TTY_EXISTS=0
fi

# 测试 /dev/tty 是否真正可用
echo ""
echo "测试 /dev/tty 是否真正可用:"
if [ -c /dev/tty ]; then
    if { read -t 0.1 < /dev/tty } 2>/dev/null; then
        echo "  ✓ /dev/tty 可以打开（交互式可用）"
        TTY_USABLE=1
    else
        echo "  ✗ /dev/tty 存在但无法打开（device not configured）"
        TTY_USABLE=0
    fi
else
    TTY_USABLE=0
fi

echo ""
echo "is_interactive() 结果:"
if is_interactive; then
    echo "  ✓ 交互式环境可用"
    INTERACTIVE_AVAILABLE=1
else
    echo "  ✗ 非交互式环境"
    INTERACTIVE_AVAILABLE=0
fi

echo ""

# 测试2：功能测试（仅在交互式环境中执行）
if [ $INTERACTIVE_AVAILABLE -eq 1 ]; then
    echo "测试 2: 智能读取功能测试"
    echo "----------------------------------------"

    echo "测试 2a: 读取单字符（5秒超时）"
    echo "请按任意键..."
    local key=""
    if safe_read_key key 0 5; then
        echo "  ✓ 成功读取字符: '$key'"
    else
        echo "  ✗ 读取失败或超时"
    fi

    echo ""
    echo "测试 2b: 读取方向键（5秒超时）"
    echo "请按方向键..."
    key=""
    if safe_read_key key 0 5; then
        if [ "$key" = $'\e' ]; then
            local key2=""
            safe_read_key key2 0 1 || key2=""

            if [ "$key2" = "[" ]; then
                local key3=""
                safe_read_key key3 0 1 || key3=""

                case "$key3" in
                    A) echo "  ✓ 检测到上键" ;;
                    B) echo "  ✓ 检测到下键" ;;
                    C) echo "  ✓ 检测到右键" ;;
                    D) echo "  ✓ 检测到左键" ;;
                    *) echo "  ? 检测到其他方向键字符: '$key3'" ;;
                esac
            else
                echo "  ✓ 检测到 ESC 键"
            fi
        else
            echo "  ✓ 读取到字符: '$key'"
        fi
    else
        echo "  ✗ 读取失败或超时"
    fi
else
    echo "测试 2: 跳过（非交互式环境）"
    echo "----------------------------------------"
    echo "无法在当前环境中测试交互功能"
fi

echo ""
echo "=== 测试完成 ==="
echo ""

# 总结
echo "总结:"
echo "------"
if is_interactive; then
    echo "✓ 当前环境支持交互式输入"
    echo "  交互式菜单应该能够正常工作"

    if [ $STDIN_IS_TTY -eq 1 ]; then
        echo "  → 使用 stdin 进行交互"
    elif [ $TTY_USABLE -eq 1 ]; then
        echo "  → 使用 /dev/tty 进行交互"
    fi
else
    echo "✗ 当前环境不支持交互式输入"
    echo "  脚本将使用默认配置，跳过交互式菜单"

    if [ $STDIN_IS_TTY -eq 0 ] && [ $TTY_EXISTS -eq 1 ] && [ $TTY_USABLE -eq 0 ]; then
        echo ""
        echo "  原因：/dev/tty 存在但无法使用（device not configured）"
        echo "  这通常发生在通过某些工具调用脚本时"
    fi
fi

echo ""
echo "下一步："
echo "  运行 ./install-claude-sounds.sh 测试完整的安装流程"
