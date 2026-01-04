#!/usr/bin/env python3
"""
修复 settings.json 格式错误

问题分析：
当前 settings.json 中的 sandbox 字段格式错误：
  "sandbox": {
    "enabled": false

  ,

解决方案：
使用 Python 读取、修复并重新格式化 settings.json
"""

import json
import os
import shutil
from datetime import datetime

def fix_settings_json():
    settings_file = os.path.expanduser("~/.claude/settings.json")

    if not os.path.exists(settings_file):
        print(f"✗ 配置文件不存在: {settings_file}")
        return False

    # 备份原文件
    timestamp = datetime.now().strftime("%Y%m%d%H%M%S")
    backup_file = f"{settings_file}.fixed.{timestamp}"
    shutil.copy2(settings_file, backup_file)
    print(f"✓ 已备份到: {backup_file}")

    try:
        # 尝试直接读取（如果格式已经正确）
        with open(settings_file, 'r', encoding='utf-8') as f:
            content = f.read()

        # 尝试解析 JSON
        try:
            config = json.loads(content)
            print("✓ JSON 格式正确，无需修复")
            return True
        except json.JSONDecodeError as e:
            print(f"⚠ JSON 格式错误: {e}")
            print("  尝试修复...")

            # 尝试修复：移除错误的逗号和空白
            # 常见错误："}\n\n  ,"  这样的格式
            import re

            # 修复规则1：移除对象后面的多余逗号和空白
            # "  }\n\n  ," -> "  },"
            fixed_content = re.sub(r'\}\s*\n\s*,\s*\n', '},\n', content)

            # 修复规则2：移除文件末尾的错误逗号
            # "}\n  ," -> "},"
            fixed_content = re.sub(r'\}\s*\n\s*,\s*\n', '},\n', fixed_content)

            try:
                config = json.loads(fixed_content)
                print("✓ 修复成功，写入文件...")

                # 写入修复后的内容
                with open(settings_file, 'w', encoding='utf-8') as f:
                    json.dump(config, f, indent=2, ensure_ascii=False)

                print(f"✓ 已修复: {settings_file}")
                return True

            except json.JSONDecodeError as e2:
                print(f"✗ 自动修复失败: {e2}")
                print("\n请手动修复或从备份恢复：")
                print(f"  备份文件: {backup_file}")
                print(f"  原始文件: {settings_file}")
                return False

    except Exception as e:
        print(f"✗ 发生错误: {e}")
        return False

def show_current_config():
    """显示当前配置"""
    settings_file = os.path.expanduser("~/.claude/settings.json")

    if not os.path.exists(settings_file):
        print(f"✗ 配置文件不存在: {settings_file}")
        return

    print(f"\n当前配置 ({settings_file}):")
    print("=" * 60)

    try:
        with open(settings_file, 'r', encoding='utf-8') as f:
            content = f.read()

        # 尝试格式化显示
        try:
            config = json.loads(content)
            print(json.dumps(config, indent=2, ensure_ascii=False))
        except json.JSONDecodeError:
            # 如果格式错误，显示原始内容
            print(content)

    except Exception as e:
        print(f"✗ 读取失败: {e}")

    print("=" * 60)

if __name__ == "__main__":
    print("Claude Code Settings.json 修复工具")
    print("=" * 60)

    # 显示当前配置
    show_current_config()

    # 修复
    print("\n开始修复...")
    if fix_settings_json():
        print("\n✓ 修复完成！")

        # 显示修复后的配置
        show_current_config()
    else:
        print("\n✗ 修复失败")
