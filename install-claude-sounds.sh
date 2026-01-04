#!/usr/bin/env zsh
#
# Claude Code 声音提示配置 - 修复版
# 版本: 3.1.1
# 修复：回车键切换和默认铃声
#

# 版本信息
VERSION="3.1.1"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# ============================================
# 数据结构定义
# ============================================

# 可用铃声列表
declare -A AVAILABLE_SOUNDS=(
    ["macos"]="Glass|Hero|Ping|Basso|Funk|Purr|Sosumi"
    ["linux"]="System Bell|paplay|aplay"
    ["windows"]="Beep(800,200)|Beep(1000,150)|Beep(1200,100)"
)

# 钩子描述
declare -A HOOK_DESCRIPTIONS=(
    ["task_done"]="工具调用提示音"
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

# 钩子当前铃声索引（根据 PLATFORM_SOUNDS 设置默认值）
# macOS 可用铃声: Glass(0) Hero(1) Ping(2) Basso(3) Funk(4) Purr(5) Sosumi(6)
declare -A HOOK_SOUND_INDEX=(
    ["task_done"]=0        # Glass
    ["user_prompt"]=1      # Hero
    ["ask_user"]=2         # Ping
    ["permission_prompt"]=2 # Ping
    ["idle_prompt"]=2      # Ping
    ["stop"]=2             # Ping
)

# 用户选择的声音命令
declare -A HOOK_SOUND_COMMANDS=(
    ["task_done"]=""
    ["user_prompt"]=""
    ["ask_user"]=""
    ["permission_prompt"]=""
    ["idle_prompt"]=""
    ["stop"]=""
)

# ============================================
# 辅助函数
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
        new_index=$((total_sounds - 1))
    fi

    HOOK_SOUND_INDEX[$hook_name]=$new_index

    # 生成声音命令
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

    HOOK_SOUND_COMMANDS[$hook_name]="$sound_cmd"

    # 试听铃声
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
        new_index=0
    fi

    HOOK_SOUND_INDEX[$hook_name]=$new_index

    # 生成声音命令
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

    HOOK_SOUND_COMMANDS[$hook_name]="$sound_cmd"

    # 试听铃声
    eval "$sound_cmd" 2>/dev/null &
}

# 试听当前铃声
preview_sound() {
    local hook_name="$1"
    local sounds="${AVAILABLE_SOUNDS[$OS]}"
    local sound_array=("${(@s/|/)sounds}")
    local sound_index="${HOOK_SOUND_INDEX[$hook_name]}"
    local selected_sound="${sound_array[$sound_index + 1]}"
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

    # 试听铃声
    eval "$sound_cmd" 2>/dev/null &
}

# ============================================
# 工具函数
# ============================================

detect_os() {
    case "$(uname -s)" in
        Darwin*) echo "macos" ;;
        Linux*) echo "linux" ;;
        MINGW*|MSYS*|CYGWIN*) echo "windows" ;;
        *) echo "unknown" ;;
    esac
}

print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_header() {
    echo ""
    echo -e "${CYAN}============================================${NC}"
    echo -e "${CYAN}$1${NC}"
    echo -e "${CYAN}============================================${NC}"
    echo ""
}

is_interactive() {
    [ -t 0 ]
}

# ============================================
# 配置生成和写入
# ============================================

