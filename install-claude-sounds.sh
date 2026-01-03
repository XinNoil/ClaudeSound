#!/bin/bash
#
# Claude Code 声音提示配置 - 一键安装脚本
# 版本: 1.0.0
# 适用于 macOS 系统
# 项目主页: https://github.com/yourusername/claude-code-sounds
#

set -e  # 遇到错误立即退出

# 版本信息
VERSION="1.0.0"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# 打印信息函数
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo ""
    echo -e "${CYAN}============================================${NC}"
    echo -e "${CYAN}$1${NC}"
    echo -e "${CYAN}============================================${NC}"
    echo ""
}

# 显示欢迎信息
print_header "Claude Code 声音提示配置 v${VERSION}"
echo -e "本项目为 Claude Code 添加声音提示功能"
echo -e "项目主页: https://github.com/yourusername/claude-code-sounds"
echo ""

# 检查系统
print_info "检查系统..."
if [[ "$OSTYPE" != "darwin"* ]]; then
    print_error "此脚本仅适用于 macOS 系统"
    exit 1
fi
print_success "系统检查通过 (macOS)"

# 检查 afplay 命令是否可用
print_info "检查 afplay 命令..."
if ! command -v afplay &> /dev/null; then
    print_error "afplay 命令不可用，请确认系统正常"
    exit 1
fi
print_success "afplay 命令可用"

# 创建必要的目录
print_info "创建必要的目录..."
mkdir -p "$HOME/.local/bin"
print_success "目录创建完成"

# 创建任务完成提示音脚本
print_info "创建任务完成提示音脚本..."
cat > "$HOME/.local/bin/claude-task-done.sh" << 'EOF'
#!/bin/bash
# 任务完成时播放的提示音
afplay /System/Library/Sounds/Glass.aiff
EOF
chmod +x "$HOME/.local/bin/claude-task-done.sh"
print_success "任务完成提示音脚本创建完成"

# 创建用户提交提示音脚本
print_info "创建用户提交提示音脚本..."
cat > "$HOME/.local/bin/claude-user-prompt.sh" << 'EOF'
#!/bin/bash
# 用户提交提示时播放的提示音
afplay /System/Library/Sounds/Hero.aiff
EOF
chmod +x "$HOME/.local/bin/claude-user-prompt.sh"
print_success "用户提交提示音脚本创建完成"

# 创建用户询问提示音脚本
print_info "创建用户询问提示音脚本..."
cat > "$HOME/.local/bin/claude-ask-user.sh" << 'EOF'
#!/bin/bash
# Claude 向用户询问时播放的提示音
afplay /System/Library/Sounds/Ping.aiff
EOF
chmod +x "$HOME/.local/bin/claude-ask-user.sh"
print_success "用户询问提示音脚本创建完成"

# 处理配置文件
SETTINGS_DIR="$HOME/.claude"
SETTINGS_FILE="$SETTINGS_DIR/settings.json"
BACKUP_FILE="$SETTINGS_DIR/settings.json.backup"

print_info "处理配置文件..."

# 创建 .claude 目录（如果不存在）
mkdir -p "$SETTINGS_DIR"

