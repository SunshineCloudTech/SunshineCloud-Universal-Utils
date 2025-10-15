# ============================================================================
# MySQL 8.0.43 源码编译 Dockerfile
# ============================================================================
# 项目: SunshineCloud MySQL Server
# 描述: 从源码编译 MySQL 8.0.43 数据库服务器，使用 Supervisor 管理进程
# 基础镜像: buildpack-deps (Debian Bookworm)
# 维护者: SunshineCloudTech
# 创建日期: 2025-10-15
# ============================================================================

# 基础镜像参数，使用 Debian Bookworm
ARG VARIANT="bookworm"
FROM buildpack-deps:${VARIANT}-curl

# ============================================================================
# 系统环境配置
# ============================================================================

# 设置非交互式安装模式，避免安装过程中出现交互提示
ENV DEBIAN_FRONTEND=noninteractive

# ============================================================================
# MySQL 版本和下载配置
# ============================================================================

# MySQL 版本号 - 使用 8.0.43 版本
ENV MYSQL_VERSION=8.0.43

# MySQL 源码下载地址
ENV MYSQL_DOWNLOAD_URL=https://dev.mysql.com/get/Downloads/MySQL-8.0/mysql-${MYSQL_VERSION}.tar.gz

# Boost 库版本配置 (MySQL 8.0.43 需要 Boost 1.77.0)
ENV BOOST_VERSION=1.77.0
ENV BOOST_VERSION_UNDERSCORED=1_77_0
ENV BOOST_DOWNLOAD_URL=https://sourceforge.net/projects/boost/files/boost/${BOOST_VERSION}/boost_${BOOST_VERSION_UNDERSCORED}.tar.gz/download

# ============================================================================
# MySQL 用户和组配置
# ============================================================================

# MySQL 运行用户名
ENV MYSQL_USER=mysql

# MySQL 运行用户组名
ENV MYSQL_GROUP=mysql

# MySQL 用户 UID (用户ID)
ENV MYSQL_UID=999

# MySQL 组 GID (组ID)
ENV MYSQL_GID=999

# ============================================================================
# MySQL 目录路径配置
# ============================================================================

# MySQL 程序安装根目录
ENV MYSQL_PREFIX=/SunshineCloud/MySQL-Server

# MySQL 数据文件存储目录
ENV MYSQL_DATADIR=/SunshineCloud/MySQL-Data

# MySQL 日志文件存储目录
ENV MYSQL_LOGDIR=/var/log/mysql

# MySQL 运行时文件目录 (存放 socket 和 pid 文件)
ENV MYSQL_RUNDIR=/var/run/mysqld

# MySQL 配置文件目录
ENV MYSQL_CONFDIR=/etc/mysql

# Supervisor 配置文件目录
ENV SUPERVISOR_CONFDIR=/etc/supervisor/conf.d

# 临时构建目录
ENV BUILD_TMPDIR=/tmp/mysql-build

# 临时构建目录
ENV BUILD_TMPDIR=/tmp/mysql-build

# ============================================================================
# MySQL 编译选项 - CMAKE 配置变量
# ============================================================================

# --- 存储引擎配置 ---
# 启用 InnoDB 存储引擎 (MySQL 默认和推荐的事务性存储引擎)
ENV CMAKE_WITH_INNOBASE_STORAGE_ENGINE=1

# 启用分区存储引擎 (支持表分区功能)
ENV CMAKE_WITH_PARTITION_STORAGE_ENGINE=1

# 启用 MyISAM 存储引擎 (传统的非事务性存储引擎)
ENV CMAKE_WITH_MYISAM_STORAGE_ENGINE=1

# 启用 MEMORY 存储引擎 (内存表，数据存储在内存中)
ENV CMAKE_WITH_MEMORY_STORAGE_ENGINE=1

# 启用 CSV 存储引擎 (以 CSV 格式存储数据)
ENV CMAKE_WITH_CSV_STORAGE_ENGINE=1

# 启用 ARCHIVE 存储引擎 (用于数据归档和压缩)
ENV CMAKE_WITH_ARCHIVE_STORAGE_ENGINE=1

# 启用 BLACKHOLE 存储引擎 (接收但不存储数据，用于日志记录和复制)
ENV CMAKE_WITH_BLACKHOLE_STORAGE_ENGINE=1

# 启用 FEDERATED 存储引擎 (访问远程 MySQL 服务器上的表)
ENV CMAKE_WITH_FEDERATED_STORAGE_ENGINE=1

# --- 功能特性配置 ---
# 允许 CMake 自动下载缺失的依赖
ENV CMAKE_ENABLE_DOWNLOADS=1

# SSL/TLS 支持 (使用系统提供的 OpenSSL 库)
ENV CMAKE_WITH_SSL=system

# 数据压缩支持 (使用系统提供的 zlib 库)
ENV CMAKE_WITH_ZLIB=system

# TCP Wrapper 支持 (0=禁用，用于访问控制)
ENV CMAKE_WITH_LIBWRAP=0

# MySQL X Protocol 支持 (启用文档存储和新协议)
ENV CMAKE_WITH_MYSQLX=1

# 单元测试 (0=禁用，减少编译时间和空间)
ENV CMAKE_WITH_UNIT_TESTS=0

# 嵌入式服务器 (0=禁用，不编译 libmysqld)
ENV CMAKE_WITH_EMBEDDED_SERVER=0

# 启用 LOCAL INFILE 功能 (允许从客户端加载本地文件)
ENV CMAKE_ENABLED_LOCAL_INFILE=1

# --- 性能和调试配置 ---
# 调试模式 (0=禁用，生产环境建议禁用)
ENV CMAKE_WITH_DEBUG=0

# Valgrind 内存检测工具支持 (0=禁用)
ENV CMAKE_WITH_VALGRIND=0

# 性能分析 (0=禁用)
ENV CMAKE_ENABLE_PROFILING=0

# 代码覆盖率测试 (0=禁用)
ENV CMAKE_ENABLE_GCOV=0

# --- 字符集和排序规则配置 ---
# 默认字符集 (utf8mb4 支持完整的 Unicode，包括 emoji)
ENV CMAKE_DEFAULT_CHARSET=utf8mb4

# 默认排序规则 (utf8mb4_unicode_ci 提供更准确的排序)
ENV CMAKE_DEFAULT_COLLATION=utf8mb4_unicode_ci

