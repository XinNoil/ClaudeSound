# Claude Code 声音提示配置

<div align="center">

![License](https://img.shields.io/badge/license-MIT-blue.svg)
![Platform](https://img.shields.io/badge/platform-macOS-lightgrey.svg)
![Shell](https://img.shields.io/badge/shell-bash-green.svg)

为 Claude Code 配置声音提示功能，让 AI 在完成任务时播放提示音，无需一直盯着屏幕等待。

[English](README_EN.md) | 简体中文

</div>

## ✨ 功能特性

- 🎵 **三种提示音** - 针对不同场景配置专属音效
  - 任务完成音 - 清脆的玻璃声
  - 用户提交音 - 英雄登场音效
  - 权限请求音 - 清脆的提示音
- 🚀 **一键安装** - 自动化安装脚本，无需手动配置
- 🎨 **自定义音效** - 支持使用自定义音频文件
- ⚙️ **灵活配置** - 可为不同工具配置不同提示音
- 📝 **详细文档** - 完整的配置说明和使用指南

## 📋 系统要求

- **操作系统**: macOS
- **Shell**: Bash
- **依赖**: `afplay` (macOS 内置)

## 🚀 快速开始

### 一键安装

```bash
# 下载安装脚本
curl -O https://raw.githubusercontent.com/yourusername/claude-code-sounds/main/install-claude-sounds.sh

# 添加执行权限
chmod +x install-claude-sounds.sh

# 运行安装
./install-claude-sounds.sh
```

或使用 git：

```bash
# 克隆仓库
git clone https://github.com/yourusername/claude-code-sounds.git

# 进入目录
cd claude-code-sounds

# 运行安装
./install-claude-sounds.sh
```

### 手动安装

详见 [配置指南](docs/配置指南.md)

## 📖 使用说明

安装完成后，重启 Claude Code 即可生效。

### Hook 事件

| 事件 | 触发时机 | 音效 | 用途 |
|------|----------|------|------|
| **PostToolUse** | Claude 执行工具操作后 | Glass.aiff | 表示任务已完成 |
| **UserPromptSubmit** | 用户提交新的提示时 | Hero.aiff | 表示已接收指令 |
| **PermissionRequest** | Claude 请求权限时 | Ping.aiff | 等待授权确认 |

### 测试提示音

```bash
# 测试任务完成提示音
~/.local/bin/claude-task-done.sh

# 测试用户提交提示音
~/.local/bin/claude-user-prompt.sh

# 测试用户询问提示音
~/.local/bin/claude-ask-user.sh
```

## ⚙️ 自定义配置

### 更换提示音

编辑脚本文件，将音频文件路径改为你自己的文件：

```bash
~/.local/bin/claude-task-done.sh
```

### 支持的音频格式

- AIFF
- MP3
- WAV
- M4A
- 其他 `afplay` 支持的格式

### macOS 系统音效

```bash
ls /System/Library/Sounds/*.aiff
```

可选系统音效：
- `Glass.aiff` - 清脆的玻璃声（默认）
- `Hero.aiff` - 英雄登场音效
- `Ping.aiff` - 清脆的提示音
- `Basso.aiff` - 低沉提示音
- `Funk.aiff` - 时尚音效
- `Purr.aiff` - 呼噜声
- `Sosumi.aiff` - 经典 Mac 音效
- 更多...

## 📁 项目结构

```
claude-code-sounds/
├── README.md                 # 项目说明
├── README_EN.md             # 英文说明
├── LICENSE                  # MIT 许可证
├── .gitignore              # Git 忽略文件
├── install-claude-sounds.sh # 一键安装脚本
└── docs/
    └── 配置指南.md          # 详细配置文档
```

## 🔧 高级配置

### 为不同工具配置不同提示音

编辑 `~/.claude/settings.json`：

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "/Users/YOURNAME/.local/bin/claude-task-done.sh"
          }
        ]
      },
      {
        "matcher": "Edit",
        "hooks": [
          {
            "type": "command",
            "command": "/Users/YOURNAME/.local/bin/claude-user-prompt.sh"
          }
        ]
      }
    ]
  }
}
```

### 组合多个 Hook

在同一事件中配置多个 hook：

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "/Users/YOURNAME/.local/bin/claude-task-done.sh"
          },
          {
            "type": "command",
            "command": "echo 'Task completed at $(date)' >> ~/claude-tasks.log"
          }
        ]
      }
    ]
  }
}
```

## ❓ 常见问题

### 1. 没有声音

检查以下项目：
- [ ] 系统音量是否开启
- [ ] 脚本是否有执行权限（`ls -l ~/.local/bin/`）
- [ ] 音频文件路径是否正确
- [ ] 使用 `afplay` 命令直接测试音频文件

### 2. Hook 没有触发

确认以下事项：
- [ ] `settings.json` 文件位置是否正确（必须在 `~/.claude/` 目录下）
- [ ] JSON 格式是否正确
- [ ] Hook 事件名称是否正确
- [ ] 是否已重启 Claude Code

### 3. 查看支持的 Hook 事件

在 Claude Code 中输入：

```
/hooks
```

## 📚 文档

- [详细配置指南](docs/配置指南.md)
- [Claude Code 官方文档](https://docs.anthropic.com/claude-code)

## 🤝 贡献

欢迎贡献！请随时提交 Issue 或 Pull Request。

1. Fork 本仓库
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 开启 Pull Request

## 📄 许可证

本项目采用 MIT 许可证 - 详见 [LICENSE](LICENSE) 文件

## 🙏 致谢

- [Claude Code](https://docs.anthropic.com/claude-code) - Anthropic 官方 AI 编程助手
- [原教程文章](https://zhuanlan.zhihu.com/p/1946504710031926731) - 提供了实现思路

## 📮 联系方式

- GitHub Issues: [提交问题](https://github.com/yourusername/claude-code-sounds/issues)

## ⭐ 如果这个项目对你有帮助，请给个 Star！

<div align="center">

Made with ❤️ by Claude Code Community

</div>
