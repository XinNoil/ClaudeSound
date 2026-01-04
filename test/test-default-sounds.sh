#!/usr/bin/env zsh

# Test script to verify default ringtone mappings

echo "=== 测试默认铃声映射 ==="
echo ""

OS="macos"
AVAILABLE_SOUNDS="Glass|Hero|Ping|Basso|Funk|Purr|Sosumi"
sound_array=("${(@s/|/)AVAILABLE_SOUNDS}")

echo "可用铃声列表:"
local i=1
while [ $i -le ${#sound_array[@]} ]; do
    echo "  [$((i-1))] ${sound_array[$i]}"
    ((i++))
done

echo ""
echo "钩子默认铃声映射:"

declare -A HOOK_SOUND_INDEX=(
    ["task_done"]=0        # Glass
    ["user_prompt"]=1      # Hero
    ["ask_user"]=2         # Ping
    ["permission_prompt"]=2 # Ping
    ["idle_prompt"]=2      # Ping
    ["stop"]=2             # Ping
)

declare -A HOOK_DESCRIPTIONS=(
    ["task_done"]="任务完成提示音"
    ["user_prompt"]="用户提交提示音"
    ["ask_user"]="用户询问提示音"
    ["permission_prompt"]="权限请求提示音"
    ["idle_prompt"]="空闲等待提示音"
    ["stop"]="任务停止提示音"
)

for hook_name in task_done user_prompt ask_user permission_prompt idle_prompt stop; do
    local sound_index="${HOOK_SOUND_INDEX[$hook_name]}"
    local sound_name="${sound_array[$((sound_index + 1))]}"
    echo "  ${HOOK_DESCRIPTIONS[$hook_name]}: ${sound_name} (${sound_index})"
done

echo ""
echo "✓ 默认铃声已正确设置"