# --- 构建类型和其他选项 ---
# 构建类型 (RelWithDebInfo = 发布版本 + 调试信息)
ENV CMAKE_BUILD_TYPE=RelWithDebInfo

# 允许源码目录内构建 (1=允许)
ENV CMAKE_FORCE_INSOURCE_BUILD=1

# CMake 系统配置目录
ENV CMAKE_SYSCONFDIR=/etc/mysql

# --- 编译并行度配置 ---
# CPU 核心数 (动态获取，用于并行编译)
# 此变量在运行时通过 nproc 命令动态设置

# 内存限制因子 (用于根据可用内存调整编译并行度)
# 每个编译线程大约需要 1.5GB 内存
ENV COMPILE_MEMORY_PER_JOB=1536

# ============================================================================
# Supervisor 配置变量
# ============================================================================

# Supervisor 程序名称
ENV SUPERVISOR_PROGRAM_NAME=mysql-server

# Supervisor 日志目录
ENV SUPERVISOR_LOGDIR=/var/log/supervisor

# Supervisor 自动启动配置
ENV SUPERVISOR_AUTOSTART=true

# Supervisor 自动重启配置
ENV SUPERVISOR_AUTORESTART=true

# Supervisor 启动重试次数
ENV SUPERVISOR_STARTRETRIES=3

# Supervisor 停止信号
ENV SUPERVISOR_STOPSIGNAL=TERM

# Supervisor 停止等待时间(秒)
ENV SUPERVISOR_STOPWAITSECS=30

# Supervisor 停止等待时间(秒)
ENV SUPERVISOR_STOPWAITSECS=30

# ============================================================================
# 阶段 1: 安装编译依赖和工具
# ============================================================================

# 更新软件包索引并安装 MySQL 编译所需的全部依赖
RUN echo "============================================" && \
    echo "开始安装编译依赖..." && \
    echo "============================================" && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
    # --- 编译工具链 ---
    build-essential \
    cmake \
    make \
    gcc \
    g++ \
    # --- 下载工具 ---
    wget \
    curl \
    ca-certificates \
    # --- MySQL 核心编译依赖 ---
    libssl-dev \
    libncurses5-dev \
    libncursesw5-dev \
    zlib1g-dev \
    libevent-dev \
    libreadline-dev \
    # --- Boost 库依赖 (MySQL 8.0 依赖) ---
    libboost-all-dev \
    # --- 其他必要系统库 ---
    libnuma-dev \
    libaio-dev \
    libmecab-dev \
    libtirpc-dev \
    librpc-dev \
    # --- 系统构建工具 ---
    pkg-config \
    bison \
    flex \
    # --- Supervisor 进程管理工具 ---
    supervisor \
    # --- 系统监控和资源管理工具 ---
    procps \
    sysstat \
    && echo "依赖安装完成" && \
    # 清理 APT 缓存，减少镜像体积
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    echo "APT 缓存清理完成"

# ============================================================================
# 阶段 2: 创建 MySQL 系统用户和组
# ============================================================================

# 创建专用的 MySQL 系统用户和组，用于运行 MySQL 服务
RUN echo "============================================" && \
    echo "创建 MySQL 用户和组..." && \
    echo "============================================" && \
    # 创建 MySQL 组
    groupadd -r -g ${MYSQL_GID} ${MYSQL_GROUP} && \
    echo "MySQL 组创建成功: ${MYSQL_GROUP} (GID: ${MYSQL_GID})" && \
    # 创建 MySQL 用户
    useradd -r -u ${MYSQL_UID} -g ${MYSQL_GROUP} -s /bin/false \
    -c "MySQL Server" ${MYSQL_USER} && \
    echo "MySQL 用户创建成功: ${MYSQL_USER} (UID: ${MYSQL_UID})"

# ============================================================================
# 阶段 3: 创建目录结构
# ============================================================================

# 创建 MySQL 运行所需的所有目录
RUN echo "============================================" && \
    echo "创建目录结构..." && \
    echo "============================================" && \
    mkdir -p \
    ${MYSQL_PREFIX} \
    ${MYSQL_DATADIR} \
    ${MYSQL_LOGDIR} \
    ${MYSQL_RUNDIR} \
    ${MYSQL_CONFDIR} \
    ${SUPERVISOR_CONFDIR} \
    ${SUPERVISOR_LOGDIR} \
    ${BUILD_TMPDIR} && \
    echo "目录创建完成" && \
    # 设置目录所有权和权限
    chown -R ${MYSQL_USER}:${MYSQL_GROUP} \
    ${MYSQL_DATADIR} \
    ${MYSQL_LOGDIR} \
    ${MYSQL_RUNDIR} && \
    echo "目录权限设置完成"

# ============================================================================
# 阶段 4: 下载并解压 MySQL 源码
# ============================================================================

# 切换到临时构建目录
WORKDIR ${BUILD_TMPDIR}

# 下载 MySQL 源代码并解压
RUN echo "============================================" && \
    echo "下载 MySQL ${MYSQL_VERSION} 源码..." && \
    echo "下载地址: ${MYSQL_DOWNLOAD_URL}" && \
    echo "============================================" && \
    wget --progress=bar:force:noscroll -O mysql-${MYSQL_VERSION}.tar.gz ${MYSQL_DOWNLOAD_URL} && \
    echo "源码下载完成，文件大小: $(du -h mysql-${MYSQL_VERSION}.tar.gz | cut -f1)" && \
    echo "开始解压源码..." && \
    tar -xzf mysql-${MYSQL_VERSION}.tar.gz && \
    echo "源码解压完成" && \
    # 删除压缩包以节省空间
    rm -f mysql-${MYSQL_VERSION}.tar.gz && \
    echo "已清理源码压缩包"

# ============================================================================
# 阶段 5: 下载并准备 Boost 库
# ============================================================================

# 切换到 MySQL 源码目录
WORKDIR ${BUILD_TMPDIR}/mysql-${MYSQL_VERSION}

