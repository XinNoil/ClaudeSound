#!/usr/bin/env zsh
#
# Claude Code 声音提示配置 - 一键安装脚本（优化版）
# 版本: 3.0.0
# 适用于 macOS/Linux/Windows 系统
# 项目主页: https://github.com/XinNoil/claude-code-sounds
#

set -e  # 遇到错误立即退出

# 版本信息
VERSION="3.0.0"

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
    ["macos_idle_prompt"]="afplay /System/Library/Sounds/Glass.aiff"
    ["macos_stop"]="afplay /System/Library/Sounds/Hero.aiff"

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

# 钩子详细描述（用于显示）
declare -A HOOK_DETAIL_DESCRIPTIONS=(
    ["task_done"]="Claude执行工具操作后"
    ["user_prompt"]="用户提交新的提示时"
    ["ask_user"]="Claude请求权限时"
    ["permission_prompt"]="Claude请求权限时（Notification事件）"
    ["idle_prompt"]="Claude等待用户输入时（闲置60+秒）"
    ["stop"]="Claude任务完成响应时"
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

# ============================================
# 核心函数
# ============================================

# 生成声音脚本
generate_sound_script() {
    local hook_name="$1"
    local sound_cmd="$2"
    local platform="$3"
    local script_file="$HOME/.local/bin/claude-${hook_name}.sh"

    # 如果钩子未启用，跳过
    if [ "${HOOK_ENABLED[$hook_name]}" -eq 0 ]; then
        return 0
    fi

    # 检查是否自定义了声音
    if [ -n "${HOOK_SOUND_CHOICES[$hook_name]}" ]; then
        sound_cmd="${HOOK_SOUND_CHOICES[$hook_name]}"
    fi

    # 生成脚本
    print_info "创建 ${HOOK_DESCRIPTIONS[$hook_name]} 脚本..."

    cat > "$script_file" << EOF
#!/bin/bash
# ${HOOK_DESCRIPTIONS[$hook_name]} - ${HOOK_DETAIL_DESCRIPTIONS[$hook_name]} (${platform})
# 钩子事件: ${HOOK_EVENTS[$hook_name]}

$sound_cmd
EOF

    chmod +x "$script_file"
    print_success "${HOOK_DESCRIPTIONS[$hook_name]} 脚本创建完成"
}

# 为指定平台生成所有脚本
generate_all_scripts() {
    local platform="$1"

    print_info "配置 ${platform} 版本..."

    # 平台特定检查
    case "$platform" in
        macos)
            if ! command -v afplay &> /dev/null; then
                print_error "afplay 命令不可用，请确认系统正常"
                exit 1
            fi
            print_success "afplay 命令可用"
            ;;
        linux)
            print_info "使用系统提示音"
            ;;
        windows)
            print_info "使用 PowerShell beep 命令"
            ;;
    esac

    for hook_name in "${!HOOK_EVENTS[@]}"; do
        local sound_key="${platform}_${hook_name}"
        local sound_cmd="${PLATFORM_SOUNDS[$sound_key]}"
        generate_sound_script "$hook_name" "$sound_cmd" "$platform"
    done
}

# 生成单个钩子的 JSON 配置
generate_hook_json() {
    local hook_event="$1"
    local hook_script="$2"
    local matcher="$3"

    if [ -n "$matcher" ]; then
        cat << JSON
      {
        "matcher": "$matcher",
        "hooks": [
          {
            "type": "command",
            "command": "$hook_script"
          }
        ]
      }
JSON
    else
        cat << JSON
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "$hook_script"
          }
        ]
      }
JSON
    fi
}

