#!/usr/bin/env zsh
#
# Claude Code 声音提示配置 - 基于测试版本重写
# 版本: 3.1.0
# 适用于 macOS/Linux/Windows 系统
# 项目主页: https://github.com/XinNoil/claude-code-sounds
#

# 注意：交互式脚本不使用 set -e，因为它会导致 read 命令的非零返回码终止脚本

# 版本信息
VERSION="3.1.0"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# ============================================
# 数据结构定义
# ============================================

# 平台音效配置（关联数组）
declare -A PLATFORM_SOUNDS=(
    ["macos_task_done"]="afplay /System/Library/Sounds/Glass.aiff"
    ["macos_user_prompt"]="afplay /System/Library/Sounds/Hero.aiff"
    ["macos_ask_user"]="afplay /System/Library/Sounds/Ping.aiff"
    ["macos_permission_prompt"]="afplay /System/Library/Sounds/Ping.aiff"
    ["macos_idle_prompt"]="afplay /System/Library/Sounds/Ping.aiff"
    ["macos_stop"]="afplay /System/Library/Sounds/Ping.aiff"
    ["linux_task_done"]="echo -e \"\\a\""
    ["linux_user_prompt"]="echo -e \"\\a\""
    ["linux_ask_user"]="echo -e \"\\a\""
    ["linux_permission_prompt"]="echo -e \"\\a\""
    ["linux_idle_prompt"]="echo -e \"\\a\""
    ["linux_stop"]="echo -e \"\\a\""
    ["windows_task_done"]="powershell.exe -Command \"[console]::beep(800, 200)\""
    ["windows_user_prompt"]="powershell.exe -Command \"[console]::beep(1000, 150)\""
    ["windows_ask_user"]="powershell.exe -Command \"[console]::beep(1200, 100)\""
    ["windows_permission_prompt"]="powershell.exe -Command \"[console]::beep(1200, 100)\""
    ["windows_idle_prompt"]="powershell.exe -Command \"[console]::beep(800, 200)\""
    ["windows_stop"]="powershell.exe -Command \"[console]::beep(1000, 150)\""
)

# 钩子事件定义
declare -A HOOK_EVENTS=(
    ["task_done"]="PostToolUse"
    ["user_prompt"]="UserPromptSubmit"
    ["ask_user"]="PermissionRequest"
    ["permission_prompt"]="Notification:permission_prompt"
    ["idle_prompt"]="Notification:idle_prompt"
    ["stop"]="Stop"
)

# 钩子描述（用于交互式菜单）
declare -A HOOK_DESCRIPTIONS=(
    ["task_done"]="任务完成提示音"
    ["user_prompt"]="用户提交提示音"
    ["ask_user"]="用户询问提示音"
    ["permission_prompt"]="权限请求提示音"
    ["idle_prompt"]="空闲等待提示音"
    ["stop"]="任务停止提示音"
)

# 钩子启用状态（默认全部启用）
declare -A HOOK_ENABLED=(
    ["task_done"]=1
    ["user_prompt"]=1
    ["ask_user"]=1
    ["permission_prompt"]=1
    ["idle_prompt"]=1
    ["stop"]=1
)

# 用户选择的声音（空值表示使用默认）
declare -A HOOK_SOUND_CHOICES=(
    ["task_done"]=""
    ["user_prompt"]=""
    ["ask_user"]=""
    ["permission_prompt"]=""
    ["idle_prompt"]=""
    ["stop"]=""
)

# 钩子当前铃声索引（用于左右键切换）
declare -A HOOK_SOUND_INDEX=(
    ["task_done"]=0
    ["user_prompt"]=0
    ["ask_user"]=0
    ["permission_prompt"]=0
    ["idle_prompt"]=0
    ["stop"]=0
)

# 可用铃声列表（用于交互式选择）
declare -A AVAILABLE_SOUNDS=(
    ["macos"]="Glass|Hero|Ping|Basso|Funk|Purr|Sosumi"
    ["linux"]="System Bell|paplay|aplay"
    ["windows"]="Beep(800,200)|Beep(1000,150)|Beep(1200,100)"
)

# ============================================
# 工具函数
# ============================================

# 检测操作系统
detect_os() {
    case "$(uname -s)" in
        Darwin*)
            echo "macos"
            ;;
        Linux*)
            echo "linux"
            ;;
        MINGW*|MSYS*|CYGWIN*)
            echo "windows"
            ;;
        *)
            echo "unknown"
            ;;
    esac
}

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

# 检测是否在交互式终端中运行
is_interactive() {
    [ -t 0 ]
}

# ============================================
# 核心函数
# ============================================

