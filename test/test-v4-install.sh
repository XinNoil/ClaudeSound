#!/usr/bin/env zsh
#
# 测试 v4 版本安装脚本的 settings.json 写入功能
#

echo "=== 测试 install-claude-sounds-v4.sh ==="
echo ""

# 创建测试用的 settings.json
TEST_SETTINGS="/tmp/test-settings.json"
BACKUP_SETTINGS="$HOME/.claude/settings.json"

echo "1. 创建测试配置文件..."
cat > "$TEST_SETTINGS" <<'EOF'
{
  "env": {
    "TEST": "value"
  },
  "sandbox": {
    "enabled": false
  }
}
EOF

echo "✓ 测试文件创建完成: $TEST_SETTINGS"
echo ""

echo "2. 备份当前配置..."
if [ -f "$BACKUP_SETTINGS" ]; then
    cp "$BACKUP_SETTINGS" "/tmp/settings.json.backup.$(date +%Y%m%d%H%M%S)"
    echo "✓ 已备份当前配置"
else
    echo "⚠ 当前配置文件不存在"
fi
echo ""

echo "3. 测试添加 hooks 配置（使用 Python）..."

if command -v python3 &> /dev/null; then
    # 模拟安装脚本的 hooks 配置
    cat > /tmp/test_hooks.json <<'EOF'
{
  "PostToolUse": [
    {
      "matcher": "",
      "hooks": [
        {
          "type": "command",
          "command": "afplay /System/Library/Sounds/Glass.aiff"
        }
      ]
    }
  ]
}
EOF

    python3 <<PYTHON_SCRIPT
import json

# 读取测试配置
with open('$TEST_SETTINGS', 'r') as f:
    config = json.load(f)

# 读取 hooks 配置
with open('/tmp/test_hooks.json', 'r') as f:
    hooks = json.load(f)

# 添加 hooks
config['hooks'] = hooks

# 写回文件
with open('$TEST_SETTINGS', 'w') as f:
    json.dump(config, f, indent=2)

print("✓ 使用 Python 成功添加 hooks 配置")
PYTHON_SCRIPT

    echo ""
    echo "添加后的配置："
    cat "$TEST_SETTINGS"
    echo ""

else
    echo "✗ Python3 不可用"
fi

echo ""
echo "---"
echo ""

echo "4. 测试使用 jq 添加 hooks..."

if command -v jq &> /dev/null; then
    # 重新创建测试文件
    cat > "$TEST_SETTINGS" <<'EOF'
{
  "env": {
    "TEST": "value"
  },
  "sandbox": {
    "enabled": false
  }
}
EOF

    # 使用 jq 添加 hooks
    jq '. + {"hooks": {"PostToolUse": [{"matcher": "", "hooks": [{"type": "command", "command": "afplay /System/Library/Sounds/Glass.aiff"}]}]}}' "$TEST_SETTINGS" > "${TEST_SETTINGS}.new"
    mv "${TEST_SETTINGS}.new" "$TEST_SETTINGS"

    echo "✓ 使用 jq 成功添加 hooks 配置"
    echo ""
    echo "添加后的配置："
    cat "$TEST_SETTINGS"
    echo ""

else
    echo "✗ jq 不可用"
fi

echo ""
echo "---"
echo ""

echo "5. 验证生成的 JSON 格式..."

if command -v python3 &> /dev/null; then
    python3 <<PYTHON_SCRIPT
import json

try:
    with open('$TEST_SETTINGS', 'r') as f:
        config = json.load(f)
    print("✓ JSON 格式正确")
    print(f"✓ 配置字段: {', '.join(config.keys())}")
    print(f"✓ 包含 hooks: {'hooks' in config}")
except json.JSONDecodeError as e:
    print(f"✗ JSON 格式错误: {e}")
PYTHON_SCRIPT
fi

echo ""
echo "---"
echo ""

echo "6. 清理测试文件..."
rm -f "$TEST_SETTINGS" "/tmp/test_hooks.json"
echo "✓ 清理完成"

echo ""
echo "=== 测试完成 ==="
