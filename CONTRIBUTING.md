# 贡献指南

感谢你对 Claude Code 声音提示配置项目的关注！

## 如何贡献

我们欢迎任何形式的贡献，包括但不限于：

- 🐛 报告 Bug
- 💡 提出新功能建议
- 📖 改进文档
- 🔧 提交代码修复
- 🌍 帮助翻译

## 报告问题

在提交 Issue 之前，请先：

1. 搜索现有的 Issues，避免重复
2. 收集以下信息：
   - macOS 版本
   - Claude Code 版本
   - 错误信息或截图
   - 复现步骤

提交 Issue 时，请使用清晰的标题和详细的描述。

## 提交 Pull Request

### 开发流程

1. **Fork 本仓库**
   ```bash
   # 点击 GitHub 页面上的 Fork 按钮
   ```

2. **克隆你的 Fork**
   ```bash
   git clone https://github.com/yourusername/claude-code-sounds.git
   cd claude-code-sounds
   ```

3. **创建特性分支**
   ```bash
   git checkout -b feature/your-feature-name
   ```

   分支命名规范：
   - `feature/` - 新功能
   - `fix/` - Bug 修复
   - `docs/` - 文档更新
   - `refactor/` - 代码重构

4. **进行修改**
   - 遵循现有代码风格
   - 添加必要的注释
   - 更新相关文档

5. **提交更改**
   ```bash
   git add .
   git commit -m "feat: add some amazing feature"
   ```

   提交信息规范：
   - `feat:` - 新功能
   - `fix:` - Bug 修复
   - `docs:` - 文档更新
   - `style:` - 代码格式调整
   - `refactor:` - 代码重构
   - `test:` - 测试相关
   - `chore:` - 构建/工具链相关

6. **推送到 GitHub**
   ```bash
   git push origin feature/your-feature-name
   ```

7. **创建 Pull Request**
   - 在 GitHub 页面上创建 PR
   - 填写 PR 模板
   - 等待审查

### 代码规范

#### Shell 脚本规范

- 使用 4 空格缩进
- 添加必要的注释
- 函数名使用 `print_` 前缀（打印类）或动词开头（操作类）
- 使用 `set -e` 确保错误时退出
- 使用有意义的变量名

示例：

```bash
#!/bin/bash

# 函数注释
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

# 主逻辑
main() {
    print_info "开始执行..."
}

main "$@"
```

#### 文档规范

- 使用 Markdown 格式
- 添加代码示例
- 使用清晰的标题层级
- 提供必要的截图（如适用）

### 测试

提交前请确保：

- [ ] 代码能在标准 macOS 环境下运行
- [ ] 安装脚本没有语法错误
- [ ] 文档示例可以正常执行
- [ ] 更新了相关文档

## 文档贡献

文档改进同样重要！你可以：

- 修正错别字
- 改进说明的清晰度
- 添加使用示例
- 翻译文档

## 行为准则

- 尊重所有贡献者
- 欢迎新手提问
- 建设性讨论
- 专注于解决问题

## 获取帮助

如有疑问，可以：

- 查看 [文档](docs/配置指南.md)
- 提交 [Issue](https://github.com/yourusername/claude-code-sounds/issues)
- 加入讨论

## 许可证

提交贡献即表示你同意你的贡献将根据 [MIT License](LICENSE) 发布。

---

再次感谢你的贡献！🎉
