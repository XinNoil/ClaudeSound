#!/usr/bin/env zsh
#
# Claude Code 声音提示配置 - 修复版
# 版本: 3.1.2
# 修复：正确处理 settings.json 格式，避免 JSON 格式错误
#

# 版本信息
VERSION="3.1.2"

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

# 打印带颜色的消息
print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_info() {
    echo -e "${CYAN}ℹ $1${NC}"
}

print_header() {
    echo ""
    echo -e "${BLUE}═══════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}  $1${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════${NC}"
    echo ""
}

# 检测操作系统
detect_os() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        OS="macos"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        OS="linux"
    elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
        OS="windows"
    else
        print_error "不支持的操作系统: $OSTYPE"
        exit 1
    fi
}

# 播放声音
play_sound() {
    local hook_name="$1"

    case "$OS" in
        macos)
            local sounds="${AVAILABLE_SOUNDS[$OS]}"
            local sound_array=("${(@s/|/)sounds}")
            local sound_index="${HOOK_SOUND_INDEX[$hook_name]}"
            local selected_sound="${sound_array[$sound_index + 1]}"

            afplay "/System/Library/Sounds/${selected_sound}.aiff" 2>/dev/null &
            ;;
        linux)
            local sounds="${AVAILABLE_SOUNDS[$OS]}"
            local sound_array=("${(@s/|/)sounds}")
            local sound_index="${HOOK_SOUND_INDEX[$hook_name]}"
            local selected_sound="${sound_array[$sound_index + 1]}"

            if [ "$selected_sound" = "System Bell" ]; then
                echo -e "\a"
            elif [ "$selected_sound" = "paplay" ]; then
                paplay /usr/share/sounds/freedesktop/stereo/complete.oga 2>/dev/null &
            elif [ "$selected_sound" = "aplay" ]; then
                aplay /usr/share/sounds/alsa/Front_Center.wav 2>/dev/null &
            fi
            ;;
        windows)
            local sounds="${AVAILABLE_SOUNDS[$OS]}"
            local sound_array=("${(@s/|/)sounds}")
            local sound_index="${HOOK_SOUND_INDEX[$hook_name]}"
            local selected_sound="${sound_array[$sound_index + 1]}"

            # 解析频率和时长，例如 "Beep(800,200)"
            if [[ "$selected_sound" =~ "Beep\(([0-9]+),([0-9]+)\)" ]]; then
                local freq=$match[1]
                local duration=$match[2]
                powershell.exe -Command "[console]::beep(${freq},${duration})" 2>/dev/null &
            fi
            ;;
    esac
}

# ============================================
# Hooks 配置生成
# ============================================

# 生成单个 hook 配置
generate_hook_entry() {
    local hook_name="$1"
    local sound_cmd="${HOOK_SOUND_COMMANDS[$hook_name]}"

    # 如果没有指定命令，生成默认命令
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
                    sound_cmd="echo -e \"\\\\a\""
                elif [ "$selected_sound" = "paplay" ]; then
                    sound_cmd="paplay /usr/share/sounds/freedesktop/stereo/complete.oga"
                elif [ "$selected_sound" = "aplay" ]; then
                    sound_cmd="aplay /usr/share/sounds/alsa/Front_Center.wav"
                fi
                ;;
            windows)
                if [[ "$selected_sound" =~ "Beep\(([0-9]+),([0-9]+)\)" ]]; then
                    local freq=$match[1]
                    local duration=$match[2]
                    sound_cmd="powershell.exe -Command \"[console]::beep(${freq},${duration})\""
                fi
                ;;
        esac
    fi

    # 输出 JSON 格式的 hook 配置
    cat <<EOF
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "${sound_cmd}"
          }
        ]
      }
EOF
}