# 生成 settings.json 的 hooks 配置
generate_hooks_config() {
    local config_json=""
    local notification_hooks=""

    # 遍历所有钩子
    for hook_name in task_done user_prompt ask_user permission_prompt idle_prompt stop; do
        # 如果该钩子未启用，跳过
        if [ "${HOOK_ENABLED[$hook_name]}" -eq 0 ]; then
            continue
        fi

        # 获取声音命令
        local sound_cmd="${HOOK_SOUND_COMMANDS[$hook_name]}"

        # 如果声音命令为空，生成默认命令
        if [ -z "$sound_cmd" ]; then
            local sounds="${AVAILABLE_SOUNDS[$OS]}"
            local sound_array=("${(@s/|/)sounds}")
            local sound_index="${HOOK_SOUND_INDEX[$hook_name]}"
            local selected_sound="${sound_array[$sound_index + 1]}"

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
        fi

        # 根据钩子名称处理
        case "$hook_name" in
            task_done)
                config_json+="
    \"PostToolUse\": [
      {
        \"matcher\": \"\",
        \"hooks\": [
          {
            \"type\": \"command\",
            \"command\": \"${sound_cmd}\"
          }
        ]
      }
    ],"
                ;;
            user_prompt)
                config_json+="
    \"UserPromptSubmit\": [
      {
        \"matcher\": \"\",
        \"hooks\": [
          {
            \"type\": \"command\",
            \"command\": \"${sound_cmd}\"
          }
        ]
      }
    ],"
                ;;
            ask_user)
                config_json+="
    \"PermissionRequest\": [
      {
        \"matcher\": \"\",
        \"hooks\": [
          {
            \"type\": \"command\",
            \"command\": \"${sound_cmd}\"
          }
        ]
      }
    ],"
                ;;
            permission_prompt)
                notification_hooks+="
      {
        \"matcher\": \"permission_prompt\",
        \"hooks\": [
          {
            \"type\": \"command\",
            \"command\": \"${sound_cmd}\"
          }
        ]
      },"
                ;;
            idle_prompt)
                notification_hooks+="
      {
        \"matcher\": \"idle_prompt\",
        \"hooks\": [
          {
            \"type\": \"command\",
            \"command\": \"${sound_cmd}\"
          }
        ]
      },"
                ;;
            stop)
                config_json+="
    \"Stop\": [
      {
        \"matcher\": \"\",
        \"hooks\": [
          {
            \"type\": \"command\",
            \"command\": \"${sound_cmd}\"
          }
        ]
      }
    ],"
                ;;
        esac
    done

    # 添加 Notification 钩子（如果有）
    if [ -n "$notification_hooks" ]; then
        # 移除末尾的逗号
        notification_hooks="${notification_hooks%,}"
        config_json+="
    \"Notification\": [${notification_hooks}
    ],"
    fi

    # 移除末尾的逗号
    config_json="${config_json%,}"

    echo "$config_json"
}