# 切换到上一个铃声
cycle_prev_sound() {
    local hook_name="$1"
    local sounds="${AVAILABLE_SOUNDS[$OS]}"
    local sound_array=("${(@s/|/)sounds}")
    local total_sounds=${#sound_array[@]}

    local current_index="${HOOK_SOUND_INDEX[$hook_name]}"
    local new_index=$((current_index - 1))

    if [ $new_index -lt 0 ]; then
        new_index=$((total_sounds - 1))  # 循环到最后一个
    fi

    HOOK_SOUND_INDEX[$hook_name]=$new_index

    # 应用新的铃声选择
    local selected_sound="${sound_array[$new_index + 1]}"
    local sound_cmd=""

    case "$OS" in
        macos)
            sound_cmd="afplay /System/Library/Sounds/${selected_sound}.aiff"
            ;;
        linux)
            if [ "$selected_sound" = "System Bell" ]; then
                sound_cmd="echo -e \"\\a\""
            elif [ "$selected_sound" = "paplay" ]; then
                sound_cmd="paplay /usr/share/sounds/freedesktop/stereo/complete.oga"
            elif [ "$selected_sound" = "aplay" ]; then
                sound_cmd="aplay /usr/share/sounds/alsa/Front_Center.wav"
            fi
            ;;
        windows)
            sound_cmd="powershell.exe -Command \"[console]::beep(${selected_sound})\""
            ;;
    esac

    HOOK_SOUND_CHOICES[$hook_name]="$sound_cmd"

    # 立即播放铃声试听
    eval "$sound_cmd" 2>/dev/null &
}

# 切换到下一个铃声
cycle_next_sound() {
    local hook_name="$1"
    local sounds="${AVAILABLE_SOUNDS[$OS]}"
    local sound_array=("${(@s/|/)sounds}")
    local total_sounds=${#sound_array[@]}

    local current_index="${HOOK_SOUND_INDEX[$hook_name]}"
    local new_index=$((current_index + 1))

    if [ $new_index -ge $total_sounds ]; then
        new_index=0  # 循环到第一个
    fi

    HOOK_SOUND_INDEX[$hook_name]=$new_index

    # 应用新的铃声选择
    local selected_sound="${sound_array[$new_index + 1]}"
    local sound_cmd=""

    case "$OS" in
        macos)
            sound_cmd="afplay /System/Library/Sounds/${selected_sound}.aiff"
            ;;
        linux)
            if [ "$selected_sound" = "System Bell" ]; then
                sound_cmd="echo -e \"\\a\""
            elif [ "$selected_sound" = "paplay" ]; then
                sound_cmd="paplay /usr/share/sounds/freedesktop/stereo/complete.oga"
            elif [ "$selected_sound" = "aplay" ]; then
                sound_cmd="aplay /usr/share/sounds/alsa/Front_Center.wav"
            fi
            ;;
        windows)
            sound_cmd="powershell.exe -Command \"[console]::beep(${selected_sound})\""
            ;;
    esac

    HOOK_SOUND_CHOICES[$hook_name]="$sound_cmd"

    # 立即播放铃声试听
    eval "$sound_cmd" 2>/dev/null &
}

# ============================================
# 交互式菜单函数（基于 test-final.sh）
# ============================================

# 显示交互式配置菜单（完全基于 test-final.sh 的结构）
show_interactive_menu() {
    print_info "进入交互式菜单..."
    echo ""

    # 清空输入缓冲区
    echo "步骤 1: 清空输入缓冲区"
    local dummy=""
    local count=0
    while read -t 0.1 -k 1 dummy 2>/dev/null; do
        ((count++))
    done
    echo "  清空了 $count 个残留字符"
    echo ""

    # 获取可用铃声列表
    local sounds="${AVAILABLE_SOUNDS[$OS]}"
    local sound_array=("${(@s/|/)sounds}")
    local total_sounds=${#sound_array[@]}

    # 钩子列表和当前选择
    local hook_names=(task_done user_prompt ask_user permission_prompt idle_prompt stop)
    local total_hooks=6
    local current_selection=0  # 当前选中的钩子索引 (0-5)

    # 交互式菜单循环
    echo "步骤 2: 进入菜单循环（按 q 退出）"
    echo ""

    # 完全按照 test-final.sh 的结构
    while true; do
        printf "\033[H\033[J"  # 清屏

        print_header "Claude Code 声音提示配置 v${VERSION} - 交互式配置"
        echo -e "${CYAN}当前操作系统: ${OS}${NC}"
        echo ""

        print_info "步骤 1/1: 配置声音通知"
        echo ""
        echo "使用 ↑↓ 键移动，回车切换启用/禁用，左右键切换铃声，q 键退出完成"
        echo ""

        # 显示所有钩子
        local i=0
        while [ $i -lt $total_hooks ]; do
            local hook_name="${hook_names[$i + 1]}"

            # 获取启用/禁用状态文本
            local status_text="[✓ 启用]"
            if [ "${HOOK_ENABLED[$hook_name]}" -eq 0 ]; then
                status_text="[✗ 禁用]"
            fi

            # 显示当前选中项的箭头
            if [ $i -eq $current_selection ]; then
                echo -e "\033[1;33m→${NC} ${status_text} ${HOOK_DESCRIPTIONS[$hook_name]} - ${sound_array[$((HOOK_SOUND_INDEX[$hook_name] + 1))]} ($((HOOK_SOUND_INDEX[$hook_name] + 1))/${total_sounds})"
            else
                echo "  ${status_text} ${HOOK_DESCRIPTIONS[$hook_name]} - ${sound_array[$((HOOK_SOUND_INDEX[$hook_name] + 1))]} ($((HOOK_SOUND_INDEX[$hook_name] + 1))/${total_sounds})"
            fi

            ((i++))
        done

        echo ""
        echo -e "${CYAN}按 q 键完成配置并继续${NC}"
        echo ""

        # 读取按键 - 完全按照 test-final.sh 的方式
        local input=""
        read -rsk1 input 2>/dev/null || input=""

        # 处理按键
        case $input in
            A)  # 上键
                if [ $current_selection -gt 0 ]; then
                    ((current_selection--))
                else
                    current_selection=$((total_hooks - 1))
                fi
                ;;
            B)  # 下键
                if [ $current_selection -lt $((total_hooks - 1)) ]; then
                    ((current_selection++))
                else
                    current_selection=0
                fi
                ;;
            D)  # 左键
                local selected_hook="${hook_names[$current_selection + 1]}"
                cycle_prev_sound "$selected_hook"
                ;;
            C)  # 右键
                local selected_hook="${hook_names[$current_selection + 1]}"
                cycle_next_sound "$selected_hook"
                ;;
            "")  # 回车键 - 切换启用/禁用
                local selected_hook="${hook_names[$current_selection + 1]}"
                if [ "${HOOK_ENABLED[$selected_hook]}" -eq 1 ]; then
                    HOOK_ENABLED[$selected_hook]=0
                else
                    HOOK_ENABLED[$selected_hook]=1
                fi
                ;;
            q|Q)  # q 键完成配置
                break
                ;;
        esac
    done

    echo ""
    print_success "交互式配置完成！"
    sleep 1
}