# 生成 hooks 配置
generate_hooks_config() {
    local config_json=""
    local first_hook=1

    # PostToolUse (task_done)
    if [ "${HOOK_ENABLED[task_done]}" -eq 1 ]; then
        config_json+=$'\n'
        config_json+='    "PostToolUse": ['
        config_json+=$'\n'
        config_json+="      $(generate_hook_entry task_done)"
        config_json+=$'\n'
        config_json+="    ],"
    fi

    # UserPromptSubmit (user_prompt)
    if [ "${HOOK_ENABLED[user_prompt]}" -eq 1 ]; then
        config_json+=$'\n'
        config_json+='    "UserPromptSubmit": ['
        config_json+=$'\n'
        config_json+="      $(generate_hook_entry user_prompt)"
        config_json+=$'\n'
        config_json+="    ],"
    fi

    # PermissionRequest (permission_prompt, idle_prompt)
    if [ "${HOOK_ENABLED[permission_prompt]}" -eq 1 ] || [ "${HOOK_ENABLED[idle_prompt]}" -eq 1 ]; then
        config_json+=$'\n'
        config_json+='    "PermissionRequest": ['

        local permission_hooks=""
        if [ "${HOOK_ENABLED[permission_prompt]}" -eq 1 ]; then
            permission_hooks+=$'\n'
            permission_hooks+='      {'
            permission_hooks+=$'\n'
            permission_hooks+='        "matcher": "",'
            permission_hooks+=$'\n'
            permission_hooks+='        "hooks": ['
            permission_hooks+=$'\n'
            permission_hooks+="          $(generate_hook_entry permission_prompt | sed '2,/^$/s/^      /          /')"
            permission_hooks+=$'\n'
            permission_hooks+='        ]'
            permission_hooks+=$'\n'
            permission_hooks+='      }'
        fi

        if [ "${HOOK_ENABLED[idle_prompt]}" -eq 1 ]; then
            if [ -n "$permission_hooks" ]; then
                permission_hooks+=","
            fi
            permission_hooks+=$'\n'
            permission_hooks+='      {'
            permission_hooks+=$'\n'
            permission_hooks+='        "matcher": "idle_prompt",'
            permission_hooks+=$'\n'
            permission_hooks+='        "hooks": ['
            permission_hooks+=$'\n'
            permission_hooks+="          $(generate_hook_entry idle_prompt | sed '2,/^$/s/^      /          /')"
            permission_hooks+=$'\n'
            permission_hooks+='        ]'
            permission_hooks+=$'\n'
            permission_hooks+='      }'
        fi

        permission_hooks+=$'\n'
        permission_hooks+='    ]'

        config_json+="$permission_hooks,"

        # 如果没有启用任何 PermissionRequest hook，移除逗号
        if [ "${HOOK_ENABLED[permission_prompt]}" -eq 0 ] && [ "${HOOK_ENABLED[idle_prompt]}" -eq 0 ]; then
            config_json="${config_json%,}"
        fi
    fi

    # Stop (stop)
    if [ "${HOOK_ENABLED[stop]}" -eq 1 ]; then
        config_json+=$'\n'
        config_json+='    "Stop": ['
        config_json+=$'\n'
        config_json+="      $(generate_hook_entry stop)"
        config_json+=$'\n'
        config_json+="    ],"
    fi

    # Notification (permission_prompt matcher, idle_prompt matcher)
    if [ "${HOOK_ENABLED[permission_prompt]}" -eq 1 ] || [ "${HOOK_ENABLED[idle_prompt]}" -eq 1 ]; then
        config_json+=$'\n'
        config_json+='    "Notification": ['

        local notification_hooks=""
        if [ "${HOOK_ENABLED[permission_prompt]}" -eq 1 ]; then
            notification_hooks+=$'\n'
            notification_hooks+='      {'
            notification_hooks+=$'\n'
            notification_hooks+='        "matcher": "permission_prompt",'
            notification_hooks+=$'\n'
            notification_hooks+='        "hooks": ['
            notification_hooks+=$'\n'
            notification_hooks+="          $(generate_hook_entry permission_prompt | sed '2,/^$/s/^      /          /')"
            notification_hooks+=$'\n'
            notification_hooks+='        ]'
            notification_hooks+=$'\n'
            notification_hooks+='      }'
        fi

        if [ "${HOOK_ENABLED[idle_prompt]}" -eq 1 ]; then
            if [ -n "$notification_hooks" ]; then
                notification_hooks+=","
            fi
            notification_hooks+=$'\n'
            notification_hooks+='      {'
            notification_hooks+=$'\n'
            notification_hooks+='        "matcher": "idle_prompt",'
            notification_hooks+=$'\n'
            notification_hooks+='        "hooks": ['
            notification_hooks+=$'\n'
            notification_hooks+="          $(generate_hook_entry idle_prompt | sed '2,/^$/s/^      /          /')"
            notification_hooks+=$'\n'
            notification_hooks+='        ]'
            notification_hooks+=$'\n'
            notification_hooks+='      }'
        fi

        notification_hooks+=$'\n'
        notification_hooks+='    ]'

        config_json+="$notification_hooks"

        # 移除前面的逗号
        config_json="${config_json%,}"
    fi

    # 移除末尾的逗号
    config_json="${config_json%,}"

    echo "$config_json"
}

# ============================================
# 配置文件写入
# ============================================

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
            # 使用更可靠的方法：移除最后的 } 及其前面的空白，然后添加新配置
            local backup_file="${settings_file}.backup.$(date +%Y%m%d%H%M%S)"
            cp "$settings_file" "$backup_file"
            print_info "已备份原配置到: $backup_file"

            # 使用 Python 或 jq 来处理 JSON（如果可用），否则使用改进的 sed 方法
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
# 交互式菜单
# ============================================

