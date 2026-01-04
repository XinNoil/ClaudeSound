#!/usr/bin/env zsh
#
# Settings.json 快速修复脚本
#
# 使用方法：
#   ./quick-fix.sh
#

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Claude Code Settings.json 快速修复工具"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# 检查修复工具是否存在
if [ ! -f "./fix-settings-json.py" ]; then
    echo "✗ 找不到修复工具：fix-settings-json.py"
    echo ""
    echo "请确保在正确的目录下运行此脚本"
    exit 1
fi

# 运行修复工具
python3 fix-settings-json.py

# 检查修复结果
if [ $? -eq 0 ]; then
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  修复完成！"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "如果问题仍然存在，可以："
    echo "  1. 查看修复文档：cat docs/FIX_SUMMARY.md"
    echo "  2. 使用新的安装脚本：./install-claude-sounds-v4.sh"
    echo "  3. 从备份恢复：cp ~/.claude/settings.json.fixed.* ~/.claude/settings.json"
else
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  修复失败"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "请手动修复或联系技术支持"
    exit 1
fi