# 生成完整的 hooks 配置 JSON（用于 jq 合并）
generate_hooks_config_for_jq() {
    local config_content=""
    local first_hook=true

    # 收集非 Notification 钩子
    for hook_name in "${!HOOK_EVENTS[@]}"; do
        if [ "${HOOK_ENABLED[$hook_name]}" -eq 0 ]; then
            continue
        fi

        local hook_event="${HOOK_EVENTS[$hook_name]}"

        # 跳过 Notification 类型的钩子（稍后处理）
        if [[ "$hook_event" == Notification:* ]]; then
            continue
        fi

        local hook_script="$HOME/.local/bin/claude-${hook_name}.sh"

        if [ "$first_hook" = true ]; then
            first_hook=false
        else
            config_content+=","
        fi

        config_content+="
    \"$hook_event\": [
      {
        \"matcher\": \"\",
        \"hooks\": [
          {
            \"type\": \"command\",
            \"command\": \"$hook_script\"
          }
        ]
      }
    ]"
    done

    # 收集 Notification 钩子
    local notification_items=()
    for hook_name in "${!HOOK_EVENTS[@]}"; do
        if [ "${HOOK_ENABLED[$hook_name]}" -eq 0 ]; then
            continue
        fi

        local hook_event="${HOOK_EVENTS[$hook_name]}"

        if [[ "$hook_event" == Notification:* ]]; then
            notification_items+=("$hook_name")
        fi
    done

    # 如果有 Notification 钩子，添加到配置
    if [ ${#notification_items[@]} -gt 0 ]; then
        if [ "$first_hook" = false ]; then
            config_content+=","
        fi

        config_content+="
    \"Notification\": ["

        local first_notif=true
        for hook_name in "${notification_items[@]}"; do
            local hook_event="${HOOK_EVENTS[$hook_name]}"
            local matcher="${hook_event#*:}"
            local hook_script="$HOME/.local/bin/claude-${hook_name}.sh"

            if [ "$first_notif" = false ]; then
                config_content+=","
            fi

            config_content+="
      {
        \"matcher\": \"$matcher\",
        \"hooks\": [
          {
            \"type\": \"command\",
            \"command\": \"$hook_script\"
          }
        ]
      }"

            first_notif=false
        done

        config_content+="
    ]"
    fi

    echo "{$config_content
}"
}

# 测试提示音
test_notification_sounds() {
    print_info "测试已启用的提示音..."
    echo ""

    for hook_name in "${!HOOK_EVENTS[@]}"; do
        if [ "${HOOK_ENABLED[$hook_name]}" -eq 0 ]; then
            continue
        fi

        local sound_key="${OS}_${hook_name}"
        local sound_cmd="${PLATFORM_SOUNDS[$sound_key]}"

        # 使用自定义声音（如果有）
        if [ -n "${HOOK_SOUND_CHOICES[$hook_name]}" ]; then
            sound_cmd="${HOOK_SOUND_CHOICES[$hook_name]}"
        fi

        print_info "播放 ${HOOK_DESCRIPTIONS[$hook_name]}..."
        eval "$sound_cmd"
        sleep 0.3
    done

    echo ""
    print_success "提示音测试完成"
}

# ============================================
# 交互式菜单函数
# ============================================

# 显示声音选项
show_sound_options() {
    local hook_name="$1"
    local sounds="${AVAILABLE_SOUNDS[$OS]}"
    local i=1

    echo "  0. 使用默认声音"

    IFS='|' read -ra sound_array <<< "$sounds"
    for sound in "${sound_array[@]}"; do
        echo "  ${i}. ${sound}"
        ((i++))
    done
}