# 写入配置到 settings.json
write_settings_json() {
    local settings_file="$HOME/.claude/settings.json"
    local hooks_config="$(generate_hooks_config)"

    # 确保目录存在
    mkdir -p "$(dirname "$settings_file")"

    # 如果文件不存在，创建新文件
    if [ ! -f "$settings_file" ]; then
        cat > "$settings_file" <<EOF
{
  "hooks": {
${hooks_config}
  }
}
EOF
        print_success "已创建配置文件: $settings_file"
    else
        # 文件存在，需要合并 hooks 配置
        print_info "更新现有配置文件: $settings_file"

        # 读取现有配置
        local existing_content=$(cat "$settings_file")

        # 使用临时文件
        local temp_file=$(mktemp)

        # 检查是否已有 hooks 字段
        if echo "$existing_content" | grep -q '"hooks"'; then
            # 已有 hooks，需要提示用户手动合并或使用备份
            local backup_file="${settings_file}.backup.$(date +%Y%m%d%H%M%S)"
            cp "$settings_file" "$backup_file"
            print_info "已备份原配置到: $backup_file"

            # 创建新的配置文件（包含原配置和新 hooks）
            print_info "现有的 settings.json 包含 hooks 配置。"
            print_info "为了安全起见，请手动合并以下配置到你的 settings.json:"
            echo ""
            echo "--- 配置内容 ---"
            echo "{"
            echo "  \"hooks\": {"
            echo "$hooks_config"
            echo "  }"
            echo "}"
            echo "--- 配置内容 ---"
            echo ""
            echo "或者直接替换整个 hooks 字段。"
            return 0
        else
            # 没有 hooks，直接添加
            # 使用更可靠的方法处理JSON格式
            local backup_file="${settings_file}.backup.$(date +%Y%m%d%H%M%S)"
            cp "$settings_file" "$backup_file"
            print_info "已备份原配置到: $backup_file"

            # 使用 Python 来处理 JSON（如果可用），否则使用改进的 sed 方法
            if command -v python3 &> /dev/null; then
                python3 -c "
import json
import sys

# 读取现有配置
with open('${settings_file}', 'r') as f:
    config = json.load(f)

# 添加 hooks 配置
hooks_json = '''{
${hooks_config}
}'''

# 解析 hooks 配置
hooks = json.loads(hooks_json)
config['hooks'] = hooks

# 写回文件
with open('${settings_file}', 'w') as f:
    json.dump(config, f, indent=2)
"
                print_success "已更新配置文件: $settings_file"
            elif command -v jq &> /dev/null; then
                # 使用 jq 添加 hooks 字段
                local hooks_json="{\"hooks\": {${hooks_config}}}"
                jq --argjson hooks "$hooks_json" '. + $hooks' "$settings_file" > "$temp_file"
                mv "$temp_file" "$settings_file"
                print_success "已更新配置文件: $settings_file"
            else
                # 使用改进的 sed 方法
                # 删除最后的 } 及其前面的所有空白字符（包括换行和空格）
                local new_content=$(echo "$existing_content" | sed -e :a -e '/\n.*}$/!{N;ba;}' -e 's/[[:space:]]*}$//')

                # 写入新内容
                echo "$new_content" > "$temp_file"
                echo "," >> "$temp_file"
                echo "  \"hooks\": {" >> "$temp_file"
                echo "$hooks_config" >> "$temp_file"
                echo "  }" >> "$temp_file"
                echo "}" >> "$temp_file"

                mv "$temp_file" "$settings_file"
                print_success "已更新配置文件: $settings_file"
            fi
        fi
    fi

    echo ""
    print_info "配置的 hooks:"
    for hook_name in task_done user_prompt ask_user permission_prompt idle_prompt stop; do
        if [ "${HOOK_ENABLED[$hook_name]}" -eq 1 ]; then
            # 生成声音命令（如果为空）
            local sound_cmd="${HOOK_SOUND_COMMANDS[$hook_name]}"
            if [ -z "$sound_cmd" ]; then
                local sounds="${AVAILABLE_SOUNDS[$OS]}"
                local sound_array=("${(@s/|/)sounds}")
                local sound_index="${HOOK_SOUND_INDEX[$hook_name]}"
                local selected_sound="${sound_array[$sound_index + 1]}"

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
            fi
            printf "  ✓ %s: %s\n" "${HOOK_DESCRIPTIONS[$hook_name]}" "$sound_cmd"
        fi
    done
}

# ============================================
# 交互式菜单（修复版）
# ============================================

