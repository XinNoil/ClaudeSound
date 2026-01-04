#!/usr/bin/env zsh
#
# 测试修复后的 settings.json 写入功能
#

echo "=== 测试修复后的 settings.json 写入功能 ==="
echo ""

# 备份当前的 settings.json
SETTINGS_FILE="$HOME/.claude/settings.json"
BACKUP_FILE="/tmp/settings.json.test.backup"

if [ -f "$SETTINGS_FILE" ]; then
    cp "$SETTINGS_FILE" "$BACKUP_FILE"
    echo "✓ 已备份当前配置到: $BACKUP_FILE"
    echo ""
fi

# 测试 Python 方法
echo "1. 测试使用 Python 修复格式..."
if command -v python3 &> /dev/null; then
    echo "✓ Python3 可用"
    echo ""
    echo "原始文件内容（最后几行）:"
    tail -5 "$SETTINGS_FILE"
    echo ""

    # 创建一个测试用的损坏格式（用于测试修复）
    cat > /tmp/test_broken.json <<'EOF'
{
  "sandbox": {
    "enabled": false

  ,
  "env": {
    "test": "value"
  }
}
EOF

    echo "测试损坏的 JSON 格式:"
    cat /tmp/test_broken.json
    echo ""

    # 使用 Python 修复
    python3 -c "
import json

# 读取文件
with open('/tmp/test_broken.json', 'r') as f:
    content = f.read()

print('尝试解析损坏的 JSON...')
try:
    config = json.loads(content)
    print('✓ JSON 解析成功')
    print(json.dumps(config, indent=2))
except json.JSONDecodeError as e:
    print(f'✗ JSON 解析失败: {e}')
    print('')
    print('使用 sed 修复...')

    # 修复：移除错误的逗号位置
    import re
    fixed_content = re.sub(r'[[:space:]]*\n[[:space:]]*,\n[[:space:]]*([}\]])', r'\n\1', content)
    print(fixed_content)
"
else
    echo "✗ Python3 不可用，跳过测试"
fi

echo ""
echo "---"
echo ""

# 测试 jq 方法
echo "2. 测试使用 jq 修复格式..."
if command -v jq &> /dev/null; then
    echo "✓ jq 可用"

    # 创建测试文件
    cat > /tmp/test_format.json <<'EOF'
{
  "env": {
    "test": "value"
  },
  "sandbox": {
    "enabled": false
  }
}
EOF

    echo ""
    echo "添加 hooks 字段..."
    jq '. + {"hooks": {"PostToolUse": [{"matcher": "", "hooks": [{"type": "command", "command": "echo test"}]}]}}' /tmp/test_format.json

    echo ""
    echo "✓ jq 格式化成功"
else
    echo "✗ jq 不可用，跳过测试"
fi

echo ""
echo "---"
echo ""

# 测试 sed 方法
echo "3. 测试使用 sed 移除最后的 }..."
echo "原始文件:"
cat /tmp/test_format.json
echo ""

echo "移除最后的 } 及其前面的空白:"
echo "/tmp/test_format.json" | sed -e :a -e '/\n.*}$/!{N;ba;}' -e 's/[[:space:]]*$//' | head -c -1
echo ""
echo "（已移除最后的 }）"

echo ""
echo "---"
echo ""

# 测试当前脚本的 hooks 生成
echo "4. 测试脚本的 hooks 配置生成..."

if [ -f "./install-claude-sounds-v4.sh" ]; then
    echo "✓ 找到测试脚本: install-claude-sounds-v4.sh"

    # 提取并测试 generate_hooks_config 函数
    source ./install-claude-sounds-v4.sh

    echo ""
    echo "生成的 hooks 配置:"
    echo "{"
    echo "  \"hooks\": {"
    generate_hooks_config
    echo "  }"
    echo "}"

else
    echo "✗ 未找到测试脚本"
fi

echo ""
echo "=== 测试完成 ==="
