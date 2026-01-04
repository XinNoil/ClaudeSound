# Claude Code 声音提示配置

<div align="center">

![License](https://img.shields.io/badge/license-MIT-blue.svg)
![Platform](https://img.shields.io/badge/platform-macOS%20%7C%20Linux%20%7C%20Windows-lightgrey.svg)
![Shell](https://img.shields.io/badge/shell-bash-green.svg)

为 Claude Code 配置声音提示功能，让 AI 在完成任务时播放提示音，无需一直盯着屏幕等待。

[English](README_EN.md) | 简体中文

</div>

## ✨ 功能特性

- 🎵 **六种提示音** - 针对不同场景配置专属音效
  - 任务完成音 - 清脆的玻璃声/系统提示音
  - 用户提交音 - 英雄登场音效/系统提示音
  - 用户询问音 - 清脆的提示音/系统提示音
  - 权限请求音 - 清脆的提示音/系统提示音
  - 空闲等待音 - 清脆的玻璃声/系统提示音
  - 任务停止音 - 英雄登场音效/系统提示音
- 🚀 **一键安装** - 自动化安装脚本，无需手动配置
- 🎮 **交互式配置** - 可选择启用哪些通知及使用哪种铃声
- 🌍 **跨平台支持** - 支持 macOS、Linux 和 Windows
- 🎨 **自定义音效** - 支持使用自定义音频文件
- ⚙️ **灵活配置** - 可为不同工具配置不同提示音
- 📝 **详细文档** - 完整的配置说明和使用指南

## 📋 系统要求

### macOS
- **操作系统**: macOS 10.12+
- **Shell**: Bash
- **依赖**: `afplay` (macOS 内置)

### Linux
- **操作系统**: 任意 Linux 发行版
- **Shell**: Bash
- **依赖**: 系统终端提示音 (`echo -e "\a"`)

### Windows
- **操作系统**: Windows 10/11
- **环境**: Git Bash、MSYS2 或 WSL
- **依赖**: PowerShell (Windows 内置)

## 🚀 快速开始

### 一键安装（默认配置）

```bash
# 下载安装脚本
curl -O https://raw.githubusercontent.com/XinNoil/claude-code-sounds/main/install-claude-sounds.sh

# 添加执行权限
chmod +x install-claude-sounds.sh

# 运行安装（使用默认配置）
./install-claude-sounds.sh
```

默认配置会启用所有通知并使用系统默认铃声。

### 交互式安装

```bash
# 运行安装并进入交互式配置模式
./install-claude-sounds.sh

# 当提示"是否使用交互式配置？"时，输入 y
```

交互式配置提供统一的键盘导航界面：
- ✅ **↑↓ 键**：在不同通知之间移动光标
- ✅ **回车键**：切换当前通知的启用/禁用状态
- ✅ **←→ 键**：切换当前通知的铃声类型（立即试听）
- ✅ **q 键**：完成配置并继续

**支持的平台铃声选项**：

#### macOS
- Glass - 清脆的玻璃声（默认）
- Hero - 英雄登场音效
- Ping - 清脆的提示音
- Basso - 低沉提示音
- Funk - 时尚音效
- Purr - 呼噜声
- Sosumi - 经典 Mac 音效

#### Linux
- System Bell - 系统终端蜂鸣声（默认）
- paplay - PulseAudio 声音系统
- aplay - ALSA 声音系统

#### Windows (Git Bash/MSYS2/WSL)
- Beep(800,200) - 标准提示音
- Beep(1000,150) - 高音提示音
- Beep(1200,100) - 高频提示音

或使用 git：

```bash
# 克隆仓库
git clone https://github.com/XinNoil/claude-code-sounds.git

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

本项目支持以下 Claude Code 钩子事件：

| 事件 | 触发时机 | 音效 | 用途 |
|------|----------|------|------|
| **PostToolUse** | Claude 执行工具操作后 | Glass.aiff | 表示任务已完成 |
| **UserPromptSubmit** | 用户提交新的提示时 | Hero.aiff | 表示已接收指令 |
| **PermissionRequest** | Claude 请求权限时 | Ping.aiff | 等待授权确认 |
| **Notification (permission_prompt)** | Claude 需要权限时 | Ping.aiff | 权限请求通知 |
| **Notification (idle_prompt)** | Claude 等待输入时 | Glass.aiff | 空闲等待通知 |
| **Stop** | Claude 任务完成响应时 | Hero.aiff | 表示任务结束 |

### Notification 事件详解

Notification 事件包含多个子类型，本项目支持其中两个：

- **permission_prompt** - 当 Claude 需要用户授权执行某些操作时触发
- **idle_prompt** - 当 Claude 等待用户输入超过 60 秒时触发

### Claude Code 所有钩子事件参考

根据官方文档，Claude Code 支持以下 10 个钩子事件：

1. **PreToolUse** - 工具调用前运行（支持 matcher）
2. **PermissionRequest** - 显示权限对话框时运行（支持 matcher）
3. **PostToolUse** - 工具成功完成后运行（支持 matcher）✅ *已支持*
4. **Notification** - 发送通知时运行（支持 matcher）
   - `permission_prompt` - 权限请求 ✅ *已支持*
   - `idle_prompt` - 等待用户输入（闲置 60+ 秒）✅ *已支持*
   - `auth_success` - 认证成功
   - `elicitation_dialog` - MCP 工具输入需要
5. **UserPromptSubmit** - 用户提交提示时运行 ✅ *已支持*
6. **Stop** - 主代理完成响应时运行 ✅ *已支持*
7. **SubagentStop** - 子代理完成响应时运行
8. **PreCompact** - 运行压缩操作前运行
9. **SessionStart** - 开始或恢复会话时运行
10. **SessionEnd** - 会话结束时运行

> 💡 提示：你可以根据需要为其他钩子事件配置声音提示。详情请参考 [Claude Code 官方文档](https://code.claude.com/docs/en/hooks)

### 测试提示音

#### macOS
```bash
# 测试任务完成提示音
~/.local/bin/claude-task-done.sh

# 测试用户提交提示音
~/.local/bin/claude-user-prompt.sh

# 测试用户询问提示音
~/.local/bin/claude-ask-user.sh

# 测试权限请求提示音
~/.local/bin/claude-permission-prompt.sh

# 测试空闲等待提示音
~/.local/bin/claude-idle-prompt.sh

# 测试任务停止提示音
~/.local/bin/claude-stop.sh
```

#### Linux
```bash
# 测试提示音（所有脚本使用相同的声音）
~/.local/bin/claude-task-done.sh
~/.local/bin/claude-user-prompt.sh
~/.local/bin/claude-ask-user.sh
~/.local/bin/claude-permission-prompt.sh
~/.local/bin/claude-idle-prompt.sh
~/.local/bin/claude-stop.sh
```

#### Windows (Git Bash/MSYS2/WSL)
```bash
# 测试任务完成提示音
~/.local/bin/claude-task-done.sh

# 测试用户提交提示音
~/.local/bin/claude-user-prompt.sh

# 测试用户询问提示音
~/.local/bin/claude-ask-user.sh

# 测试权限请求提示音
~/.local/bin/claude-permission-prompt.sh

# 测试空闲等待提示音
~/.local/bin/claude-idle-prompt.sh

# 测试任务停止提示音
~/.local/bin/claude-stop.sh
```

## ⚙️ 自定义配置

### 更换提示音

#### macOS
编辑脚本文件，将音频文件路径改为你自己的文件：

```bash
~/.local/bin/claude-task-done.sh
```

**macOS 系统音效位置：**
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

**支持的音频格式：**
- AIFF
- MP3
- WAV
- M4A
- 其他 `afplay` 支持的格式

#### Linux
编辑脚本文件以使用不同的声音播放方式：

```bash
~/.local/bin/claude-task-done.sh
```

**其他 Linux 声音播放方式：**

1. **使用 paplay (PulseAudio)**：
```bash
paplay /usr/share/sounds/freedesktop/stereo/complete.oga
```

2. **使用 aplay (ALSA)**：
```bash
aplay /usr/share/sounds/alsa/Front_Center.wav
```

3. **使用 paplay 系统音效**：
```bash
# 查看可用音效
ls /usr/share/sounds/freedesktop/stereo/
```

#### Windows (Git Bash/MSYS2/WSL)
编辑脚本文件以调整提示音的频率和时长：

```bash
~/.local/bin/claude-task-done.sh
```

**PowerShell Beep 参数：**
```bash
powershell.exe -Command "[console]::beep(频率, 时长)"
```

- 频率范围：37 - 32767 Hz
- 时长单位：毫秒

**示例：**
```bash
# 低沉提示音
powershell.exe -Command "[console]::beep(400, 300)"

# 高音提示音
powershell.exe -Command "[console]::beep(1500, 100)"

# 双音提示音
powershell.exe -Command "[console]::beep(800, 100); [console]::beep(1200, 100)"
```

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

#### macOS
检查以下项目：
- [ ] 系统音量是否开启
- [ ] 脚本是否有执行权限（`ls -l ~/.local/bin/`）
- [ ] 音频文件路径是否正确
- [ ] 使用 `afplay` 命令直接测试音频文件

#### Linux
检查以下项目：
- [ ] 系统音量是否开启
- [ ] 终端是否启用了系统提示音
- [ ] 脚本是否有执行权限
- [ ] 尝试其他声音播放方式（paplay、aplay 等）

**启用终端提示音：**
```bash
# 编辑 ~/.inputrc 或 /etc/inputrc
set bell-style audible
```

#### Windows (Git Bash/MSYS2/WSL)
检查以下项目：
- [ ] 系统音量是否开启
- [ ] PowerShell 是否可用
- [ ] 脚本是否有执行权限
- [ ] 在 PowerShell 中直接测试：`[console]::beep(800, 200)`

### 2. Hook 没有触发

确认以下事项：
- [ ] `settings.json` 文件位置是否正确（必须在 `~/.claude/` 目录下）
- [ ] JSON 格式是否正确
- [ ] Hook 事件名称是否正确
- [ ] 是否已重启 Claude Code

### 3. Windows 下脚本路径问题

如果在 Windows 下遇到路径问题，请确保：
- 使用 Git Bash、MSYS2 或 WSL 环境
- 脚本使用 Unix 风格的路径分隔符（/）
- 脚本有执行权限（`chmod +x ~/.local/bin/*.sh`）

### 4. 查看支持的 Hook 事件

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

- GitHub Issues: [提交问题](https://github.com/XinNoil/ClaudeSound/issues)

## ⭐ 如果这个项目对你有帮助，请给个 Star！

<div align="center">

Made with ❤️ by Claude Code Community

</div>