show_interactive_menu() {
    print_info "进入交互式菜单..."
    echo ""

    # 清空输入缓冲区
    local dummy=""
    local count=0
    while read -t 0.1 -k 1 dummy 2>/dev/null; do
        ((count++))
    done
    [ $count -gt 0 ] && echo "  清空了 $count 个残留字符" || echo "  缓冲区为空"
    echo ""

    # 获取可用铃声列表
    local sounds="${AVAILABLE_SOUNDS[$OS]}"
    local sound_array=("${(@s/|/)sounds}")
    local total_sounds=${#sound_array[@]}

    # 钩子列表
    local hook_names=(task_done user_prompt ask_user permission_prompt idle_prompt stop)
    local total_hooks=6
    local current_selection=0

    echo "步骤 2: 进入菜单循环（按 q 退出）"
    echo ""

    # 主循环
    while true; do
        printf "\033[H\033[J"  # 清屏

        print_header "Claude Code 声音提示配置 v${VERSION} - 交互式配置"
        echo -e "${CYAN}当前操作系统: ${OS}${NC}"
        echo ""

        print_info "步骤 1/1: 配置声音通知"
        echo ""
        echo "使用 ↑↓ 键移动，回车切换启用/禁用，左右键切换铃声，空格试听，q 键退出完成"
        echo ""

        # 显示所有钩子
        local i=0
        while [ $i -lt $total_hooks ]; do
            local hook_name="${hook_names[$i + 1]}"

            # 获取启用/禁用状态
            local status_text="${GREEN}[✓ 启用]${NC}"
            if [ "${HOOK_ENABLED[$hook_name]}" -eq 0 ]; then
                status_text="${RED}[✗ 禁用]${NC}"
            fi

            # 获取当前铃声（索引从 0 开始，所以直接用索引）
            local sound_index="${HOOK_SOUND_INDEX[$hook_name]}"
            local current_sound="${sound_array[$sound_index + 1]}"
            local display_index=$((sound_index + 1))

            # 显示
            if [ $i -eq $current_selection ]; then
                echo -e "\033[1;33m→${NC} ${status_text} ${HOOK_DESCRIPTIONS[$hook_name]} - ${current_sound} (${display_index}/${total_sounds})"
            else
                echo "  ${status_text} ${HOOK_DESCRIPTIONS[$hook_name]} - ${current_sound} (${display_index}/${total_sounds})"
            fi

            ((i++))
        done

        echo ""
        echo -e "${CYAN}按 q 键完成配置并继续${NC}"
        echo ""

        # 读取按键
        local input=""
        read -rsk1 input 2>/dev/null || input=""

        # 处理按键 - 修复回车键匹配
        case "$input" in
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
            D)  # 左键 - 切换到上一个铃声
                local selected_hook="${hook_names[$current_selection + 1]}"
                cycle_prev_sound "$selected_hook"
                ;;
            C)  # 右键 - 切换到下一个铃声
                local selected_hook="${hook_names[$current_selection + 1]}"
                cycle_next_sound "$selected_hook"
                ;;
            $'\r'|$'\n')  # 回车键 - 切换启用/禁用（立即刷新）
                local selected_hook="${hook_names[$current_selection + 1]}"
                if [ "${HOOK_ENABLED[$selected_hook]}" -eq 1 ]; then
                    HOOK_ENABLED[$selected_hook]=0
                else
                    HOOK_ENABLED[$selected_hook]=1
                fi
                # 不显示任何信息，直接刷新
                ;;
            ' ')  # 空格键 - 试听当前铃声
                local selected_hook="${hook_names[$current_selection + 1]}"
                preview_sound "$selected_hook"
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
echo ""

# 检测操作系统
OS=$(detect_os)
if [ "$OS" = "unknown" ]; then
    echo -e "${RED}[ERROR]${NC} 不支持的操作系统"
    exit 1
fi
print_info "检测到操作系统: $OS"
echo ""

# 询问是否使用交互式配置
print_info "是否使用交互式配置？(y/n，默认: n)"
if ! is_interactive; then
    echo -e "${YELLOW}[WARNING]${NC} 非交互式环境，跳过交互式配置"
    use_interactive="n"
else
    read -r use_interactive || use_interactive="n"
fi
echo ""

if [[ "$use_interactive" =~ ^[Yy]$ ]]; then
    if is_interactive; then
        show_interactive_menu
    else
        echo -e "${YELLOW}[WARNING]${NC} 检测到非交互式环境，无法使用交互式配置"
    fi
else
    print_info "使用默认配置（所有通知启用，默认声音）"
fi

echo ""
print_header "写入配置到 settings.json"

# 写入配置到 settings.json
write_settings_json

echo ""
print_success "配置完成！"
echo ""
print_info "请重启 Claude Code 以使配置生效"
