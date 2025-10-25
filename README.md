# SunshineCloud 通用工具集

一个全面的开发环境和容器化服务实用工具集合。

## 项目概述

本仓库包含多个实用工具，用于自动化软件安装和构建容器化服务：

- JetBrains IDE 自动化安装器
- PyTorch CUDA 安装脚本
- MySQL Docker 构建器
- PulseAudio XRDP Docker 构建器
- 各种实用脚本

## 组件说明

### 1. JetBrains IDE 安装器

位置：`Jetbrains-Installer/`

JetBrains IDE 自动化安装器，支持：
- 版本指定安装
- ARM64 架构支持
- 多个 IDE 同时安装
- 自定义安装路径

支持的产品：

| 产品名称 | 命令参数 | 说明 |
|---------|---------|------|
| CLion | `clion` | C/C++ 开发环境 |
| DataGrip | `datagrip` | 数据库工具 |
| DataSpell | `dataspell` | 数据科学 IDE |
| GoLand | `goland` | Go 语言 IDE |
| IntelliJ IDEA Ultimate | `idea-ultimate` | Java 企业版 IDE |
| IntelliJ IDEA Community | `idea-community` | Java 社区版 IDE |
| PhpStorm | `phpstorm` | PHP 开发环境 |
| PyCharm Professional | `pycharm` | Python 专业版 IDE |
| PyCharm Community | `pycharm-community` | Python 社区版 IDE |
| Rider | `rider` | .NET 开发环境 |
| RubyMine | `rubymine` | Ruby 开发环境 |
| RustRover | `rustrover` | Rust 开发环境 |
| WebStorm | `webstorm` | JavaScript IDE |

使用方法：

```bash
# 安装默认版本
python3 cli.py pycharm

# 安装多个产品
python3 cli.py pycharm webstorm goland

# 指定版本安装
python3 cli.py --pycharm 2024.2.1 --webstorm 2024.1.5

# ARM64 支持
python3 cli.py listing-arm.json pycharm goland
```

配置说明：
- 默认安装路径：`/SunshineCloud/Jetbrains/`
- 临时目录：`/SunshineCloud/Jetbrains/temp`
- 默认版本：`2024.1.4`
- 用户权限：自动设置为当前用户

### 2. PyTorch CUDA 安装器

位置：`Torch-Install-GPU/`

用于 CI/CD 环境的 PyTorch CUDA 自动化安装脚本。

功能特性：
- 自动版本检测
- 虚拟环境检测
- Docker 环境跳过验证
- 全面的错误处理和清理

使用方法：
```bash
# 基础安装
bash Torch-Install-GPU.sh

# 跳过验证（适用于 Docker）
TORCH_GPU_SKIP_VERIFICATION=true bash Torch-Install-GPU.sh

# 强制重新安装
FORCE_REINSTALL=true bash Torch-Install-GPU.sh
```

环境变量：
- `TORCH_GPU_SKIP_VERIFICATION`：跳过安装验证（默认：false）
- `FORCE_REINSTALL`：强制重新安装（默认：true）
- `INSTALL_CUDA_VERSION`：使用的 CUDA 版本（默认：cu126）

### 3. MySQL Docker 构建器

位置：`MySQL-Docker-Builder/`

用于从源代码构建 MySQL 8.0.43 的 Dockerfile，集成 Supervisor 进程管理。

功能特性：
- 源代码编译
- Debian Bookworm 基础镜像
- Supervisor 进程管理
- 自定义配置支持

### 4. PulseAudio XRDP Docker 构建器

位置：`PulseAudio-XRDP-Docker-Builder/`

用于构建支持音频转发的 XRDP 远程桌面的 Dockerfile。

功能特性：
- 支持音频的 XRDP
- PulseAudio 模块编译
- 自动化构建流程

## 项目结构

```
SunshineCloud-Universal-Utils/
├── Jetbrains-Installer/
│   ├── cli.py
│   ├── listing.json
│   ├── listing-arm.json
│   ├── software_install.sh
│   └── applications/
├── Torch-Install-GPU/
│   └── Torch-Install-GPU.sh
├── MySQL-Docker-Builder/
│   └── Dockerfile
├── PulseAudio-XRDP-Docker-Builder/
│   └── Dockerfile
├── scripts/
│   └── repo-push.sh
├── sources/
│   ├── sources-bookworm.list
│   └── sources-bullseye.list
└── README.md
```

## 系统要求

JetBrains 安装器：
- Linux 系统
- Python 3.6+
- Sudo 权限
- 每个 IDE 需要 1-2GB 磁盘空间

PyTorch 安装器：
- Linux 系统
- Python 3.6+
- 网络连接
- CUDA 兼容的 GPU（用于验证）

Docker 构建器：
- Docker 环境
- 网络连接
- 构建工具和依赖

## 快速开始

### 克隆仓库
```bash
git clone https://github.com/SunshineCloudTech/SunshineCloud-Universal-Utils.git
cd SunshineCloud-Universal-Utils
```

### 安装 JetBrains IDE
```bash
cd Jetbrains-Installer
python3 cli.py pycharm webstorm
```

### 安装 PyTorch CUDA
```bash
cd Torch-Install-GPU
bash Torch-Install-GPU.sh
```

### 构建 Docker 镜像
```bash
# 构建 MySQL
docker build -t custom-mysql ./MySQL-Docker-Builder/

# 构建 PulseAudio XRDP
docker build -t xrdp-audio ./PulseAudio-XRDP-Docker-Builder/
```

## 贡献

欢迎贡献代码！请遵循以下步骤：

1. Fork 此仓库
2. 创建功能分支（`git checkout -b feature/AmazingFeature`）
3. 提交更改（`git commit -m 'Add some AmazingFeature'`）
4. 推送到分支（`git push origin feature/AmazingFeature`）
5. 创建 Pull Request

## 许可证

本项目采用 MIT 许可证 - 详见 LICENSE 文件。

## 维护者

- **SunshineCloudTech** - 项目维护者

## 致谢

- JetBrains 提供优秀的开发工具
- 开源社区的支持和贡献