# 下载 Boost 库 (MySQL 8.0.43 编译必需依赖)
RUN echo "============================================" && \
    echo "下载 Boost ${BOOST_VERSION} 库..." && \
    echo "下载地址: ${BOOST_DOWNLOAD_URL}" && \
    echo "============================================" && \
    mkdir -p boost && \
    cd boost && \
    wget --progress=bar:force:noscroll -O boost_${BOOST_VERSION_UNDERSCORED}.tar.gz ${BOOST_DOWNLOAD_URL} && \
    echo "Boost 库下载完成，文件大小: $(du -h boost_${BOOST_VERSION_UNDERSCORED}.tar.gz | cut -f1)" && \
    echo "开始解压 Boost 库..." && \
    tar -xzf boost_${BOOST_VERSION_UNDERSCORED}.tar.gz && \
    echo "Boost 库解压完成" && \
    # 删除压缩包以节省空间
    rm -f boost_${BOOST_VERSION_UNDERSCORED}.tar.gz && \
    echo "已清理 Boost 压缩包"

# ============================================================================
# 阶段 6: 配置 MySQL 编译选项 (CMake)
# ============================================================================

# 配置 MySQL 编译参数
# 此阶段会检查系统依赖并生成 Makefile
RUN echo "============================================" && \
    echo "配置 MySQL 编译选项..." && \
    echo "============================================" && \
    # 显示系统资源信息
    echo "系统 CPU 核心数: $(nproc)" && \
    echo "系统总内存: $(free -h | awk '/^Mem:/ {print $2}')" && \
    echo "可用内存: $(free -h | awk '/^Mem:/ {print $7}')" && \
    echo "============================================" && \
    cmake . \
    # --- 基本路径配置 ---
    -DCMAKE_INSTALL_PREFIX=${MYSQL_PREFIX} \
    -DMYSQL_DATADIR=${MYSQL_DATADIR} \
    -DSYSCONFDIR=${CMAKE_SYSCONFDIR} \
    -DMYSQL_UNIX_ADDR=${MYSQL_RUNDIR}/mysqld.sock \
    # --- 存储引擎配置 ---
    -DWITH_INNOBASE_STORAGE_ENGINE=${CMAKE_WITH_INNOBASE_STORAGE_ENGINE} \
    -DWITH_PARTITION_STORAGE_ENGINE=${CMAKE_WITH_PARTITION_STORAGE_ENGINE} \
    -DWITH_MYISAM_STORAGE_ENGINE=${CMAKE_WITH_MYISAM_STORAGE_ENGINE} \
    -DWITH_MEMORY_STORAGE_ENGINE=${CMAKE_WITH_MEMORY_STORAGE_ENGINE} \
    -DWITH_CSV_STORAGE_ENGINE=${CMAKE_WITH_CSV_STORAGE_ENGINE} \
    -DWITH_ARCHIVE_STORAGE_ENGINE=${CMAKE_WITH_ARCHIVE_STORAGE_ENGINE} \
    -DWITH_BLACKHOLE_STORAGE_ENGINE=${CMAKE_WITH_BLACKHOLE_STORAGE_ENGINE} \
    -DWITH_FEDERATED_STORAGE_ENGINE=${CMAKE_WITH_FEDERATED_STORAGE_ENGINE} \
    # --- 功能特性配置 ---
    -DENABLED_LOCAL_INFILE=${CMAKE_ENABLED_LOCAL_INFILE} \
    -DWITH_SSL=${CMAKE_WITH_SSL} \
    -DWITH_ZLIB=${CMAKE_WITH_ZLIB} \
    -DWITH_LIBWRAP=${CMAKE_WITH_LIBWRAP} \
    -DWITH_MYSQLX=${CMAKE_WITH_MYSQLX} \
    -DWITH_UNIT_TESTS=${CMAKE_WITH_UNIT_TESTS} \
    -DWITH_EMBEDDED_SERVER=${CMAKE_WITH_EMBEDDED_SERVER} \
    # --- 字符集配置 ---
    -DDEFAULT_CHARSET=${CMAKE_DEFAULT_CHARSET} \
    -DDEFAULT_COLLATION=${CMAKE_DEFAULT_COLLATION} \
    # --- 性能和调试配置 ---
    -DWITH_DEBUG=${CMAKE_WITH_DEBUG} \
    -DWITH_VALGRIND=${CMAKE_WITH_VALGRIND} \
    -DENABLE_PROFILING=${CMAKE_ENABLE_PROFILING} \
    -DENABLE_GCOV=${CMAKE_ENABLE_GCOV} \
    # --- Boost 库路径配置 ---
    -DWITH_BOOST=${BUILD_TMPDIR}/mysql-${MYSQL_VERSION}/boost/boost_${BOOST_VERSION_UNDERSCORED} \
    -DDOWNLOAD_BOOST=${CMAKE_ENABLE_DOWNLOADS} \
    # --- 构建类型配置 ---
    -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE} \
    -DFORCE_INSOURCE_BUILD=${CMAKE_FORCE_INSOURCE_BUILD} && \
    echo "============================================" && \
    echo "MySQL 配置完成" && \
    echo "============================================"

# ============================================================================
# 阶段 7: 编译 MySQL (智能并行编译)
# ============================================================================

# 编译 MySQL - 使用智能并行度控制
# 根据可用 CPU 核心数和内存自动调整编译并行度
RUN echo "============================================" && \
    echo "开始编译 MySQL ${MYSQL_VERSION}..." && \
    echo "============================================" && \
    # 获取系统资源信息
    CPU_CORES=$(nproc) && \
    TOTAL_MEM_MB=$(free -m | awk '/^Mem:/ {print $2}') && \
    # 计算基于内存的最大并行任务数 (每个任务需要约 1.5GB 内存)
    MAX_JOBS_BY_MEM=$((TOTAL_MEM_MB / COMPILE_MEMORY_PER_JOB)) && \
    # 取 CPU 核心数和内存限制的较小值
    PARALLEL_JOBS=$((CPU_CORES < MAX_JOBS_BY_MEM ? CPU_CORES : MAX_JOBS_BY_MEM)) && \
    # 至少使用 1 个线程，最多不超过 CPU 核心数
    [ ${PARALLEL_JOBS} -lt 1 ] && PARALLEL_JOBS=1 && \
    [ ${PARALLEL_JOBS} -gt ${CPU_CORES} ] && PARALLEL_JOBS=${CPU_CORES} && \
    echo "编译配置:" && \
    echo "  - CPU 核心数: ${CPU_CORES}" && \
    echo "  - 总内存: ${TOTAL_MEM_MB} MB" && \
    echo "  - 内存限制的最大并行数: ${MAX_JOBS_BY_MEM}" && \
    echo "  - 实际使用并行数: ${PARALLEL_JOBS}" && \
    echo "============================================" && \
    echo "开始编译 (预计需要 30-60 分钟，取决于系统性能)..." && \
    make -j${PARALLEL_JOBS} && \
    echo "============================================" && \
    echo "MySQL 编译完成!" && \
    echo "============================================"

