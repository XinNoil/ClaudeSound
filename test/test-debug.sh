#!/usr/bin/env zsh

# 带调试输出的测试脚本

# 启用调试模式
set -x  # 打印每个命令
# 或者使用
# set -v  # 打印脚本输入

echo "开始测试..."
echo ""

# 测试 read 命令
echo "测试 1: 基本 read 命令"
echo -n "请输入一个字符: "
local key=""
read -s -k 1 key 2>&1
echo ""
echo "读取到: '$key'"
echo "长度: ${#key}"
echo ""

echo "测试 2: read 命令返回值"
echo -n "请输入一个字符: "
key=""
if read -s -k 1 key 2>&1; then
    echo ""
    echo "读取成功"
    echo "读取到: '$key'"
else
    echo ""
    echo "读取失败"
    echo "返回码: $?"
fi
echo ""

echo "测试 3: 检查终端"
echo "STDOUT 是终端: [ -t 1 ] = $([ -t 1 ] && echo '是' || echo '否')"
echo "STDIN 是终端: [ -t 0 ] = $([ -t 0 ] && echo '是' || echo '否')"
echo "TTY: $(tty)"
echo ""

echo "测试 4: 在循环中测试 read"
local count=0
while [ $count -lt 3 ]; do
    echo -n "第 $((count + 1)) 次读取，请输入字符: "
    key=""
    read -s -k 1 key 2>&1
    echo ""
    echo "读取到: '$key'"
    ((count++))

    if [ "$key" = "q" ]; then
        echo "检测到 q，退出"
        break
    fi
done

echo ""
echo "测试完成！"
