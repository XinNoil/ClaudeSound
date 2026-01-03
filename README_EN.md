# Claude Code Sound Notifications

<div align="center">

![License](https://img.shields.io/badge/license-MIT-blue.svg)
![Platform](https://img.shields.io/badge/platform-macOS-lightgrey.svg)
![Shell](https://img.shields.io/badge/shell-bash-green.svg)

Configure sound notifications for Claude Code. Get audio alerts when AI completes tasks, so you don't need to keep staring at the screen.

English | [简体中文](README.md)

</div>

## ✨ Features

- 🎵 **Three Notification Sounds** - Unique sound effects for different scenarios
  - Task Complete Sound - Crisp glass sound
  - User Submit Sound - Hero entrance effect
  - Permission Request Sound - Clear notification ping
- 🚀 **One-Click Installation** - Automated installation script, no manual configuration required
- 🎨 **Custom Sound Effects** - Support for custom audio files
- ⚙️ **Flexible Configuration** - Configure different sounds for different tools
- 📝 **Detailed Documentation** - Complete configuration guide and usage instructions

## 📋 System Requirements

- **Operating System**: macOS
- **Shell**: Bash
- **Dependencies**: `afplay` (built into macOS)

## 🚀 Quick Start

### One-Click Installation

```bash
# Download installation script
curl -O https://raw.githubusercontent.com/XinNoil/ClaudeSound/main/install-claude-sounds.sh

# Add execute permission
chmod +x install-claude-sounds.sh

# Run installation
./install-claude-sounds.sh
```

Or use git:

```bash
# Clone repository
git clone https://github.com/XinNoil/ClaudeSound.git

# Enter directory
cd ClaudeSound

# Run installation
./install-claude-sounds.sh
```

### Manual Installation

See [Configuration Guide](docs/配置指南.md) (Chinese version)

## 📖 Usage

Restart Claude Code after installation for changes to take effect.

### Hook Events

| Event | Trigger | Sound | Purpose |
|------|---------|-------|---------|
| **PostToolUse** | After Claude executes tool operations | Glass.aiff | Indicates task completion |
| **UserPromptSubmit** | When user submits new prompt | Hero.aiff | Indicates command received |
| **PermissionRequest** | When Claude requests permission | Ping.aiff | Waiting for authorization |

### Test Notification Sounds

```bash
# Test task complete sound
~/.local/bin/claude-task-done.sh

# Test user submit sound
~/.local/bin/claude-user-prompt.sh

# Test user prompt sound
~/.local/bin/claude-ask-user.sh
```

## ⚙️ Custom Configuration

### Changing Notification Sounds

Edit the script file and replace the audio file path with your own:

```bash
~/.local/bin/claude-task-done.sh
```

### Supported Audio Formats

- AIFF
- MP3
- WAV
- M4A
- Other formats supported by `afplay`

### macOS System Sounds

```bash
ls /System/Library/Sounds/*.aiff
```

Available system sounds:
- `Glass.aiff` - Crisp glass sound (default)
- `Hero.aiff` - Hero entrance effect
- `Ping.aiff` - Clear notification ping
- `Basso.aiff` - Low notification sound
- `Funk.aiff` - Stylish effect
- `Purr.aiff` - Purring sound
- `Sosumi.aiff` - Classic Mac sound
- And more...

## 📁 Project Structure

```
ClaudeSound/
├── README.md                 # Project description (Chinese)
├── README_EN.md             # Project description (English)
├── LICENSE                  # MIT License
├── .gitignore              # Git ignore file
├── install-claude-sounds.sh # One-click installation script
└── docs/
    └── 配置指南.md          # Detailed configuration document (Chinese)
```

## 🔧 Advanced Configuration

### Configure Different Sounds for Different Tools

Edit `~/.claude/settings.json`:

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

### Combining Multiple Hooks

Configure multiple hooks for the same event:

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

## ❓ FAQ

### 1. No Sound

Check the following:
- [ ] System volume is turned on
- [ ] Script has execute permission (`ls -l ~/.local/bin/`)
- [ ] Audio file path is correct
- [ ] Test audio file directly with `afplay` command

### 2. Hook Not Triggering

Confirm the following:
- [ ] `settings.json` file location is correct (must be in `~/.claude/` directory)
- [ ] JSON format is correct
- [ ] Hook event name is correct
- [ ] Claude Code has been restarted

### 3. View Supported Hook Events

In Claude Code, type:

```
/hooks
```

## 📚 Documentation

- [Detailed Configuration Guide](docs/配置指南.md) (Chinese)
- [Claude Code Official Documentation](https://docs.anthropic.com/claude-code)

## 🤝 Contributing

Contributions are welcome! Feel free to submit Issues or Pull Requests.

1. Fork this repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details

## 🙏 Acknowledgments

- [Claude Code](https://docs.anthropic.com/claude-code) - Official AI programming assistant by Anthropic
- [Original Tutorial Article](https://zhuanlan.zhihu.com/p/1946504710031926731) - Provided implementation ideas

## 📮 Contact

- GitHub Issues: [Submit Issues](https://github.com/XinNoil/ClaudeSound/issues)

## ⭐ If this project helps you, please give it a Star!

<div align="center">

Made with ❤️ by Claude Code Community

</div>