# ============================================================================
# 阶段 8: 安装 MySQL 到指定目录
# ============================================================================

# 将编译好的 MySQL 安装到 ${MYSQL_PREFIX} 目录
RUN echo "============================================" && \
    echo "安装 MySQL 到 ${MYSQL_PREFIX}..." && \
    echo "============================================" && \
    make install && \
    echo "MySQL 安装完成" && \
    # 显示安装目录大小
    echo "安装目录大小: $(du -sh ${MYSQL_PREFIX} | cut -f1)" && \
    echo "============================================"

# ============================================================================
# 阶段 9: 生成 MySQL 配置文件
# ============================================================================

# 创建优化的 MySQL 配置文件 (my.cnf)
RUN echo "============================================" && \
    echo "生成 MySQL 配置文件..." && \
    echo "============================================" && \
    mkdir -p ${MYSQL_CONFDIR} && \
    echo '# ============================================================================' > ${MYSQL_CONFDIR}/my.cnf && \
    echo '# MySQL 8.0.43 服务器配置文件' >> ${MYSQL_CONFDIR}/my.cnf && \
    echo '# ============================================================================' >> ${MYSQL_CONFDIR}/my.cnf && \
    echo '# 生成时间: 2025-10-15' >> ${MYSQL_CONFDIR}/my.cnf && \
    echo '# 配置说明: 此配置适用于容器化部署的 MySQL 服务器' >> ${MYSQL_CONFDIR}/my.cnf && \
    echo '# ============================================================================' >> ${MYSQL_CONFDIR}/my.cnf && \
    echo '' >> ${MYSQL_CONFDIR}/my.cnf && \
    echo '[mysqld]' >> ${MYSQL_CONFDIR}/my.cnf && \
    echo '# --- 基本配置 ---' >> ${MYSQL_CONFDIR}/my.cnf && \
    echo '# MySQL 运行用户' >> ${MYSQL_CONFDIR}/my.cnf && \
    echo 'user = mysql' >> ${MYSQL_CONFDIR}/my.cnf && \
    echo '' >> ${MYSQL_CONFDIR}/my.cnf && \
    echo '# 监听端口号' >> ${MYSQL_CONFDIR}/my.cnf && \
    echo 'port = 3306' >> ${MYSQL_CONFDIR}/my.cnf && \
    echo '' >> ${MYSQL_CONFDIR}/my.cnf && \
    echo '# MySQL 安装根目录' >> ${MYSQL_CONFDIR}/my.cnf && \
    echo 'basedir = /SunshineCloud/MySQL-Server' >> ${MYSQL_CONFDIR}/my.cnf && \
    echo '' >> ${MYSQL_CONFDIR}/my.cnf && \
    echo '# 数据文件存储目录' >> ${MYSQL_CONFDIR}/my.cnf && \
    echo 'datadir = /SunshineCloud/MySQL-Data' >> ${MYSQL_CONFDIR}/my.cnf && \
    echo '' >> ${MYSQL_CONFDIR}/my.cnf && \
    echo '# Unix Socket 文件路径' >> ${MYSQL_CONFDIR}/my.cnf && \
    echo 'socket = /var/run/mysqld/mysqld.sock' >> ${MYSQL_CONFDIR}/my.cnf && \
    echo '' >> ${MYSQL_CONFDIR}/my.cnf && \
    echo '# 进程 PID 文件路径' >> ${MYSQL_CONFDIR}/my.cnf && \
    echo 'pid-file = /var/run/mysqld/mysqld.pid' >> ${MYSQL_CONFDIR}/my.cnf && \
    echo '' >> ${MYSQL_CONFDIR}/my.cnf && \
    echo '# 跳过主机名解析 (提高连接速度)' >> ${MYSQL_CONFDIR}/my.cnf && \
    echo 'skip-name-resolve' >> ${MYSQL_CONFDIR}/my.cnf && \
    echo '' >> ${MYSQL_CONFDIR}/my.cnf && \
    echo '# 禁用符号链接 (安全性考虑)' >> ${MYSQL_CONFDIR}/my.cnf && \
    echo 'symbolic-links = 0' >> ${MYSQL_CONFDIR}/my.cnf && \
    echo '' >> ${MYSQL_CONFDIR}/my.cnf && \
    echo '# --- 字符集和排序规则配置 ---' >> ${MYSQL_CONFDIR}/my.cnf && \
    echo '# 服务器字符集' >> ${MYSQL_CONFDIR}/my.cnf && \
    echo 'character-set-server = utf8mb4' >> ${MYSQL_CONFDIR}/my.cnf && \
    echo '' >> ${MYSQL_CONFDIR}/my.cnf && \
    echo '# 服务器排序规则' >> ${MYSQL_CONFDIR}/my.cnf && \
    echo 'collation-server = utf8mb4_unicode_ci' >> ${MYSQL_CONFDIR}/my.cnf && \
    echo '' >> ${MYSQL_CONFDIR}/my.cnf && \
    echo '# 初始化连接字符集' >> ${MYSQL_CONFDIR}/my.cnf && \
    echo 'init_connect = "SET NAMES utf8mb4"' >> ${MYSQL_CONFDIR}/my.cnf && \
    echo '' >> ${MYSQL_CONFDIR}/my.cnf && \
    echo '# --- 网络和连接配置 ---' >> ${MYSQL_CONFDIR}/my.cnf && \
    echo '# 最大连接数' >> ${MYSQL_CONFDIR}/my.cnf && \
    echo 'max_connections = 200' >> ${MYSQL_CONFDIR}/my.cnf && \
    echo '' >> ${MYSQL_CONFDIR}/my.cnf && \
    echo '# 最大连接错误次数' >> ${MYSQL_CONFDIR}/my.cnf && \
    echo 'max_connect_errors = 100' >> ${MYSQL_CONFDIR}/my.cnf && \
    echo '' >> ${MYSQL_CONFDIR}/my.cnf && \
    echo '# 连接超时时间 (秒)' >> ${MYSQL_CONFDIR}/my.cnf && \
    echo 'connect_timeout = 10' >> ${MYSQL_CONFDIR}/my.cnf && \
    echo '' >> ${MYSQL_CONFDIR}/my.cnf && \
    echo '# 等待超时时间 (秒)' >> ${MYSQL_CONFDIR}/my.cnf && \
    echo 'wait_timeout = 28800' >> ${MYSQL_CONFDIR}/my.cnf && \
    echo '' >> ${MYSQL_CONFDIR}/my.cnf && \
    echo '# 交互式超时时间 (秒)' >> ${MYSQL_CONFDIR}/my.cnf && \
    echo 'interactive_timeout = 28800' >> ${MYSQL_CONFDIR}/my.cnf && \
    echo '' >> ${MYSQL_CONFDIR}/my.cnf && \
    echo '# 最大允许的数据包大小 (64MB)' >> ${MYSQL_CONFDIR}/my.cnf && \
    echo 'max_allowed_packet = 64M' >> ${MYSQL_CONFDIR}/my.cnf && \
    echo '' >> ${MYSQL_CONFDIR}/my.cnf && \
    echo '# --- 日志配置 ---' >> ${MYSQL_CONFDIR}/my.cnf && \
    echo '# 错误日志路径' >> ${MYSQL_CONFDIR}/my.cnf && \
    echo 'log-error = /var/log/mysql/error.log' >> ${MYSQL_CONFDIR}/my.cnf && \
    echo '' >> ${MYSQL_CONFDIR}/my.cnf && \
    echo '# 启用慢查询日志' >> ${MYSQL_CONFDIR}/my.cnf && \
    echo 'slow_query_log = 1' >> ${MYSQL_CONFDIR}/my.cnf && \
    echo '' >> ${MYSQL_CONFDIR}/my.cnf && \
    echo '# 慢查询日志文件路径' >> ${MYSQL_CONFDIR}/my.cnf && \
    echo 'slow_query_log_file = /var/log/mysql/slow.log' >> ${MYSQL_CONFDIR}/my.cnf && \
    echo '' >> ${MYSQL_CONFDIR}/my.cnf && \
    echo '# 慢查询时间阈值 (秒)' >> ${MYSQL_CONFDIR}/my.cnf && \
    echo 'long_query_time = 2' >> ${MYSQL_CONFDIR}/my.cnf && \
    echo '' >> ${MYSQL_CONFDIR}/my.cnf && \
    echo '# 通用查询日志 (生产环境建议关闭)' >> ${MYSQL_CONFDIR}/my.cnf && \
    echo 'general_log = 0' >> ${MYSQL_CONFDIR}/my.cnf && \
    echo 'general_log_file = /var/log/mysql/general.log' >> ${MYSQL_CONFDIR}/my.cnf && \
    echo '' >> ${MYSQL_CONFDIR}/my.cnf && \
    echo '# --- 二进制日志配置 ---' >> ${MYSQL_CONFDIR}/my.cnf && \
    echo '# 服务器唯一ID (用于主从复制)' >> ${MYSQL_CONFDIR}/my.cnf && \
    echo 'server-id = 1' >> ${MYSQL_CONFDIR}/my.cnf && \
    echo '' >> ${MYSQL_CONFDIR}/my.cnf && \
    echo '# 启用二进制日志' >> ${MYSQL_CONFDIR}/my.cnf && \
    echo 'log_bin = /var/log/mysql/mysql-bin' >> ${MYSQL_CONFDIR}/my.cnf && \
    echo '' >> ${MYSQL_CONFDIR}/my.cnf && \
    echo '# 二进制日志格式 (ROW 格式最安全)' >> ${MYSQL_CONFDIR}/my.cnf && \
    echo 'binlog_format = ROW' >> ${MYSQL_CONFDIR}/my.cnf && \
    echo '' >> ${MYSQL_CONFDIR}/my.cnf && \
    echo '# 二进制日志过期天数' >> ${MYSQL_CONFDIR}/my.cnf && \
    echo 'expire_logs_days = 7' >> ${MYSQL_CONFDIR}/my.cnf && \
    echo '' >> ${MYSQL_CONFDIR}/my.cnf && \
    echo '# 单个二进制日志文件最大大小' >> ${MYSQL_CONFDIR}/my.cnf && \
    echo 'max_binlog_size = 100M' >> ${MYSQL_CONFDIR}/my.cnf && \
    echo '' >> ${MYSQL_CONFDIR}/my.cnf && \
    echo '# 每次事务提交同步二进制日志到磁盘' >> ${MYSQL_CONFDIR}/my.cnf && \
    echo 'sync_binlog = 1' >> ${MYSQL_CONFDIR}/my.cnf && \
    echo '' >> ${MYSQL_CONFDIR}/my.cnf && \
    echo '# --- InnoDB 存储引擎配置 ---' >> ${MYSQL_CONFDIR}/my.cnf && \
    echo '# 默认存储引擎' >> ${MYSQL_CONFDIR}/my.cnf && \
    echo 'default-storage-engine = INNODB' >> ${MYSQL_CONFDIR}/my.cnf && \
    echo '' >> ${MYSQL_CONFDIR}/my.cnf && \
    echo '# InnoDB 缓冲池大小' >> ${MYSQL_CONFDIR}/my.cnf && \
    echo 'innodb_buffer_pool_size = 512M' >> ${MYSQL_CONFDIR}/my.cnf && \
    echo '' >> ${MYSQL_CONFDIR}/my.cnf && \
    echo '# InnoDB 日志文件大小' >> ${MYSQL_CONFDIR}/my.cnf && \
    echo 'innodb_log_file_size = 128M' >> ${MYSQL_CONFDIR}/my.cnf && \
    echo '' >> ${MYSQL_CONFDIR}/my.cnf && \
    echo '# InnoDB 日志缓冲区大小' >> ${MYSQL_CONFDIR}/my.cnf && \
    echo 'innodb_log_buffer_size = 16M' >> ${MYSQL_CONFDIR}/my.cnf && \
    echo '' >> ${MYSQL_CONFDIR}/my.cnf && \
    echo '# InnoDB 刷新日志策略' >> ${MYSQL_CONFDIR}/my.cnf && \
    echo 'innodb_flush_log_at_trx_commit = 1' >> ${MYSQL_CONFDIR}/my.cnf && \
    echo '' >> ${MYSQL_CONFDIR}/my.cnf && \
    echo '# InnoDB 数据文件刷新方法' >> ${MYSQL_CONFDIR}/my.cnf && \
    echo 'innodb_flush_method = O_DIRECT' >> ${MYSQL_CONFDIR}/my.cnf && \
    echo '' >> ${MYSQL_CONFDIR}/my.cnf && \
    echo '# InnoDB 文件每表一个文件' >> ${MYSQL_CONFDIR}/my.cnf && \
    echo 'innodb_file_per_table = 1' >> ${MYSQL_CONFDIR}/my.cnf && \
    echo '' >> ${MYSQL_CONFDIR}/my.cnf && \
    echo '# InnoDB 锁等待超时时间 (秒)' >> ${MYSQL_CONFDIR}/my.cnf && \
    echo 'innodb_lock_wait_timeout = 50' >> ${MYSQL_CONFDIR}/my.cnf && \
    echo '' >> ${MYSQL_CONFDIR}/my.cnf && \
    echo '# InnoDB IO 读线程数' >> ${MYSQL_CONFDIR}/my.cnf && \
    echo 'innodb_read_io_threads = 4' >> ${MYSQL_CONFDIR}/my.cnf && \
    echo '' >> ${MYSQL_CONFDIR}/my.cnf && \
    echo '# InnoDB IO 写线程数' >> ${MYSQL_CONFDIR}/my.cnf && \
    echo 'innodb_write_io_threads = 4' >> ${MYSQL_CONFDIR}/my.cnf && \
    echo '' >> ${MYSQL_CONFDIR}/my.cnf && \
    echo '# --- MyISAM 存储引擎配置 ---' >> ${MYSQL_CONFDIR}/my.cnf && \
    echo '# MyISAM 键缓冲区大小' >> ${MYSQL_CONFDIR}/my.cnf && \
    echo 'key_buffer_size = 32M' >> ${MYSQL_CONFDIR}/my.cnf && \
    echo '' >> ${MYSQL_CONFDIR}/my.cnf && \
    echo '# --- 临时表和内存配置 ---' >> ${MYSQL_CONFDIR}/my.cnf && \
    echo '# 临时表最大大小' >> ${MYSQL_CONFDIR}/my.cnf && \
    echo 'tmp_table_size = 64M' >> ${MYSQL_CONFDIR}/my.cnf && \
    echo '' >> ${MYSQL_CONFDIR}/my.cnf && \
    echo '# 最大堆表大小' >> ${MYSQL_CONFDIR}/my.cnf && \
    echo 'max_heap_table_size = 64M' >> ${MYSQL_CONFDIR}/my.cnf && \
    echo '' >> ${MYSQL_CONFDIR}/my.cnf && \
    echo '# 排序缓冲区大小' >> ${MYSQL_CONFDIR}/my.cnf && \
    echo 'sort_buffer_size = 2M' >> ${MYSQL_CONFDIR}/my.cnf && \
    echo '' >> ${MYSQL_CONFDIR}/my.cnf && \
    echo '# 读缓冲区大小' >> ${MYSQL_CONFDIR}/my.cnf && \
    echo 'read_buffer_size = 2M' >> ${MYSQL_CONFDIR}/my.cnf && \
    echo '' >> ${MYSQL_CONFDIR}/my.cnf && \
    echo '# Join 缓冲区大小' >> ${MYSQL_CONFDIR}/my.cnf && \
    echo 'join_buffer_size = 2M' >> ${MYSQL_CONFDIR}/my.cnf && \
    echo '' >> ${MYSQL_CONFDIR}/my.cnf && \
    echo '# 线程缓存大小' >> ${MYSQL_CONFDIR}/my.cnf && \
    echo 'thread_cache_size = 8' >> ${MYSQL_CONFDIR}/my.cnf && \
    echo '' >> ${MYSQL_CONFDIR}/my.cnf && \
    echo '# 打开表的缓存数量' >> ${MYSQL_CONFDIR}/my.cnf && \
    echo 'table_open_cache = 2000' >> ${MYSQL_CONFDIR}/my.cnf && \
    echo '' >> ${MYSQL_CONFDIR}/my.cnf && \
    echo '# --- 安全性配置 ---' >> ${MYSQL_CONFDIR}/my.cnf && \
    echo '# 本地文件导入功能' >> ${MYSQL_CONFDIR}/my.cnf && \
    echo 'local_infile = 1' >> ${MYSQL_CONFDIR}/my.cnf && \
    echo '' >> ${MYSQL_CONFDIR}/my.cnf && \
    echo '# --- 其他优化配置 ---' >> ${MYSQL_CONFDIR}/my.cnf && \
    echo '# 默认认证插件' >> ${MYSQL_CONFDIR}/my.cnf && \
    echo 'default_authentication_plugin = mysql_native_password' >> ${MYSQL_CONFDIR}/my.cnf && \
    echo '' >> ${MYSQL_CONFDIR}/my.cnf && \
    echo '# 时区设置' >> ${MYSQL_CONFDIR}/my.cnf && \
    echo 'default-time-zone = "+08:00"' >> ${MYSQL_CONFDIR}/my.cnf && \
    echo '' >> ${MYSQL_CONFDIR}/my.cnf && \
    echo '# SQL 模式' >> ${MYSQL_CONFDIR}/my.cnf && \
    echo 'sql_mode = STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' >> ${MYSQL_CONFDIR}/my.cnf && \
    echo '' >> ${MYSQL_CONFDIR}/my.cnf && \
    echo '# ============================================================================' >> ${MYSQL_CONFDIR}/my.cnf && \
    echo '# MySQL 客户端配置' >> ${MYSQL_CONFDIR}/my.cnf && \
    echo '# ============================================================================' >> ${MYSQL_CONFDIR}/my.cnf && \
    echo '' >> ${MYSQL_CONFDIR}/my.cnf && \
    echo '[mysql]' >> ${MYSQL_CONFDIR}/my.cnf && \
    echo '# 客户端默认字符集' >> ${MYSQL_CONFDIR}/my.cnf && \
    echo 'default-character-set = utf8mb4' >> ${MYSQL_CONFDIR}/my.cnf && \
    echo '' >> ${MYSQL_CONFDIR}/my.cnf && \
    echo '# 启用自动重连' >> ${MYSQL_CONFDIR}/my.cnf && \
    echo 'auto-rehash' >> ${MYSQL_CONFDIR}/my.cnf && \
    echo '' >> ${MYSQL_CONFDIR}/my.cnf && \
    echo '[client]' >> ${MYSQL_CONFDIR}/my.cnf && \
    echo '# 默认字符集' >> ${MYSQL_CONFDIR}/my.cnf && \
    echo 'default-character-set = utf8mb4' >> ${MYSQL_CONFDIR}/my.cnf && \
    echo '' >> ${MYSQL_CONFDIR}/my.cnf && \
    echo '# Socket 文件路径' >> ${MYSQL_CONFDIR}/my.cnf && \
    echo 'socket = /var/run/mysqld/mysqld.sock' >> ${MYSQL_CONFDIR}/my.cnf && \
    echo '' >> ${MYSQL_CONFDIR}/my.cnf && \
    echo '# 默认端口' >> ${MYSQL_CONFDIR}/my.cnf && \
    echo 'port = 3306' >> ${MYSQL_CONFDIR}/my.cnf && \
    echo '' >> ${MYSQL_CONFDIR}/my.cnf && \
    echo '[mysqldump]' >> ${MYSQL_CONFDIR}/my.cnf && \
    echo '# 快速导出' >> ${MYSQL_CONFDIR}/my.cnf && \
    echo 'quick' >> ${MYSQL_CONFDIR}/my.cnf && \
    echo '' >> ${MYSQL_CONFDIR}/my.cnf && \
    echo '# 导出时显示列名' >> ${MYSQL_CONFDIR}/my.cnf && \
    echo 'quote-names' >> ${MYSQL_CONFDIR}/my.cnf && \
    echo '' >> ${MYSQL_CONFDIR}/my.cnf && \
    echo '# 最大允许的数据包大小' >> ${MYSQL_CONFDIR}/my.cnf && \
    echo 'max_allowed_packet = 64M' >> ${MYSQL_CONFDIR}/my.cnf && \
    echo '' >> ${MYSQL_CONFDIR}/my.cnf && \
    echo '# 默认字符集' >> ${MYSQL_CONFDIR}/my.cnf && \
    echo 'default-character-set = utf8mb4' >> ${MYSQL_CONFDIR}/my.cnf && \
    echo "MySQL 配置文件生成完成: ${MYSQL_CONFDIR}/my.cnf" && \
    echo "============================================"

