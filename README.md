# 🌤️ SunshineCloud Universal Utils

� **JetBrains安装器** | 🔊 **XRDP音频支持** | 📜 **MIT开源** | 🐳 **Docker构建** | �️ **自动化CI/CD** | ⚡ **一键部署**

A comprehensive collection of utility tools and automated installers for development environments and remote desktop solutions.

## 📋 项目概述

SunshineCloud Universal Utils 是一个通用工具集合，提供以下核心功能：

### 🚀 主要组件

#### 1. JetBrains IDE 自动化安装器
- **位置**: `Jetbrains-Installer/`
- **功能**: 自动下载、安装和配置 JetBrains 全系列 IDE
- **支持产品**: 13+ 款 JetBrains 产品
- **特性**: 版本指定、ARM64 支持、自动化部署

#### 2. PulseAudio XRDP 构建工具
- **位置**: `.github/workflows/`
- **功能**: 自动化构建带有音频支持的 XRDP 模块
- **输出**: 预编译的 PulseAudio 模块和 XRDP 二进制文件
- **特性**: GitHub Actions 自动化构建和发布

#### 3. 开发辅助脚本
- **位置**: `scripts/`
- **功能**: Git 操作自动化、仓库管理工具

## 🛠️ JetBrains 安装器

### 支持的产品

| 产品名称 | 命令参数 | 描述 |
|---------|---------|------|
| CLion | `clion` | C/C++ IDE |
| DataGrip | `datagrip` | 数据库工具 |
| DataSpell | `dataspell` | 数据科学 IDE |
| GoLand | `goland` | Go 语言 IDE |
| IntelliJ IDEA Ultimate | `idea-ultimate` | Java 企业版 IDE |
| IntelliJ IDEA Community | `idea-community` | Java 社区版 IDE |
| PhpStorm | `phpstorm` | PHP IDE |
| PyCharm Professional | `pycharm` | Python 专业版 IDE |
| PyCharm Community | `pycharm-community` | Python 社区版 IDE |
| Rider | `rider` | .NET IDE |
| RubyMine | `rubymine` | Ruby IDE |
| RustRover | `rustrover` | Rust IDE |
| WebStorm | `webstorm` | JavaScript IDE |

### 使用方法

#### 基本安装
```bash
# 安装默认版本的 PyCharm Professional
python3 cli.py pycharm

# 安装多个产品
python3 cli.py pycharm webstorm goland
```

#### 指定版本安装
```bash
# 安装指定版本
python3 cli.py --pycharm 2024.2.1 --webstorm 2024.1.5

# 混合版本安装
python3 cli.py pycharm --goland 2024.2 idea-ultimate
```

#### ARM64 支持
```bash
# 使用 ARM64 配置文件
python3 cli.py listing-arm.json pycharm goland
```

### 配置说明

- **默认安装路径**: `/SunshineCloud/Jetbrains/`
- **临时目录**: `/SunshineCloud/Jetbrains/temp`
- **默认版本**: `2024.1.4`
- **用户权限**: 自动设置为当前用户

## 🔊 PulseAudio XRDP 构建

### 功能特性

🤖 **自动化构建** | 🔄 **XRDP v0.9.21** | 🔊 **音频转发** | 🏗️ **多架构支持** | 📦 **自动发布**

### 构建产物

每次构建会生成以下文件：
- `pulseaudio-xrdp-utils-{timestamp}.tar.gz`: 编译好的模块包
- `checksums.sha256`: 文件完整性校验

### 手动触发构建

1. 访问 [Actions 页面](../../actions/workflows/pulseaudio-xrdp-utils.yml)
2. 点击 "Run workflow"
3. 等待构建完成
4. 在 [Releases](../../releases) 页面下载构建产物

### 使用构建产物

