#!/usr/bin/env zsh

# 诊断脚本 - 测试 read 命令在不同环境中的行为

echo "=== 诊断脚本开始 ==="
echo ""
echo "当前时间: $(date)"
echo "当前 shell: $ZSH_VERSION"
echo "当前用户: $USER"
echo "当前终端: $(tty)"
echo ""
echo "=== 测试 1: 检查文件描述符 ==="
echo "STDIN (0): [ -t 0 ] = $([ -t 0 ] && echo 'TRUE (是终端)' || echo 'FALSE (不是终端)')"
echo "STDOUT (1): [ -t 1 ] = $([ -t 1 ] && echo 'TRUE (是终端)' || echo 'FALSE (不是终端)')"
echo "STDERR (2): [ -t 2 ] = $([ -t 2 ] && echo 'TRUE (是终端)' || echo 'FALSE (不是终端)')"
echo ""

echo "=== 测试 2: 基本 read 命令 ==="
echo -n "请输入一个字符然后按回车: "
local test1=""
read -r test1
echo "读取到: '$test1'"
echo "长度: ${#test1}"
echo ""

echo "=== 测试 3: read -s -k 1 命令 ==="
echo "请输入一个字符（不需要按回车）..."
local test2=""
local result=""
echo -n "等待输入..."
result=$(read -s -k 1 test2 2>&1)
echo ""
echo "命令返回值: $?"
echo "读取到: '$test2'"
echo "错误输出: '$result'"
echo ""

echo "=== 测试 4: read -s -k 1 在循环中 ==="
local count=0
echo "将尝试读取 3 次，每次最多等待 2 秒"
while [ $count -lt 3 ]; do
    echo -n "第 $((count + 1)) 次读取..."
    local key=""

    # 使用 timeout 命令限制等待时间
    if (timeout 2 read -s -k 1 key) 2>/dev/null; then
        echo " 成功! 读取到: '$key'"
        if [ "$key" = "q" ]; then
            echo "检测到 q，退出循环"
            break
        fi
    else
        echo " 超时或失败"
    fi

    ((count++))
done
echo ""

echo "=== 测试 5: 读取方向键 ==="
echo "请按一个方向键..."
local key=""
read -s -k 1 key 2>/dev/null
echo "第一个字符: '$key' (ASCII: $(printf '%d' "'$key"))"

if [ "$key" = $'\e' ]; then
    echo "检测到 ESC，继续读取..."
    local key2=""
    read -s -k 1 key2 2>/dev/null
    echo "第二个字符: '$key2' (ASCII: $(printf '%d' "'$key2"))"

    if [ "$key2" = "[" ]; then
        local key3=""
        read -s -k 1 key3 2>/dev/null
        echo "第三个字符: '$key3' (ASCII: $(printf '%d' "'$key3"))"

        case "$key3" in
            A) echo "==> 上键!" ;;
            B) echo "==> 下键!" ;;
            C) echo "==> 右键!" ;;
            D) echo "==> 左键!" ;;
            *) echo "==> 未知方向键" ;;
        esac
    fi
fi
echo ""

echo "=== 诊断脚本完成 ==="