# ============================================================================
# 阶段 10: 生成 Supervisor 配置文件
# ============================================================================

# 创建 Supervisor 配置文件用于管理 MySQL 进程
RUN echo "============================================" && \
    echo "生成 Supervisor 配置文件..." && \
    echo "============================================" && \
    mkdir -p ${SUPERVISOR_CONFDIR} ${SUPERVISOR_LOGDIR} && \
    echo '# ============================================================================' > ${SUPERVISOR_CONFDIR}/mysql.conf && \
    echo '# Supervisor MySQL 进程管理配置文件' >> ${SUPERVISOR_CONFDIR}/mysql.conf && \
    echo '# ============================================================================' >> ${SUPERVISOR_CONFDIR}/mysql.conf && \
    echo '# 生成时间: 2025-10-15' >> ${SUPERVISOR_CONFDIR}/mysql.conf && \
    echo '# 程序名称: mysql-server' >> ${SUPERVISOR_CONFDIR}/mysql.conf && \
    echo '# 说明: 此配置用于通过 Supervisor 管理 MySQL 服务器进程' >> ${SUPERVISOR_CONFDIR}/mysql.conf && \
    echo '# ============================================================================' >> ${SUPERVISOR_CONFDIR}/mysql.conf && \
    echo '' >> ${SUPERVISOR_CONFDIR}/mysql.conf && \
    echo '[program:mysql-server]' >> ${SUPERVISOR_CONFDIR}/mysql.conf && \
    echo '# --- 基本配置 ---' >> ${SUPERVISOR_CONFDIR}/mysql.conf && \
    echo '# 执行命令: 以 mysql 用户身份运行 mysqld' >> ${SUPERVISOR_CONFDIR}/mysql.conf && \
    echo 'command=/SunshineCloud/MySQL-Server/bin/mysqld --defaults-file=/etc/mysql/my.cnf --user=mysql --console' >> ${SUPERVISOR_CONFDIR}/mysql.conf && \
    echo '' >> ${SUPERVISOR_CONFDIR}/mysql.conf && \
    echo '# 工作目录' >> ${SUPERVISOR_CONFDIR}/mysql.conf && \
    echo 'directory=/SunshineCloud/MySQL-Server' >> ${SUPERVISOR_CONFDIR}/mysql.conf && \
    echo '' >> ${SUPERVISOR_CONFDIR}/mysql.conf && \
    echo '# 运行用户' >> ${SUPERVISOR_CONFDIR}/mysql.conf && \
    echo 'user=mysql' >> ${SUPERVISOR_CONFDIR}/mysql.conf && \
    echo '' >> ${SUPERVISOR_CONFDIR}/mysql.conf && \
    echo '# --- 自动启动配置 ---' >> ${SUPERVISOR_CONFDIR}/mysql.conf && \
    echo '# 是否随 Supervisor 自动启动' >> ${SUPERVISOR_CONFDIR}/mysql.conf && \
    echo 'autostart=true' >> ${SUPERVISOR_CONFDIR}/mysql.conf && \
    echo '' >> ${SUPERVISOR_CONFDIR}/mysql.conf && \
    echo '# 是否自动重启' >> ${SUPERVISOR_CONFDIR}/mysql.conf && \
    echo 'autorestart=true' >> ${SUPERVISOR_CONFDIR}/mysql.conf && \
    echo '' >> ${SUPERVISOR_CONFDIR}/mysql.conf && \
    echo '# 启动重试次数' >> ${SUPERVISOR_CONFDIR}/mysql.conf && \
    echo 'startretries=3' >> ${SUPERVISOR_CONFDIR}/mysql.conf && \
    echo '' >> ${SUPERVISOR_CONFDIR}/mysql.conf && \
    echo '# 启动等待时间 (秒)' >> ${SUPERVISOR_CONFDIR}/mysql.conf && \
    echo 'startsecs=10' >> ${SUPERVISOR_CONFDIR}/mysql.conf && \
    echo '' >> ${SUPERVISOR_CONFDIR}/mysql.conf && \
    echo '# --- 停止配置 ---' >> ${SUPERVISOR_CONFDIR}/mysql.conf && \
    echo '# 停止信号' >> ${SUPERVISOR_CONFDIR}/mysql.conf && \
    echo 'stopsignal=TERM' >> ${SUPERVISOR_CONFDIR}/mysql.conf && \
    echo '' >> ${SUPERVISOR_CONFDIR}/mysql.conf && \
    echo '# 停止等待时间 (秒)' >> ${SUPERVISOR_CONFDIR}/mysql.conf && \
    echo 'stopwaitsecs=30' >> ${SUPERVISOR_CONFDIR}/mysql.conf && \
    echo '' >> ${SUPERVISOR_CONFDIR}/mysql.conf && \
    echo '# 停止进程组' >> ${SUPERVISOR_CONFDIR}/mysql.conf && \
    echo 'stopasgroup=true' >> ${SUPERVISOR_CONFDIR}/mysql.conf && \
    echo 'killasgroup=true' >> ${SUPERVISOR_CONFDIR}/mysql.conf && \
    echo '' >> ${SUPERVISOR_CONFDIR}/mysql.conf && \
    echo '# --- 日志配置 ---' >> ${SUPERVISOR_CONFDIR}/mysql.conf && \
    echo '# 标准输出日志文件' >> ${SUPERVISOR_CONFDIR}/mysql.conf && \
    echo 'stdout_logfile=/var/log/supervisor/mysql-stdout.log' >> ${SUPERVISOR_CONFDIR}/mysql.conf && \
    echo '' >> ${SUPERVISOR_CONFDIR}/mysql.conf && \
    echo '# 标准输出日志文件最大大小' >> ${SUPERVISOR_CONFDIR}/mysql.conf && \
    echo 'stdout_logfile_maxbytes=50MB' >> ${SUPERVISOR_CONFDIR}/mysql.conf && \
    echo '' >> ${SUPERVISOR_CONFDIR}/mysql.conf && \
    echo '# 标准输出日志文件备份数量' >> ${SUPERVISOR_CONFDIR}/mysql.conf && \
    echo 'stdout_logfile_backups=10' >> ${SUPERVISOR_CONFDIR}/mysql.conf && \
    echo '' >> ${SUPERVISOR_CONFDIR}/mysql.conf && \
    echo '# 标准错误日志文件' >> ${SUPERVISOR_CONFDIR}/mysql.conf && \
    echo 'stderr_logfile=/var/log/supervisor/mysql-stderr.log' >> ${SUPERVISOR_CONFDIR}/mysql.conf && \
    echo '' >> ${SUPERVISOR_CONFDIR}/mysql.conf && \
    echo '# 标准错误日志文件最大大小' >> ${SUPERVISOR_CONFDIR}/mysql.conf && \
    echo 'stderr_logfile_maxbytes=50MB' >> ${SUPERVISOR_CONFDIR}/mysql.conf && \
    echo '' >> ${SUPERVISOR_CONFDIR}/mysql.conf && \
    echo '# 标准错误日志文件备份数量' >> ${SUPERVISOR_CONFDIR}/mysql.conf && \
    echo 'stderr_logfile_backups=10' >> ${SUPERVISOR_CONFDIR}/mysql.conf && \
    echo '' >> ${SUPERVISOR_CONFDIR}/mysql.conf && \
    echo '# --- 进程优先级 ---' >> ${SUPERVISOR_CONFDIR}/mysql.conf && \
    echo '# 启动优先级' >> ${SUPERVISOR_CONFDIR}/mysql.conf && \
    echo 'priority=10' >> ${SUPERVISOR_CONFDIR}/mysql.conf && \
    echo '' >> ${SUPERVISOR_CONFDIR}/mysql.conf && \
    echo '# --- 环境变量 ---' >> ${SUPERVISOR_CONFDIR}/mysql.conf && \
    echo '# 设置环境变量' >> ${SUPERVISOR_CONFDIR}/mysql.conf && \
    echo 'environment=MYSQL_HOME="/SunshineCloud/MySQL-Server",PATH="/SunshineCloud/MySQL-Server/bin:%(ENV_PATH)s"' >> ${SUPERVISOR_CONFDIR}/mysql.conf && \
    echo '' >> ${SUPERVISOR_CONFDIR}/mysql.conf && \
    echo '# --- 其他配置 ---' >> ${SUPERVISOR_CONFDIR}/mysql.conf && \
    echo '# 退出代码' >> ${SUPERVISOR_CONFDIR}/mysql.conf && \
    echo 'exitcodes=0,2' >> ${SUPERVISOR_CONFDIR}/mysql.conf && \
    echo "Supervisor 配置文件生成完成: ${SUPERVISOR_CONFDIR}/mysql.conf" && \
    echo "============================================"