```bash
# 下载最新版本
wget https://github.com/SunshineCloudSoft/SunshineCloud-Universal-Utils/releases/latest/download/pulseaudio-xrdp-utils-*.tar.gz

# 验证完整性
wget https://github.com/SunshineCloudSoft/SunshineCloud-Universal-Utils/releases/latest/download/checksums.sha256
sha256sum -c checksums.sha256

# 解压安装
tar -xzf pulseaudio-xrdp-utils-*.tar.gz
sudo cp pulseaudio-modules/*.so /usr/lib/pulse-*/modules/

# 重启服务
sudo systemctl restart xrdp
sudo systemctl restart pulseaudio
```

## 📁 项目结构

```
SunshineCloud-Universal-Utils/
├── 📁 Jetbrains-Installer/          # JetBrains IDE 安装器
│   ├── 🐍 cli.py                    # 主安装脚本
│   ├── 📋 listing.json              # x86_64 产品配置
│   ├── 📋 listing-arm.json          # ARM64 产品配置
│   ├── 🔧 software_install.sh       # 安装助手脚本
│   └── 📁 applications/             # 桌面应用配置
├── 📁 .github/workflows/            # GitHub Actions 工作流
│   ├── 🏗️ pulseaudio-xrdp-utils.yml # XRDP 构建工作流
│   └── 🐳 Dockerfile               # 构建镜像定义
├── 📁 scripts/                     # 辅助脚本
│   └── 🔄 repo-push.sh             # Git 推送脚本
├── 📄 README.md                    # 项目文档
└── 📜 LICENSE                      # 开源许可证
```

## 🔧 系统要求

### JetBrains 安装器
🐧 **Linux系统** | 🐍 **Python 3.6+** | 🔑 **Sudo权限** | 💾 **1-2GB空间/IDE**

### XRDP 构建
🐳 **Docker环境** | 🌐 **网络连接** | 💿 **Linux系统** | ⚙️ **构建工具链**

## 🚀 快速开始

### 1. 克隆仓库
```bash
git clone https://github.com/SunshineCloudSoft/SunshineCloud-Universal-Utils.git
cd SunshineCloud-Universal-Utils
```

### 2. 安装 JetBrains IDE
```bash
cd Jetbrains-Installer
python3 cli.py pycharm webstorm
```

### 3. 获取 XRDP 模块
访问 [Releases 页面](../../releases) 下载最新的预编译模块。

## 🤝 贡献指南

我们欢迎社区贡献！请遵循以下步骤：

1. **Fork** 此仓库
2. **创建** 功能分支 (`git checkout -b feature/AmazingFeature`)
3. **提交** 更改 (`git commit -m 'Add some AmazingFeature'`)
4. **推送** 到分支 (`git push origin feature/AmazingFeature`)
5. **创建** Pull Request

### 开发环境设置

```bash
# 安装开发依赖
pip3 install -r requirements.txt  # (如果存在)

# 运行测试
python3 -m pytest tests/  # (如果存在)
```

## 📝 更新日志

### v1.0.0 (当前版本)
🚀 **JetBrains安装器** | 🔊 **XRDP音频模块** | 🏗️ **CI/CD集成** | 🌐 **多架构支持** | ⚙️ **灵活配置**

## 🐛 问题报告

如果您遇到问题，请：

1. 检查 [已知问题](../../issues)
2. 提供详细的环境信息
3. 包含完整的错误日志
4. 提供复现步骤

## 📄 许可证

本项目采用 [MIT 许可证](LICENSE) - 详情请参阅 LICENSE 文件。

## 👥 维护团队

- **SunshineCloud** - *项目维护者* - [GitHub](https://github.com/SunshineCloudSoft)

## 🙏 致谢

- JetBrains 提供优秀的开发工具
- neutrinolabs 团队的 XRDP 项目
- 开源社区的支持和贡献

---

<div align="center">

**[⬆ 返回顶部](#-sunshinecloud-universal-utils)**

Made with ❤️ by SunshineCloud Team

</div>