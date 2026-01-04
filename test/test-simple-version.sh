#!/usr/bin/env zsh

# 简化版交互式菜单（使用普通 read 命令）

clear
print_header "Claude Code 声音提示配置 v3.0.0 - 交互式配置（简化版）"

echo -e "${CYAN}当前操作系统: macos${NC}"
echo ""

print_info "步骤 1/1: 配置声音通知"
echo ""
echo "操作说明："
echo "  1-6: 选择并切换对应钩子的启用/禁用状态"
echo "  ←: 左箭头键切换到上一个铃声"
echo "  →: 右箭头键切换到下一个铃声"
echo "  0 或 Enter: 完成配置"
echo "  q: 退出并使用默认配置"
echo ""

# 钩子列表
local hook_names=(task_done user_prompt ask_user permission_prompt idle_prompt stop)
local hook_descriptions=(
    "任务完成提示音 (Claude执行工具操作后)"
    "用户提交提示音 (用户提交新的提示时)"
    "用户询问提示音 (Claude请求权限时)"
    "权限请求提示音 (Claude请求权限时（Notification事件）)"
    "空闲等待提示音 (Claude等待用户输入时（闲置60+秒）)"
    "任务停止提示音 (Claude任务完成响应时)"
)

# 可用铃声
local sounds="Glass|Hero|Ping|Basso|Funk|Purr|Sosumi"
local sound_array=("${(@s/|/)sounds}")
local total_sounds=${#sound_array[@]}

# 铃声索引数组
local -A sound_index=(
    task_done=0 user_prompt=0 ask_user=0 permission_prompt=0 idle_prompt=0 stop=0
)

while true; do
    clear
    print_header "Claude Code 声音提示配置 v3.0.0 - 交互式配置（简化版）"
    echo -e "${CYAN}当前操作系统: macos${NC}"
    echo ""
    print_info "步骤 1/1: 配置声音通知"
    echo ""
    echo "操作说明："
    echo "  1-6: 选择并切换对应钩子的启用/禁用状态"
    echo "  ←: 左箭头键切换到上一个铃声"
    echo "  →: 右箭头键切换到下一个铃声"
    echo "  0 或 Enter: 完成配置"
    echo "  q: 退出并使用默认配置"
    echo ""

    # 显示所有钩子
    local i=1
    while [ $i -le 6 ]; do
        local hook_name="${hook_names[$i]}"
        local desc="${hook_descriptions[$i]}"

        # 显示启用/禁用状态
        local hook_status="${GREEN}[✓ 启用]${NC}"
        if [ "${HOOK_ENABLED[$hook_name]}" -eq 0 ]; then
            hook_status="${RED}[✗ 禁用]${NC}"
        fi

        # 显示当前铃声
        local idx="${sound_index[$hook_name]}"
        local current_sound="${sound_array[$idx + 1]}"
        local display_idx=$((idx + 1))

        echo "  ${i}. ${hook_status} ${desc} - ${current_sound} (${display_idx}/${total_sounds})"
        ((i++))
    done

    echo ""
    echo -n "选择 (1-6/←→/0/Enter/q): "

    # 使用普通 read 命令读取输入
    local input=""
    read -r input

    case "$input" in
        [1-6])
            # 切换启用/禁用
            local idx=$((input))
            local hook_name="${hook_names[$idx]}"
            if [ "${HOOK_ENABLED[$hook_name]}" -eq 1 ]; then
                HOOK_ENABLED[$hook_name]=0
                print_success "已禁用: ${hook_descriptions[$idx]}"
            else
                HOOK_ENABLED[$hook_name]=1
                print_success "已启用: ${hook_descriptions[$idx]}"
            fi
            sleep 0.5
            ;;
        0|'')
            # 完成配置
            break
            ;;
        q|Q)
            # 退出
            echo ""
            print_info "取消配置，使用默认设置"
            exit 0
            ;;
        $'\e[D'|$'\e'[D|$'\e'[D'|←)
            # 左箭头键（使用备用方法：输入 L）
            # 实际上 zsh 中很难捕获方向键，所以我们用字母代替
            print_warning "请使用小写 l (左) 和 r (右) 来切换铃声"
            sleep 1
            ;;
        *)
            # 其他输入
            if [ "$input" = "l" ]; then
                # 左：切换到上一个铃声
                local idx=1
                while [ $idx -le 6 ]; do
                    local hook_name="${hook_names[$idx]}"
                    local current_idx="${sound_index[$hook_name]}"
                    local new_idx=$((current_idx - 1))
                    if [ $new_idx -lt 0 ]; then
                        new_idx=$((total_sounds - 1))
                    fi
                    sound_index[$hook_name]=$new_idx
                    ((idx++))
                done
                print_success "所有铃声已切换到上一个"
                sleep 0.5
            elif [ "$input" = "r" ]; then
                # 右：切换到下一个铃声
                local idx=1
                while [ $idx -le 6 ]; do
                    local hook_name="${hook_names[$idx]}"
                    local current_idx="${sound_index[$hook_name]}"
                    local new_idx=$((current_idx + 1))
                    if [ $new_idx -ge $total_sounds ]; then
                        new_idx=0
                    fi
                    sound_index[$hook_name]=$new_idx
                    ((idx++))
                done
                print_success "所有铃声已切换到下一个"
                sleep 0.5
            else
                print_warning "无效的选择: $input"
                sleep 0.5
            fi
            ;;
    esac
done

echo ""
print_success "交互式配置完成！"
sleep 1
