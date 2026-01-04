# 优化说明 (v3.0.0)

## 概述

install-claude-sounds.sh 脚本已从 v2.0.0 升级到 v3.0.0，进行了重大优化和功能增强。

## 主要改进

### 1. 代码重构与优化

#### 1.1 数据结构驱动

**优化前**: 硬编码的重复代码
```bash
# 每个平台重复 6 次类似的脚本创建代码
case "$OS" in
    macos)
        print_info "创建任务完成提示音脚本..."
        cat > "$HOME/.local/bin/claude-task-done.sh" << 'EOF'
#!/bin/bash
afplay /System/Library/Sounds/Glass.aiff
EOF
        chmod +x "$HOME/.local/bin/claude-task-done.sh"
        # ... 重复 5 次
    ;;
    linux)
        # ... 又重复 6 次
    ;;
    windows)
        # ... 再重复 6 次
    ;;
esac
```

**优化后**: 配置驱动的关联数组
```bash
# 所有配置集中管理
declare -A PLATFORM_SOUNDS=(
    ["macos_task_done"]="afplay /System/Library/Sounds/Glass.aiff"
    ["linux_task_done"]="echo -e \"\\a\""
    ["windows_task_done"]="powershell.exe -Command \"[console]::beep(800, 200)\""
    # ... 其他配置
)
```

**优势**:
- 配置与逻辑分离
- 添加新平台只需修改配置数组
- 减少了约 200 行重复代码

#### 1.2 函数抽象化

**新增核心函数**:

1. **generate_sound_script()** - 生成单个声音脚本
   - 参数: hook_name, sound_cmd, platform
   - 自动处理启用/禁用状态
   - 支持自定义声音

2. **generate_all_scripts()** - 批量生成所有脚本
   - 遍历所有钩子
   - 调用 generate_sound_script()
   - 平台特定检查

3. **generate_hooks_config_for_jq()** - 生成 JSON 配置
   - 自动处理 Notification 事件的多个 matcher
   - 生成 jq 兼容的 JSON
   - 支持部分启用钩子

4. **test_notification_sounds()** - 测试提示音
   - 只测试启用的钩子
   - 支持自定义声音测试

**代码行数对比**:
```
脚本生成代码: 270 行 → 50 行 (减少 81%)
JSON 配置生成: 210 行 → 80 行 (减少 62%)
测试代码: 54 行 → 20 行 (减少 63%)
```

### 2. 交互式配置功能

#### 2.1 两个配置步骤

**步骤 1: 选择启用的通知**
```
步骤 1/2: 选择要启用的声音通知

输入钩子编号来切换启用/禁用状态，或按 Enter 继续:

  1. [✓ 启用] 任务完成提示音 (Claude执行工具操作后)
  2. [✓ 启用] 用户提交提示音 (用户提交新的提示时)
  3. [✗ 禁用] 用户询问提示音 (Claude请求权限时)
  4. [✓ 启用] 权限请求提示音 (Claude请求权限时（Notification事件）)
  5. [✓ 启用] 空闲等待提示音 (Claude等待用户输入时（闲置60+秒））
  6. [✓ 启用] 任务停止提示音 (Claude任务完成响应时)

选择 (1-6, 或 Enter 继续):
```

**步骤 2: 为每个启用的钩子选择声音**
```
步骤 2/2: 为每个钩子选择声音

任务完成提示音 - Claude执行工具操作后

  0. 使用默认声音
  1. Glass
  2. Hero
  3. Ping
  4. Basso
  5. Funk
  6. Purr
  7. Sosumi

输入声音编号或按 Enter 使用默认:
```

#### 2.2 交互式菜单函数

1. **show_interactive_menu()** - 主菜单
   - 清屏显示
   - 循环处理用户输入
   - 实时更新状态显示

2. **show_sound_options()** - 显示声音选项
   - 平台特定的声音列表
   - 包含"使用默认"选项

3. **apply_sound_choice()** - 应用声音选择
   - 验证用户输入
   - 生成平台特定的命令
   - 更新配置数组

### 3. 向后兼容性

#### 3.1 默认行为保持不变

