#!/usr/bin/env zsh

# 测试交互式菜单的核心逻辑

echo "=== 测试交互式菜单核心逻辑 ==="
echo ""

# 设置环境以跳过主脚本执行
export AUTO_TEST_MODE=1

# 源脚本加载函数定义（模拟环境）
OS="macos"
VERSION="3.0.0"

# 定义颜色
GREEN='\033[0;32m'
RED='\033[0;31m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m'

# 定义可用声音
typeset -gA AVAILABLE_SOUNDS
AVAILABLE_SOUNDS[macos]="Glass|Hero|Ping|Basso|Funk|Purr|Sosumi"
AVAILABLE_SOUNDS[linux]="System Bell|paplay|aplay"
AVAILABLE_SOUNDS[windows]="Beep(800,200)|Beep(1000,150)|Beep(1200,100)"

# 初始化关联数组
typeset -gA HOOK_ENABLED
typeset -gA HOOK_SOUND_INDEX
typeset -gA HOOK_SOUND_CHOICES
typeset -gA HOOK_DESCRIPTIONS

# 钩子描述
HOOK_DESCRIPTIONS[task_done]="任务完成提示音 (Claude执行工具操作后)"
HOOK_DESCRIPTIONS[user_prompt]="用户提交提示音 (用户提交新的提示时)"
HOOK_DESCRIPTIONS[ask_user]="用户询问提示音 (Claude请求权限时)"
HOOK_DESCRIPTIONS[permission_prompt]="权限请求提示音 (Claude请求权限时（Notification事件）)"
HOOK_DESCRIPTIONS[idle_prompt]="空闲等待提示音 (Claude等待用户输入时（闲置60+秒）)"
HOOK_DESCRIPTIONS[stop]="任务停止提示音 (Claude任务完成响应时)"

# 初始化所有钩子为启用状态
HOOK_ENABLED[task_done]=1
HOOK_ENABLED[user_prompt]=1
HOOK_ENABLED[ask_user]=1
HOOK_ENABLED[permission_prompt]=1
HOOK_ENABLED[idle_prompt]=1
HOOK_ENABLED[stop]=1

# 初始化所有钩子的铃声索引为 0（第一个铃声）
HOOK_SOUND_INDEX[task_done]=0
HOOK_SOUND_INDEX[user_prompt]=0
HOOK_SOUND_INDEX[ask_user]=0
HOOK_SOUND_INDEX[permission_prompt]=0
HOOK_SOUND_INDEX[idle_prompt]=0
HOOK_SOUND_INDEX[stop]=0

# 加载主脚本中的函数定义
eval "$(sed -n '/^# 切换到下一个铃声$/,/^}$/p' install-claude-sounds.sh)"
eval "$(sed -n '/^# 切换到上一个铃声$/,/^}$/p' install-claude-sounds.sh)"

# 测试1: 验证函数存在
echo "测试 1: 验证函数定义"
if type cycle_prev_sound >/dev/null 2>&1; then
    echo "✓ cycle_prev_sound 函数已定义"
else
    echo "✗ cycle_prev_sound 函数未定义"
    exit 1
fi

if type cycle_next_sound >/dev/null 2>&1; then
    echo "✓ cycle_next_sound 函数已定义"
else
    echo "✗ cycle_next_sound 函数未定义"
    exit 1
fi

echo ""

# 测试2: 验证变量初始化
echo "测试 2: 验证全局变量"
echo "  OS = $OS"
echo "  VERSION = $VERSION"

# 检查关联数组
if [ "${#HOOK_ENABLED[@]}" -gt 0 ]; then
    echo "✓ HOOK_ENABLED 关联数组已初始化"
    echo "  包含的钩子: ${(@k)HOOK_ENABLED}"
else
    echo "✗ HOOK_ENABLED 关联数组未初始化"
    exit 1
fi

if [ "${#HOOK_SOUND_INDEX[@]}" -gt 0 ]; then
    echo "✓ HOOK_SOUND_INDEX 关联数组已初始化"
else
    echo "✗ HOOK_SOUND_INDEX 关联数组未初始化"
    exit 1
fi

echo ""

# 测试3: 测试铃声切换逻辑
echo "测试 3: 测试铃声切换逻辑"

# 保存原始值
local original_index="${HOOK_SOUND_INDEX[task_done]}"

echo "  原始 task_done 铃声索引: $original_index"