# 显示钩子配置菜单
show_hook_menu() {
    clear
    print_header "Claude Code 声音提示配置 v${VERSION}"

    echo -e "${CYAN}已启用的提示音:${NC}"
    echo ""

    local hook_names=("task_done" "user_prompt" "ask_user" "permission_prompt" "idle_prompt" "stop")
    local display_index=1

    for hook_name in "${hook_names[@]}"; do
        local sounds="${AVAILABLE_SOUNDS[$OS]}"
        local sound_array=("${(@s/|/)sounds}")
        local sound_index="${HOOK_SOUND_INDEX[$hook_name]}"
        local selected_sound="${sound_array[$sound_index + 1]}"
        local description="${HOOK_DESCRIPTIONS[$hook_name]}"

        local hook_status=""
        if [ "${HOOK_ENABLED[$hook_name]}" -eq 1 ]; then
            hook_status="${GREEN}✓${NC}"
        else
            hook_status="${RED}✗${NC}"
        fi

        printf "  ${display_index}. [%s] %s - %s\n" "$hook_status" "$description" "$selected_sound"

        HOOK_MENU_INDEX[$display_index]=$hook_name
        ((display_index++))
    done

    echo ""
    echo -e "${CYAN}操作:${NC}"
    echo "  1-6) 切换对应的提示音开关"
    echo "  ←/→) 切换选中提示音的铃声"
    echo "  a) 全部启用"
    echo "  n) 全部禁用"
    echo "  t) 试听当前铃声"
    echo "  s) 保存配置并退出"
    echo "  q) 不保存直接退出"
    echo ""
}

# 主交互式配置
interactive_config() {
    local current_selection=1
    local total_hooks=6

    while true; do
        show_hook_menu
        echo -e "${YELLOW}请选择操作 (1-6/箭头键/a/n/t/s/q):${NC} "

        # 读取单个字符
        local key
        read -k1 key

        case "$key" in
            [1-6])
                # 切换 hook 启用状态
                local hook_index=$((key))
                local hook_name="${HOOK_MENU_INDEX[$hook_index]}"
                if [ "${HOOK_ENABLED[$hook_name]}" -eq 1 ]; then
                    HOOK_ENABLED[$hook_name]=0
                    print_info "已禁用: ${HOOK_DESCRIPTIONS[$hook_name]}"
                else
                    HOOK_ENABLED[$hook_name]=1
                    print_success "已启用: ${HOOK_DESCRIPTIONS[$hook_name]}"
                fi
                sleep 1
                ;;
            a|A)
                # 全部启用
                for hook_name in task_done user_prompt ask_user permission_prompt idle_prompt stop; do
                    HOOK_ENABLED[$hook_name]=1
                done
                print_success "已全部启用"
                sleep 1
                ;;
            n|N)
                # 全部禁用
                for hook_name in task_done user_prompt ask_user permission_prompt idle_prompt stop; do
                    HOOK_ENABLED[$hook_name]=0
                done
                print_success "已全部禁用"
                sleep 1
                ;;
            t|T)
                # 试听当前铃声
                print_info "试听当前选中提示音的铃声..."
                play_sound "${HOOK_MENU_INDEX[$current_selection]}"
                sleep 1
                ;;
            s|S)
                # 保存配置
                write_settings_json
                print_success "配置已保存"
                return 0
                ;;
            q|Q)
                # 退出不保存
                print_warning "配置未保存"
                return 1
                ;;
            $'\x1b')  # ESC sequence (arrow keys)
                # 读取后续两个字符
                read -k1 -t 1 key1
                read -k1 -t 1 key2

                if [[ "$key1" == "[" ]]; then
                    case "$key2" in
                        A)  # Up arrow - move selection up
                            if [ $current_selection -gt 1 ]; then
                                ((current_selection--))
                            fi
                            ;;
                        B)  # Down arrow - move selection down
                            if [ $current_selection -lt $total_hooks ]; then
                                ((current_selection++))
                            fi
                            ;;
                        D)  # Left arrow - previous sound
                            local hook_name="${HOOK_MENU_INDEX[$current_selection]}"
                            cycle_prev_sound "$hook_name"
                            play_sound "$hook_name"
                            sleep 1
                            ;;
                        C)  # Right arrow - next sound
                            local hook_name="${HOOK_MENU_INDEX[$current_selection]}"
                            cycle_next_sound "$hook_name"
                            play_sound "$hook_name"
                            sleep 1
                            ;;
                    esac
                fi
                ;;
        esac
    done
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
}

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
}

# ============================================
# 主程序
# ============================================

main() {
    # 检测操作系统
    detect_os

    # 运行交互式配置
    if interactive_config; then
        echo ""
        print_success "配置完成！"
        echo ""
        print_info "Claude Code 现在将在以下事件播放声音提示:"

        for hook_name in task_done user_prompt ask_user permission_prompt idle_prompt stop; do
            if [ "${HOOK_ENABLED[$hook_name]}" -eq 1 ]; then
                local description="${HOOK_DESCRIPTIONS[$hook_name]}"
                print_success "  • $description"
            fi
        done

        echo ""
        print_info "要重新配置，请再次运行此脚本。"
        print_info "要恢复原始配置，请使用备份文件: ~/.claude/settings.json.backup.*"
    else
        echo ""
        print_warning "配置已取消"
    fi
}

# 运行主程序
main "$@"