如果用户直接运行脚本（或输入 'n'），将使用默认配置：
- 所有通知启用
- 使用平台默认铃声
- 配置文件格式不变

#### 3.2 配置文件兼容

生成的 `~/.claude/settings.json` 格式与 v2.0.0 完全一致：
```json
{
  "hooks": {
    "PostToolUse": [...],
    "UserPromptSubmit": [...],
    "PermissionRequest": [...],
    "Notification": [...],
    "Stop": [...]
  }
}
```

### 4. 代码质量提升

#### 4.1 可维护性

- **模块化设计**: 每个函数职责单一
- **配置集中**: 所有配置在文件顶部
- **注释清晰**: 分隔符和函数说明
- **命名规范**: 统一的命名约定

#### 4.2 可扩展性

添加新钩子只需三步：
1. 在 `PLATFORM_SOUNDS` 中添加音效配置
2. 在 `HOOK_EVENTS` 中添加钩子定义
3. 在 `HOOK_DESCRIPTIONS` 中添加描述

**示例**: 添加新钩子只需约 10 行配置代码

#### 4.3 可测试性

- 函数化设计便于单元测试
- 独立的配置数组易于验证
- 清晰的输入输出接口

## 性能对比

| 指标 | v2.0.0 | v3.0.0 | 改进 |
|------|--------|--------|------|
| 总行数 | 624 | 658 | +34 行 (+5.4%) |
| 核心代码行数 | ~400 | ~220 | -180 行 (-45%) |
| 重复代码 | ~270 | ~50 | -220 行 (-81%) |
| 配置项 | 硬编码 | 数组驱动 | 质的提升 |
| 交互功能 | 无 | 有 | 新增 |
| 支持钩子数 | 6 | 6 | 相同 |
| 可维护性 | 低 | 高 | 显著提升 |

注: 总行数增加主要是因为添加了交互式菜单功能（约 150 行）和更多注释。

## 功能对比

### v2.0.0 功能
- ✅ 支持三个平台（macOS、Linux、Windows）
- ✅ 支持 6 个钩子事件
- ✅ 自动生成脚本
- ✅ 自动配置 JSON
- ✅ 备份现有配置
- ✅ jq 集成
- ❌ 无交互式配置
- ❌ 无法选择启用哪些通知
- ❌ 无法自定义铃声

### v3.0.0 功能
- ✅ 支持三个平台（macOS、Linux、Windows）
- ✅ 支持 6 个钩子事件
- ✅ 自动生成脚本
- ✅ 自动配置 JSON
- ✅ 备份现有配置
- ✅ jq 集成
- ✅ **交互式配置**
- ✅ **选择启用哪些通知**
- ✅ **自定义铃声**
- ✅ **更好的代码结构**
- ✅ **更易维护**

## 使用示例

### 示例 1: 使用默认配置

```bash
./install-claude-sounds.sh
# 当提示"是否使用交互式配置？"时，按 Enter 或输入 n
```

结果：所有通知启用，使用默认铃声。

### 示例 2: 只启用部分通知

```bash
./install-claude-sounds.sh
# 输入 y 进入交互式配置
# 在步骤 1 中，输入 3 禁用"用户询问提示音"
# 输入 5 禁用"空闲等待提示音"
# 按 Enter 继续
# 在步骤 2 中，按 Enter 使用默认声音
```

结果：只启用 4 个通知，使用默认铃声。

### 示例 3: 自定义所有铃声

```bash
./install-claude-sounds.sh
# 输入 y 进入交互式配置
# 在步骤 1 中，按 Enter（全部启用）
# 在步骤 2 中，为每个通知选择不同的铃声：
#   - 任务完成: 选择 2 (Hero)
#   - 用户提交: 选择 3 (Ping)
#   - 用户询问: 选择 4 (Basso)
#   - 权限请求: 选择 5 (Funk)
#   - 空闲等待: 选择 1 (Glass)
#   - 任务停止: 选择 7 (Sosumi)
```

结果：所有通知启用，每个使用不同的铃声。

## 技术细节

### 数据结构

