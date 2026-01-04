# Settings.json 格式错误修复指南

## 快速修复

如果你遇到了 `~/.claude/settings.json` 格式错误，可以：

### 方法 1：自动修复（推荐）

```bash
cd /path/to/ClaudeSound
./quick-fix.sh
```

### 方法 2：手动修复

```bash
cd /path/to/ClaudeSound
python3 fix-settings-json.py
```

### 方法 3：重新安装配置

```bash
cd /path/to/ClaudeSound
chmod +x install-claude-sounds-v4.sh
./install-claude-sounds-v4.sh
```

## 验证修复

运行以下命令验证 JSON 格式是否正确：

```bash
python3 -m json.tool ~/.claude/settings.json
```

如果没有输出任何错误，说明格式正确。

## 详细信息

- **问题分析**: 参见 [FIX_SUMMARY.md](FIX_SUMMARY.md)
- **修复工具**: `fix-settings-json.py`
- **新安装脚本**: `install-claude-sounds-v4.sh` (v3.1.2)

## 备份恢复

如果修复失败，可以从备份恢复：

```bash
# 列出所有备份
ls -la ~/.claude/settings.json.fixed.*

# 恢复最新的备份
cp ~/.claude/settings.json.fixed.YYYYMMDDHHMMSS ~/.claude/settings.json
```

## 技术支持

如果问题持续存在，请：

1. 查看详细的修复文档：[FIX_SUMMARY.md](FIX_SUMMARY.md)
2. 检查备份文件内容
3. 提供错误信息以便进一步诊断
