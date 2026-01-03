# 更新日志

本项目的所有重要更改都将记录在此文件中。

格式基于 [Keep a Changelog](https://keepachangelog.com/zh-CN/1.0.0/)，
版本号遵循 [语义化版本](https://semver.org/lang/zh-CN/)。

## [未发布]

## [1.0.0] - 2025-01-03

### 新增
- 🎵 三种提示音配置：
  - PostToolUse - 任务完成提示音（Glass.aiff）
  - UserPromptSubmit - 用户提交提示音（Hero.aiff）
  - PermissionRequest - 权限请求提示音（Ping.aiff）
- 🚀 一键安装脚本 `install-claude-sounds.sh`
- 📖 完整的中文配置指南文档
- ⚙️ 自动备份现有配置文件功能
- 🔧 支持 jq 自动合并配置
- 🧪 安装后提示音测试功能
- 📝 详细的 README 和项目文档

### 功能
- 自动检测 macOS 系统
- 自动创建必要的目录结构
- 自动创建三个提示音脚本并设置执行权限
- 智能处理现有配置文件：
  - 创建备份
  - 使用 jq 合并配置（如已安装）
  - 提供手动配置说明（如未安装 jq）
- 交互式提示音测试

### 文档
- README.md - 项目主文档（中英文）
- docs/配置指南.md - 详细配置指南
- CONTRIBUTING.md - 贡献指南
- LICENSE - MIT 许可证
- CHANGELOG.md - 更新日志

### 安全
- 添加 .gitignore 忽略敏感配置文件
- 自动备份机制防止配置丢失

---

[未发布]: https://github.com/yourusername/claude-code-sounds/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/yourusername/claude-code-sounds/releases/tag/v1.0.0