# 应用声音选择
apply_sound_choice() {
    local hook_name="$1"
    local choice="$2"
    local sounds="${AVAILABLE_SOUNDS[$OS]}"

    if [ "$choice" = "0" ]; then
        HOOK_SOUND_CHOICES[$hook_name]=""
        return
    fi

    IFS='|' read -ra sound_array <<< "$sounds"
    local idx=$((choice - 1))

    if [ $idx -ge 0 ] && [ $idx -lt ${#sound_array[@]} ]; then
        local selected_sound="${sound_array[$idx]}"
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
        print_success "已选择: ${selected_sound}"
    else
        print_error "无效的选择"
    fi
}

# 显示交互式配置菜单
show_interactive_menu() {
    clear
    print_header "Claude Code 声音提示配置 v${VERSION} - 交互式配置"

    echo -e "${CYAN}当前操作系统: ${OS}${NC}"
    echo ""

    # 步骤 1: 选择要启用的钩子
    while true; do
        clear
        print_header "Claude Code 声音提示配置 v${VERSION} - 交互式配置"
        echo -e "${CYAN}当前操作系统: ${OS}${NC}"
        echo ""

        print_info "步骤 1/2: 选择要启用的声音通知"
        echo ""
        echo "输入钩子编号来切换启用/禁用状态，或按 Enter 继续:"
        echo ""

        local hook_names=(task_done user_prompt ask_user permission_prompt idle_prompt stop)
        local i=1

        for hook_name in "${hook_names[@]}"; do
            local hook_status="${GREEN}[✓ 启用]${NC}"
            if [ "${HOOK_ENABLED[$hook_name]}" -eq 0 ]; then
                hook_status="${RED}[✗ 禁用]${NC}"
            fi
            echo "  ${i}. ${hook_status} ${HOOK_DESCRIPTIONS[$hook_name]} (${HOOK_DETAIL_DESCRIPTIONS[$hook_name]})"
            ((i++))
        done

        echo ""
        echo -n "选择 (1-6, 或 Enter 继续): "
        read -r selection

        if [ -z "$selection" ]; then
            break
        fi

        if [[ "$selection" =~ ^[1-6]$ ]]; then
            local idx=$((selection - 1))
            local selected_hook="${hook_names[$idx]}"

            if [ "${HOOK_ENABLED[$selected_hook]}" -eq 1 ]; then
                HOOK_ENABLED[$selected_hook]=0
                print_info "已禁用: ${HOOK_DESCRIPTIONS[$selected_hook]}"
            else
                HOOK_ENABLED[$selected_hook]=1
                print_success "已启用: ${HOOK_DESCRIPTIONS[$selected_hook]}"
            fi

            sleep 1
        else
            print_warning "无效的选择，请输入 1-6 或按 Enter 继续"
            sleep 1
        fi
    done

    # 步骤 2: 为每个启用的钩子选择声音
    print_info "步骤 2/2: 为每个钩子选择声音"
    echo ""

    for hook_name in "${hook_names[@]}"; do
        if [ "${HOOK_ENABLED[$hook_name]}" -eq 0 ]; then
            continue
        fi

        echo ""
        echo -e "${CYAN}${HOOK_DESCRIPTIONS[$hook_name]}${NC} - ${HOOK_DETAIL_DESCRIPTIONS[$hook_name]}"
        echo ""
        show_sound_options "$hook_name"
        echo ""
        echo -n "输入声音编号或按 Enter 使用默认: "
        read -r sound_choice

        if [ -n "$sound_choice" ]; then
            apply_sound_choice "$hook_name" "$sound_choice"
        fi
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
read -r use_interactive

if [[ "$use_interactive" =~ ^[Yy]$ ]]; then
    show_interactive_menu
else
    print_info "使用默认配置（所有通知启用，默认声音）"
fi

# 创建必要的目录
print_info "创建必要的目录..."
mkdir -p "$HOME/.local/bin"
print_success "目录创建完成"

# 生成所有脚本
echo ""
generate_all_scripts "$OS"

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
            # 生成 hooks 配置
            local hooks_config=$(generate_hooks_config_for_jq)

            # 添加 hooks 配置
            jq ".hooks = $hooks_config" "$SETTINGS_FILE" > "$SETTINGS_FILE.tmp" && mv "$SETTINGS_FILE.tmp" "$SETTINGS_FILE"
            print_success "hooks 配置已添加到现有配置文件"
        fi
    else
        print_warning "jq 未安装，无法自动合并配置"
        print_info "请手动将以下内容添加到 $SETTINGS_FILE 中："
        echo ""
        generate_hooks_config_for_jq
        echo ""
        print_info "提示: 安装 jq 后重新运行脚本可自动合并配置"
        if [ "$OS" = "macos" ]; then
            print_info "安装命令: brew install jq"
        elif [ "$OS" = "linux" ]; then
            print_info "安装命令: sudo apt-get install jq  # Debian/Ubuntu"
            print_info "          或: sudo yum install jq     # RHEL/CentOS"
        fi
    fi
else
    print_info "创建新的配置文件..."

    # 生成完整的配置文件
    cat > "$SETTINGS_FILE" << EOF
{
  "hooks": {
$(generate_hooks_config_for_jq | sed '1d;$d')
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
    test_notification_sounds
fi

# 完成
print_header "安装完成！"
print_success "Claude Code 声音提示配置完成！"
echo ""
echo -e "${CYAN}配置文件位置：${NC}"
echo "  - 脚本目录: $HOME/.local/bin/"
echo "  - 配置文件: $SETTINGS_FILE"
echo "  - 操作系统: $OS"
if [ -f "$BACKUP_FILE" ]; then
    echo "  - 备份文件: $BACKUP_FILE"
fi
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