# 测试 cycle_next_sound
cycle_next_sound "task_done"
local new_index="${HOOK_SOUND_INDEX[task_done]}"
echo "  cycle_next_sound 后的索引: $new_index"

if [ "$new_index" -eq "$((original_index + 1))" ]; then
    echo "✓ cycle_next_sound 正常工作"
else
    echo "✗ cycle_next_sound 未按预期工作"
fi

# 测试 cycle_prev_sound
cycle_prev_sound "task_done"
local prev_index="${HOOK_SOUND_INDEX[task_done]}"
echo "  cycle_prev_sound 后的索引: $prev_index"

if [ "$prev_index" -eq "$original_index" ]; then
    echo "✓ cycle_prev_sound 正常工作（恢复到原始值）"
else
    echo "✗ cycle_prev_sound 未按预期工作"
fi

echo ""

# 测试4: 测试边界条件
echo "测试 4: 测试铃声索引边界条件"

local sounds="${AVAILABLE_SOUNDS[$OS]}"
local sound_array=("${(@s/|/)sounds}")
local total_sounds=${#sound_array[@]}

echo "  总铃声数: $total_sounds"

# 设置为最后一个铃声并测试 next
HOOK_SOUND_INDEX[task_done]=$((total_sounds - 1))
echo "  设置 task_done 为最后一个铃声 (索引 $((total_sounds - 1)))"

cycle_next_sound "task_done"
local wrapped_index="${HOOK_SOUND_INDEX[task_done]}"
echo "  cycle_next_sound 后的索引: $wrapped_index (应该回到 0)"

if [ "$wrapped_index" -eq 0 ]; then
    echo "✓ 铃声循环到开头正常工作"
else
    echo "✗ 铃声循环到开头失败"
fi

# 设置为第一个铃声并测试 prev
HOOK_SOUND_INDEX[task_done]=0
echo "  设置 task_done 为第一个铃声 (索引 0)"

cycle_prev_sound "task_done"
local wrapped_back_index="${HOOK_SOUND_INDEX[task_done]}"
echo "  cycle_prev_sound 后的索引: $wrapped_back_index (应该到 $((total_sounds - 1)))"

if [ "$wrapped_back_index" -eq "$((total_sounds - 1))" ]; then
    echo "✓ 铃声循环到末尾正常工作"
else
    echo "✗ 铃声循环到末尾失败"
fi

echo ""

# 测试5: 测试不同钩子的独立性
echo "测试 5: 测试不同钩子的铃声独立性"

# 重置所有钩子到相同索引
HOOK_SOUND_INDEX[task_done]=0
HOOK_SOUND_INDEX[user_prompt]=0
HOOK_SOUND_INDEX[ask_user]=0

echo "  所有钩子初始索引: 0"

# 只切换 task_done
cycle_next_sound "task_done"

local task_done_index="${HOOK_SOUND_INDEX[task_done]}"
local user_prompt_index="${HOOK_SOUND_INDEX[user_prompt]}"
local ask_user_index="${HOOK_SOUND_INDEX[ask_user]}"

echo "  切换 task_done 后:"
echo "    task_done 索引: $task_done_index (应该是 1)"
echo "    user_prompt 索引: $user_prompt_index (应该是 0)"
echo "    ask_user 索引: $ask_user_index (应该是 0)"

if [ "$task_done_index" -eq 1 ] && [ "$user_prompt_index" -eq 0 ] && [ "$ask_user_index" -eq 0 ]; then
    echo "✓ 不同钩子的铃声独立性正常（左右键只影响当前钩子）"
else
    echo "✗ 不同钩子的铃声独立性异常"
fi

echo ""
echo "=== 所有测试完成 ==="
echo ""
echo "说明："
echo "1. 交互式菜单要求在真实终端中运行以测试方向键输入"
echo "2. 上述测试验证了核心逻辑的正确性"
echo "3. 实际使用时请运行: ./install-claude-sounds.sh"
echo ""
echo "手动测试步骤："
echo "1. 运行 ./install-claude-sounds.sh"
echo "2. 输入 'y' 进入交互式配置"
echo "3. 测试 ↑↓ 键：观察光标（→）是否移动"
echo "4. 测试 Enter 键：观察当前选中项的启用/禁用状态是否切换"
echo "5. 测试 ←→ 键：观察当前选中项的铃声是否切换（其他项不变）"
echo "6. 按 q 键完成配置"