# 检查是否已存在配置文件
if [ -f "$SETTINGS_FILE" ]; then
    print_warning "检测到已存在的 settings.json 文件"

    # 创建备份
    if [ -f "$BACKUP_FILE" ]; then
        timestamp=$(date +%Y%m%d_%H%M%S)
        cp "$SETTINGS_FILE" "$SETTINGS_DIR/settings.json.backup.$timestamp"
        print_info "已创建带时间戳的备份: settings.json.backup.$timestamp"
    else
        cp "$SETTINGS_FILE" "$BACKUP_FILE"
        print_info "已创建备份: settings.json.backup"
    fi

    # 检查 jq 是否安装
    if command -v jq &> /dev/null; then
        print_info "使用 jq 合并配置..."

        # 检查是否已存在 hooks 配置
        if jq -e '.hooks' "$SETTINGS_FILE" > /dev/null 2>&1; then
            print_warning "配置文件中已存在 hooks 配置，跳过添加"
            print_info "如需更新，请手动编辑 $SETTINGS_FILE"
        else
            # 添加 hooks 配置
            jq '.hooks = {
                "PostToolUse": [
                    {
                        "matcher": "",
                        "hooks": [
                            {
                                "type": "command",
                                "command": "'"$HOME"'/.local/bin/claude-task-done.sh"
                            }
                        ]
                    }
                ],
                "UserPromptSubmit": [
                    {
                        "matcher": "",
                        "hooks": [
                            {
                                "type": "command",
                                "command": "'"$HOME"'/.local/bin/claude-user-prompt.sh"
                            }
                        ]
                    }
                ],
                "PermissionRequest": [
                    {
                        "matcher": "",
                        "hooks": [
                            {
                                "type": "command",
                                "command": "'"$HOME"'/.local/bin/claude-ask-user.sh"
                            }
                        ]
                    }
                ]
            }' "$SETTINGS_FILE" > "$SETTINGS_FILE.tmp" && mv "$SETTINGS_FILE.tmp" "$SETTINGS_FILE"
            print_success "hooks 配置已添加到现有配置文件"
        fi
    else
        print_warning "jq 未安装，无法自动合并配置"
        print_info "请手动将以下内容添加到 $SETTINGS_FILE 中："
        echo ""
        echo '{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "'"$HOME"'/.local/bin/claude-task-done.sh"
          }
        ]
      }
    ],
    "UserPromptSubmit": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "'"$HOME"'/.local/bin/claude-user-prompt.sh"
          }
        ]
      }
    ],
    "PermissionRequest": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "'"$HOME"'/.local/bin/claude-ask-user.sh"
          }
        ]
      }
    ]
  }
}'
        echo ""
        print_info "提示: 安装 jq 后重新运行脚本可自动合并配置"
        print_info "安装命令: brew install jq"
    fi
else
    print_info "创建新的配置文件..."

    # 创建完整的配置文件（使用绝对路径）
    cat > "$SETTINGS_FILE" << EOF
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "$HOME/.local/bin/claude-task-done.sh"
          }
        ]
      }
    ],
    "UserPromptSubmit": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "$HOME/.local/bin/claude-user-prompt.sh"
          }
        ]
      }
    ],
    "PermissionRequest": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "$HOME/.local/bin/claude-ask-user.sh"
          }
        ]
      }
    ]
  }
}
EOF
    print_success "配置文件创建完成"
fi

# 测试提示音
echo ""
print_info "是否要测试提示音？(y/n)"
read -r response

if [[ "$response" =~ ^[Yy]$ ]]; then
    print_info "播放任务完成提示音..."
    afplay /System/Library/Sounds/Glass.aiff
    print_success "任务完成提示音测试完成"

    print_info "播放用户提交提示音..."
    afplay /System/Library/Sounds/Hero.aiff
    print_success "用户提交提示音测试完成"

    print_info "播放用户询问提示音..."
    afplay /System/Library/Sounds/Ping.aiff
    print_success "用户询问提示音测试完成"
fi

# 完成
print_header "安装完成！"
print_success "Claude Code 声音提示配置完成！"
echo ""
echo -e "${CYAN}配置文件位置：${NC}"
echo "  - 脚本目录: $HOME/.local/bin/"
echo "  - 配置文件: $SETTINGS_FILE"
if [ -f "$BACKUP_FILE" ]; then
    echo "  - 备份文件: $BACKUP_FILE"
fi
echo ""
echo -e "${YELLOW}⚠️  请重启 Claude Code 以使配置生效${NC}"
echo ""
print_info "使用 /hooks 命令可以查看所有支持的 Hook 事件"
echo ""
echo -e "${CYAN}如有问题，请访问:${NC}"
echo "  https://github.com/yourusername/claude-code-sounds/issues"
echo ""
echo -e "${GREEN}感谢使用 Claude Code 声音提示配置！${NC}"
echo ""