# ============================================================================
# 阶段 11: 设置 PATH 环境变量
# ============================================================================

# 将 MySQL 二进制文件目录添加到系统 PATH
ENV PATH=${MYSQL_PREFIX}/bin:$PATH

# ============================================================================
# 阶段 12: 初始化 MySQL 数据库
# ============================================================================

# 初始化 MySQL 数据目录和系统数据库
RUN echo "============================================" && \
    echo "初始化 MySQL 数据库..." && \
    echo "============================================" && \
    # 使用 mysqld --initialize-insecure 初始化数据库 (root 用户无密码)
    ${MYSQL_PREFIX}/bin/mysqld \
    --defaults-file=${MYSQL_CONFDIR}/my.cnf \
    --initialize-insecure \
    --user=${MYSQL_USER} \
    --basedir=${MYSQL_PREFIX} \
    --datadir=${MYSQL_DATADIR} && \
    echo "MySQL 数据库初始化完成" && \
    echo "注意: root 用户初始密码为空，请在首次启动后立即修改" && \
    echo "============================================"

# ============================================================================
# 阶段 13: 创建容器启动脚本
# ============================================================================

# ============================================================================
# 构建完成
# ============================================================================
# 
# 构建命令:
#   docker build -t sunshinecloud/mysql:8.0.43 .
#
# 运行命令:
#   docker run -d \
#     --name mysql-server \
#     -p 3306:3306 \
#     -v mysql-data:/SunshineCloud/MySQL-Data \
#     -v mysql-logs:/var/log/mysql \
#     -e TZ=Asia/Shanghai \
#     sunshinecloud/mysql:8.0.43
#
# 进入容器:
#   docker exec -it mysql-server bash
#
# 连接 MySQL:
#   docker exec -it mysql-server mysql -uroot
#
# 查看日志:
#   docker logs mysql-server
#   docker exec -it mysql-server tail -f /var/log/mysql/error.log
#
# 管理 Supervisor:
#   docker exec -it mysql-server supervisorctl status
#   docker exec -it mysql-server supervisorctl restart mysql-server
#
# ============================================================================
