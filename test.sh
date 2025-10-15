#!/bin/bash
COMPILE_MEMORY_PER_JOB=1536
    CPU_CORES=$(nproc) && \
    TOTAL_MEM_MB=$(free -m | awk '/^Mem:/ {print $2}') && \
    # 设置默认内存限制 (如果环境变量未定义)
    MAX_JOBS_BY_MEM=$((TOTAL_MEM_MB / ${COMPILE_MEMORY_PER_JOB})) && \
    # 计算基于内存的最大并行任务数 (每个任务需要约 1.5GB 内存)
    #MAX_JOBS_BY_MEM=$((TOTAL_MEM_MB / MEMORY_PER_JOB)) && \
    # 取 CPU 核心数和内存限制的较小值
    PARALLEL_JOBS=$((CPU_CORES < MAX_JOBS_BY_MEM ? CPU_CORES : MAX_JOBS_BY_MEM)) && \
    # 至少使用 1 个线程，最多不超过 CPU 核心数
    [ ${PARALLEL_JOBS} -lt 1 ] && PARALLEL_JOBS=1 && \
    [ ${PARALLEL_JOBS} -gt ${CPU_CORES} ] && PARALLEL_JOBS=${CPU_CORES} && \
    echo "编译配置:" && \
    echo "  - 当前目录: $(pwd)" && \
    echo "  - CPU 核心数: ${CPU_CORES}" && \
    echo "  - 总内存: ${TOTAL_MEM_MB} MB" && \
    echo "  - 每个任务内存需求: ${MEMORY_PER_JOB} MB" && \
    echo "  - 内存限制的最大并行数: ${MAX_JOBS_BY_MEM}" && \
    echo "  - 实际使用并行数: ${PARALLEL_JOBS}" && \
    echo "============================================" && \
    echo "开始编译 (预计需要 30-60 分钟，取决于系统性能)..."
