#!/bin/bash

# PyTorch CUDA CI/CD 自动化安装脚本
# 作者: SunshineCloudTech  
# 日期: 2025-10-22
# 适用于: CI/CD 流水线，无需人工交互

set -e  # 遇到错误时退出

# 配置
CUDA_VERSION=${CUDA_VERSION:-"cu126"}  # 支持环境变量
INDEX_URL="https://download.pytorch.org/whl/${CUDA_VERSION}"
FORCE_REINSTALL=${FORCE_REINSTALL:-"true"}  # CI/CD 默认强制重装
TORCH_GPU_SKIP_VERIFICATION=${TORCH_GPU_SKIP_VERIFICATION:-"false"}  # 是否跳过验证

# 日志函数
log_info() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] INFO: $1"
}

log_error() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ERROR: $1" >&2
}

log_warn() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] WARN: $1"
}

# 检查命令是否存在
check_command() {
    if ! command -v $1 &> /dev/null; then
        log_error "$1 命令未找到，请先安装"
        exit 1
    fi
}

# 获取最新版本号
get_latest_version() {
    local package=$1
    local output=$(pip index versions ${package} --index-url ${INDEX_URL} 2>/dev/null)
    
    # 首先尝试从第一行提取版本号（格式：package (version)）
    local version=$(echo "$output" | head -1 | grep -o '([^)]*)' | tr -d '()')
    
    # 如果没有找到，尝试从 Available versions 行提取第一个版本
    if [[ -z "$version" ]]; then
        version=$(echo "$output" | grep "Available versions:" | sed 's/Available versions: //' | awk -F', ' '{print $1}')
    fi
    
    # 如果还是没有找到，尝试查找 LATEST 标识
    if [[ -z "$version" ]]; then
        version=$(echo "$output" | grep "LATEST:" | awk '{print $2}')
    fi
    
    if [[ -z "$version" ]]; then
        log_error "无法获取 ${package} 的最新版本"
        log_error "输出内容: $output"
        exit 1
    fi
    echo $version
}

# 验证安装
verify_installation() {
    if [[ "$TORCH_GPU_SKIP_VERIFICATION" == "true" ]]; then
        log_info "跳过安装验证"
        return 0
    fi
    
    log_info "验证安装..."
    python3 -c "
import sys
try:
    import torch
    import torchvision
    import torchaudio
    
    print(f'PyTorch:     {torch.__version__}')
    print(f'TorchVision: {torchvision.__version__}')
    print(f'TorchAudio:  {torchaudio.__version__}')
    print(f'CUDA:        {torch.version.cuda}')
    print(f'CUDA 可用:   {torch.cuda.is_available()}')
    
    if torch.cuda.is_available():
        print(f'GPU 数量:    {torch.cuda.device_count()}')
        try:
            print(f'GPU 名称:    {torch.cuda.get_device_name()}')
        except:
            print('GPU 名称:    无法获取')
    
    # 简单测试
    x = torch.randn(2, 3)
    if torch.cuda.is_available():
        x = x.cuda()
        print('CUDA 测试:   通过')
    
    print('验证结果:    ✅ 成功')
    
except Exception as e:
    print(f'验证失败:    ❌ {e}')
    sys.exit(1)
" || exit 1
}

# 主函数
main() {
    log_info "开始 PyTorch CUDA 自动化安装"
    log_info "CUDA 版本: ${CUDA_VERSION}"
    log_info "运行环境: CI/CD"
    
    # 检查环境
    log_info "检查系统环境..."
    check_command pip
    check_command python3
    check_command awk
    
    # 获取版本信息
    log_info "获取最新版本信息..."
    TORCH_VERSION=$(get_latest_version torch)
    TORCHVISION_VERSION=$(get_latest_version torchvision)
    TORCHAUDIO_VERSION=$(get_latest_version torchaudio)
    
    log_info "版本信息:"
    log_info "  PyTorch:     ${TORCH_VERSION}"
    log_info "  TorchVision: ${TORCHVISION_VERSION}" 
    log_info "  TorchAudio:  ${TORCHAUDIO_VERSION}"
    
    # 卸载现有版本（如果需要）
    if [[ "$FORCE_REINSTALL" == "true" ]]; then
        log_info "卸载现有版本..."
        
        # 首先尝试正常卸载
        uv pip uninstall torch torchvision torchaudio -y 2>/dev/null || log_warn "正常卸载失败或未发现现有安装"
        
        # 强制清理残留文件
        log_info "清理残留文件..."
        
        # 获取 Python site-packages 路径
        local site_packages=$(python3 -c "import site; print(site.getsitepackages()[0])" 2>/dev/null)
        if [[ -n "$site_packages" ]]; then
            log_info "清理目录: $site_packages"
            
            # 删除 PyTorch 相关目录和文件
            rm -rf "$site_packages"/torch* 2>/dev/null || true
            rm -rf "$site_packages"/nvidia* 2>/dev/null || true
            rm -rf "$site_packages"/triton* 2>/dev/null || true
            rm -rf "$site_packages"/*torch* 2>/dev/null || true
            
            # 清理 .dist-info 目录
            rm -rf "$site_packages"/torch*.dist-info 2>/dev/null || true
            rm -rf "$site_packages"/torchvision*.dist-info 2>/dev/null || true
            rm -rf "$site_packages"/torchaudio*.dist-info 2>/dev/null || true
            rm -rf "$site_packages"/nvidia*.dist-info 2>/dev/null || true
            rm -rf "$site_packages"/triton*.dist-info 2>/dev/null || true
            
            log_info "残留文件清理完成"
        else
            log_warn "无法获取 site-packages 路径，跳过文件清理"
        fi
        
        # 清理 pip 缓存
        log_info "清理安装缓存..."
        if command -v pip3 &> /dev/null; then
            pip3 cache purge 2>/dev/null || true
        fi
        uv cache clean 2>/dev/null || true
    fi
    
    # 安装
    log_info "开始安装..."
    local install_cmd="uv pip install torch==${TORCH_VERSION} torchvision==${TORCHVISION_VERSION} torchaudio==${TORCHAUDIO_VERSION} --index-url ${INDEX_URL}"
    
    # 添加常用 CI/CD 参数
    install_cmd="${install_cmd} --system --no-cache-dir --force-reinstall --no-deps"
    
    log_info "执行: ${install_cmd}"
    
    if eval $install_cmd; then
        log_info "PyTorch 核心包安装成功，开始安装依赖..."
        
        # 单独安装依赖，避免冲突
        local deps_cmd="uv pip install --system --no-cache-dir --index-url ${INDEX_URL}"
        deps_cmd="${deps_cmd} nvidia-cuda-runtime-cu12 nvidia-cuda-cupti-cu12 nvidia-cudnn-cu12"
        deps_cmd="${deps_cmd} nvidia-cublas-cu12 nvidia-cufft-cu12 nvidia-curand-cu12"
        deps_cmd="${deps_cmd} nvidia-cusolver-cu12 nvidia-cusparse-cu12 nvidia-nccl-cu12"
        deps_cmd="${deps_cmd} nvidia-nvtx-cu12 triton"
        
        log_info "安装 CUDA 依赖: ${deps_cmd}"
        eval $deps_cmd || log_warn "部分依赖安装可能失败，但不影响核心功能"
        
        log_info "安装成功 ✅"
    else
        log_error "安装失败 ❌"
        exit 1
    fi
    
    # 验证
    verify_installation
    
    log_info "PyTorch CUDA 安装完成 🎉"
}

# 执行主函数
main "$@"