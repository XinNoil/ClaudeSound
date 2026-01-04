# Claude Code Sound Notifications

<div align="center">

![License](https://img.shields.io/badge/license-MIT-blue.svg)
![Platform](https://img.shields.io/badge/platform-macOS%20%7C%20Linux%20%7C%20Windows-lightgrey.svg)
![Shell](https://img.shields.io/badge/shell-bash-green.svg)

Configure sound notifications for Claude Code. Get audio alerts when AI completes tasks, so you don't need to keep staring at the screen.

English | [简体中文](README.md)

</div>

## ✨ Features

- 🎵 **Six Notification Sounds** - Unique sound effects for different scenarios
  - Tool Call Sound - Crisp glass sound/system bell
  - User Submit Sound - Hero entrance effect/system bell
  - User Ask Sound - Clear notification ping/system bell
  - Permission Request Sound - Clear notification ping/system bell
  - Idle Prompt Sound - Crisp glass sound/system bell
  - Task Stop Sound - Hero entrance effect/system bell
- 🚀 **One-Click Installation** - Automated installation script, no manual configuration required
- 🎮 **Interactive Configuration** - Choose which notifications to enable and select ringtones
- 🌍 **Cross-Platform Support** - Supports macOS, Linux, and Windows
- 🎨 **Custom Sound Effects** - Support for custom audio files
- ⚙️ **Flexible Configuration** - Configure different sounds for different tools
- 📝 **Detailed Documentation** - Complete configuration guide and usage instructions

## 📋 System Requirements

### macOS
- **Operating System**: macOS 10.12+
- **Shell**: Bash
- **Dependencies**: `afplay` (built into macOS)

### Linux
- **Operating System**: Any Linux distribution
- **Shell**: Bash
- **Dependencies**: System terminal bell (`echo -e "\a"`)

### Windows
- **Operating System**: Windows 10/11
- **Environment**: Git Bash, MSYS2, or WSL
- **Dependencies**: PowerShell (built into Windows)

## 🚀 Quick Start

### One-Click Installation (Default Configuration)

```bash
# Download installation script
curl -O https://raw.githubusercontent.com/XinNoil/ClaudeSound/main/install-claude-sounds.sh

# Add execute permission
chmod +x install-claude-sounds.sh

# Run installation (with default configuration)
./install-claude-sounds.sh
```

Default configuration enables all notifications with system default ringtones.

### Interactive Installation

```bash
# Run installation with interactive configuration
./install-claude-sounds.sh

# When prompted "Use interactive configuration?", enter y
```

Interactive configuration provides a simple keyboard operation interface:
- ✅ **↑↓ Arrow Keys**: Move cursor between different notifications (→ arrow indicates current selection)
- ✅ **Enter Key**: Toggle enable/disable for currently selected notification
- ✅ **←→ Arrow Keys**: Switch ringtone type for currently selected notification (individual setting, not batch)
- ✅ **q Key**: Complete configuration and continue installation

**Supported Platform Ringtone Options**:

#### macOS
- Glass - Crisp glass sound (default)
- Hero - Hero entrance effect
- Ping - Clear notification ping
- Basso - Low notification sound
- Funk - Stylish effect
- Purr - Purring sound
- Sosumi - Classic Mac sound

#### Linux
- System Bell - Terminal bell (default)
- paplay - PulseAudio sound system
- aplay - ALSA sound system

#### Windows (Git Bash/MSYS2/WSL)
- Beep(800,200) - Standard beep
- Beep(1000,150) - High-pitch beep
- Beep(1200,100) - High-frequency beep

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

This project supports the following Claude Code hook events:

| Event | Trigger | Sound | Purpose |
|------|---------|-------|---------|
| **PostToolUse** | After Claude executes tool operations | Glass.aiff | Tool call completion notification |
| **UserPromptSubmit** | When user submits new prompt | Hero.aiff | Indicates command received |
| **PermissionRequest** | When Claude requests permission | Ping.aiff | Waiting for authorization |
| **Notification (permission_prompt)** | When Claude needs permission | Ping.aiff | Permission request notification |
| **Notification (idle_prompt)** | When Claude waits for input | Glass.aiff | Idle waiting notification |
| **Stop** | When Claude completes response | Hero.aiff | Indicates task completion |

### Notification Events Details

The Notification event includes multiple sub-types, and this project supports two of them:

- **permission_prompt** - Triggered when Claude needs user authorization to perform certain operations
- **idle_prompt** - Triggered when Claude waits for user input for more than 60 seconds

### Claude Code All Hook Events Reference

According to the official documentation, Claude Code supports the following 10 hook events:

1. **PreToolUse** - Runs before tool calls (supports matcher)
2. **PermissionRequest** - Runs when permission dialog is shown (supports matcher)
3. **PostToolUse** - Runs after successful tool completion (supports matcher) ✅ *Supported*
4. **Notification** - Runs when notifications are sent (supports matcher)
   - `permission_prompt` - Permission requests ✅ *Supported*
   - `idle_prompt` - Waiting for user input (60+ seconds idle) ✅ *Supported*
   - `auth_success` - Authentication success
   - `elicitation_dialog` - MCP tool input needed
5. **UserPromptSubmit** - Runs when user submits prompt ✅ *Supported*
6. **Stop** - Runs when main agent completes response ✅ *Supported*
7. **SubagentStop** - Runs when subagent completes response
8. **PreCompact** - Runs before compact operation
9. **SessionStart** - Runs when starting or resuming session
10. **SessionEnd** - Runs when session ends

> 💡 Tip: You can configure sound notifications for other hook events as needed. See [Claude Code Official Documentation](https://code.claude.com/docs/en/hooks) for details

### Test Notification Sounds

The installation script directly configures sound commands in Claude Code's settings.json. You can manually execute the following commands to test different notification sound effects.

#### macOS

```bash
# Test Glass sound (crisp glass sound)
afplay /System/Library/Sounds/Glass.aiff

# Test Hero sound (hero entrance)
afplay /System/Library/Sounds/Hero.aiff

# Test Ping sound (clear notification ping)
afplay /System/Library/Sounds/Ping.aiff

# Test Basso sound (low notification sound)
afplay /System/Library/Sounds/Basso.aiff

# Test Funk sound (funky sound effect)
afplay /System/Library/Sounds/Funk.aiff
```

#### Linux

```bash
# Test system terminal bell
echo -e "\a"

# Test PulseAudio sound (requires paplay)
paplay /usr/share/sounds/freedesktop/stereo/complete.oga

# Test ALSA sound (requires aplay)
aplay /usr/share/sounds/alsa/Front_Center.wav
```

#### Windows (Git Bash/MSYS2/WSL)

```bash
# Test standard beep (800Hz, 200ms)
powershell.exe -Command "[console]::beep(800,200)"

# Test high pitch beep (1000Hz, 150ms)
powershell.exe -Command "[console]::beep(1000,150)"

# Test high frequency beep (1200Hz, 100ms)
powershell.exe -Command "[console]::beep(1200,100)"

# Test double beep
powershell.exe -Command "[console]::beep(800,100); [console]::beep(1200,100)"
```

## ⚙️ Custom Configuration

### Changing Notification Sounds

There are two ways to change notification sounds:

#### Method 1: Re-run the Installation Script (Recommended)

```bash
# Re-download or use existing script
./install-claude-sounds.sh

# Choose interactive configuration, then select new notification sounds
```

This will automatically update your settings.json configuration.

#### Method 2: Manually Edit settings.json

Edit `~/.claude/settings.json` and modify the `command` field for the corresponding hook.

**macOS Example**:
```json
{
  "hooks": {
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
}
```

**macOS System Sounds Location**:
```bash
ls /System/Library/Sounds/*.aiff
```

**Available macOS System Sounds**:
- `Glass.aiff` - Crisp glass sound (default)
- `Hero.aiff` - Hero entrance effect
- `Ping.aiff` - Clear notification ping
- `Basso.aiff` - Low notification sound
- `Funk.aiff` - Stylish effect
- `Purr.aiff` - Purring sound
- `Sosumi.aiff` - Classic Mac sound

**Supported Audio Formats**:
- AIFF, MP3, WAV, M4A
- Other formats supported by `afplay`

**Linux Example**:
```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "paplay /usr/share/sounds/freedesktop/stereo/complete.oga"
          }
        ]
      }
    ]
  }
}
```

**Linux Sound Playback Methods**:
1. **System terminal bell**: `echo -e "\a"`
2. **PulseAudio**: `paplay /usr/share/sounds/freedesktop/stereo/complete.oga`
3. **ALSA**: `aplay /usr/share/sounds/alsa/Front_Center.wav`

**List Available System Sounds**:
```bash
ls /usr/share/sounds/freedesktop/stereo/
```

**Windows Example**:
```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "powershell.exe -Command \"[console]::beep(800,200)\""
          }
        ]
      }
    ]
  }
}
```

**Windows PowerShell Beep Parameters**:
- Command format: `powershell.exe -Command "[console]::beep(frequency, duration)"`
- Frequency range: 37 - 32767 Hz
- Duration unit: milliseconds

**Windows Sound Examples**:
```bash
# Low pitch notification
powershell.exe -Command "[console]::beep(400, 300)"

# High pitch notification
powershell.exe -Command "[console]::beep(1500, 100)"

# Double beep notification
powershell.exe -Command "[console]::beep(800, 100); [console]::beep(1200, 100)"
```

## 📁 Project Structure

```
ClaudeSound/
├── README.md                 # Project description (Chinese)
├── README_EN.md             # Project description (English)
├── LICENSE                  # MIT License
├── .gitignore              # Git ignore file
├── install-claude-sounds.sh # One-click installation script
├── docs/                    # Documentation directory
│   ├── 配置指南.md          # Detailed configuration document (Chinese)
│   ├── BUGFIX_NOTES.md      # Bug fix records
│   └── ...                  # Other documentation
└── test/                    # Test and development files
    ├── install-claude-sounds-v2.sh  # v2 version script
    ├── install-claude-sounds-v4.sh  # v4 version script
    └── ...                  # Other test files
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
            "command": "afplay /System/Library/Sounds/Glass.aiff"
          }
        ]
      },
      {
        "matcher": "Edit",
        "hooks": [
          {
            "type": "command",
            "command": "afplay /System/Library/Sounds/Hero.aiff"
          }
        ]
      }
    ]
  }
}
```

> 💡 Tip: Linux users replace `afplay` with `paplay`, `aplay`, or `echo -e "\a"`. Windows users use `powershell.exe -Command "[console]::beep(800,200)"`

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
            "command": "afplay /System/Library/Sounds/Glass.aiff"
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

> 💡 Tip: Linux and Windows users should use the corresponding sound commands for their platform

## ❓ FAQ

### 1. No Sound

#### macOS
Check the following:
- [ ] System volume is turned on
- [ ] Command path in settings.json is correct
- [ ] Test audio file directly with `afplay` command

#### Linux
Check the following:
- [ ] System volume is turned on
- [ ] Terminal bell is enabled
- [ ] Try other sound playback methods (paplay, aplay, etc.)

**Enable terminal bell:**
```bash
# Edit ~/.inputrc or /etc/inputrc
set bell-style audible
```

#### Windows (Git Bash/MSYS2/WSL)
Check the following:
- [ ] System volume is turned on
- [ ] PowerShell is available
- [ ] Test directly in PowerShell: `[console]::beep(800, 200)`

### 2. Hook Not Triggering

Confirm the following:
- [ ] `settings.json` file location is correct (must be in `~/.claude/` directory)
- [ ] JSON format is correct
- [ ] Hook event name is correct
- [ ] Claude Code has been restarted

### 3. Verify Commands Work Correctly

If sound commands are not executing, verify:
- macOS: Run `afplay /System/Library/Sounds/Glass.aiff` directly in terminal
- Linux: Run `echo -e "\a"` or `paplay ...` directly in terminal
- Windows: Run `[console]::beep(800, 200)` directly in PowerShell

### 4. View Supported Hook Events

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