# ============================================
# 主流程
# ============================================

# 显示欢迎信息
print_header "Claude Code 声音提示配置 v${VERSION}"
echo -e "本项目为 Claude Code 添加声音提示功能"
echo -e "项目主页: https://github.com/XinNoil/claude-code-sounds"
echo ""

# 检测操作系统
OS=$(detect_os)
if [ "$OS" = "unknown" ]; then
    print_error "不支持的操作系统"
    exit 1
fi
print_info "检测到操作系统: $OS"

# 询问是否使用交互式配置
echo ""
print_info "是否使用交互式配置？(y/n，默认: n)"
if ! is_interactive; then
    print_warning "非交互式环境，跳过交互式配置"
    use_interactive="n"
else
    read -r use_interactive || use_interactive="n"
fi

if [[ "$use_interactive" =~ ^[Yy]$ ]]; then
    if is_interactive; then
        show_interactive_menu
    else
        print_warning "检测到非交互式环境，无法使用交互式配置"
        print_info "使用默认配置（所有通知启用，默认声音）"
    fi
else
    print_info "使用默认配置（所有通知启用，默认声音）"
fi

# 创建必要的目录
print_info "创建必要的目录..."
mkdir -p "$HOME/.local/bin"
print_success "目录创建完成"

# 生成所有脚本
echo ""
print_info "生成声音提示脚本..."
for hook_name in ${(k)HOOK_EVENTS}; do
    local sound_key="${OS}_${hook_name}"
    local sound_cmd="${PLATFORM_SOUNDS[$sound_key]}"
    local script_file="$HOME/.local/bin/claude-${hook_name}.sh"

    # 如果钩子未启用，跳过
    if [ "${HOOK_ENABLED[$hook_name]}" -eq 0 ]; then
        continue
    fi

    # 检查是否自定义了声音
    if [ -n "${HOOK_SOUND_CHOICES[$hook_name]}" ]; then
        sound_cmd="${HOOK_SOUND_CHOICES[$hook_name]}"
    fi

    # 生成脚本
    cat > "$script_file" << EOF
#!/bin/bash
# ${HOOK_DESCRIPTIONS[$hook_name]} - (${OS})
# 钩子事件: ${HOOK_EVENTS[$hook_name]}

$sound_cmd
EOF

    chmod +x "$script_file"
done
print_success "声音提示脚本生成完成"

# 完成
print_header "安装完成！"
print_success "Claude Code 声音提示配置完成！"
echo ""
echo -e "${CYAN}配置文件位置：${NC}"
echo "  - 脚本目录: $HOME/.local/bin/"
echo "  - 操作系统: $OS"
echo ""
echo -e "${YELLOW}⚠️  请重启 Claude Code 以使配置生效${NC}"
echo ""
print_info "使用 /hooks 命令可以查看所有支持的 Hook 事件"
echo ""
echo -e "${CYAN}如有问题，请访问:${NC}"
echo "  https://github.com/XinNoil/claude-code-sounds/issues"
echo ""
echo -e "${GREEN}感谢使用 Claude Code 声音提示配置！${NC}"
echo ""