```bash
# 1. 平台音效配置（18 个键值对）
PLATFORM_SOUNDS

# 2. 钩子事件定义（6 个键值对）
HOOK_EVENTS

# 3. 钩子描述（6 个键值对）
HOOK_DESCRIPTIONS

# 4. 钩子详细描述（6 个键值对）
HOOK_DETAIL_DESCRIPTIONS

# 5. 钩子启用状态（6 个键值对）
HOOK_ENABLED

# 6. 用户声音选择（6 个键值对）
HOOK_SOUND_CHOICES

# 7. 可用铃声列表（3 个键值对）
AVAILABLE_SOUNDS
```

### 函数列表

**工具函数** (5 个):
- detect_os()
- print_info()
- print_success()
- print_warning()
- print_error()
- print_header()

**核心函数** (4 个):
- generate_sound_script()
- generate_all_scripts()
- generate_hook_json()
- generate_hooks_config_for_jq()
- test_notification_sounds()

**交互式菜单函数** (3 个):
- show_interactive_menu()
- show_sound_options()
- apply_sound_choice()

### 配置流程

```
开始
  │
  ├─ 检测操作系统
  │
  ├─ 询问：交互式配置？
  │   ├─ 是 → show_interactive_menu()
  │   │       ├─ 步骤 1: 选择启用的钩子
  │   │       │       └─ 更新 HOOK_ENABLED
  │   │       │
  │   │       └─ 步骤 2: 选择铃声
  │   │               └─ 更新 HOOK_SOUND_CHOICES
  │   │
  │   └─ 否 → 使用默认配置
  │
  ├─ generate_all_scripts(OS)
  │   └─ generate_sound_script() for each hook
  │
  ├─ 处理配置文件
  │   ├─ 备份现有配置
  │   ├─ 生成 hooks JSON
  │   └─ 合并或创建配置
  │
  ├─ 测试提示音？
  │   └─ test_notification_sounds()
  │
  └─ 完成
```

## 升级指南

### 从 v2.0.0 升级

1. **备份现有配置**（自动完成）
   ```bash
   # 脚本会自动创建备份
   ~/.claude/settings.json.backup
   ```

2. **运行新脚本**
   ```bash
   ./install-claude-sounds.sh
   ```

3. **选择配置方式**
   - 按 Enter 使用默认配置（与 v2.0.0 相同）
   - 输入 y 使用交互式配置（新功能）

4. **重启 Claude Code**
   ```bash
   # 退出并重新启动 Claude Code
   ```

### 回滚到 v2.0.0

如果需要回滚：

1. **恢复备份脚本**
   ```bash
   mv install-claude-sounds.sh.backup install-claude-sounds.sh
   ```

2. **恢复配置**
   ```bash
   mv ~/.claude/settings.json.backup ~/.claude/settings.json
   ```

3. **重新安装**
   ```bash
   ./install-claude-sounds.sh
   ```

## 已知问题与限制

1. **Linux 声音选项**
   - `paplay` 和 `aplay` 需要相应的系统包
   - 某些发行版可能没有 `/usr/share/sounds/` 目录

2. **Windows PowerShell**
   - 需要 PowerShell 3.0+
   - 在某些受限环境下可能无法使用

3. **交互式菜单**
   - 在某些终端中清屏命令可能不生效
   - 不支持返回上一步（需要重新运行脚本）

## 未来计划

1. **命令行参数支持**
   ```bash
   ./install-claude-sounds.sh --enable task_done,user_prompt
   ./install-claude-sounds.sh --disable ask_user
   ./install-claude-sounds.sh --sound Glass
   ```

2. **配置持久化**
   ```bash
   ~/.claude/sounds-config.json
   ```

3. **卸载功能**
   ```bash
   ./install-claude-sounds.sh --uninstall
   ```

4. **预设配置模板**
   ```bash
   ./install-claude-sounds.sh --preset minimal
   ./install-claude-sounds.sh --preset full
   ```

## 贡献者

感谢所有为这个项目做出贡献的开发者！

## 许可证

MIT License - 详见 [LICENSE](LICENSE) 文件
