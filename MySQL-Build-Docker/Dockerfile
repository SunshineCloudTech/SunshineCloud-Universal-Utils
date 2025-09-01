# MySQL 源码编译 Dockerfile
# 基于 buildpack-deps 构建 MySQL 服务器
ARG VARIANT="bookworm"
FROM buildpack-deps:${VARIANT}-curl

# 设置非交互式安装，避免安装过程中的交互提示
ENV DEBIAN_FRONTEND=noninteractive

# MySQL 版本配置
ENV MYSQL_VERSION=8.0.35
ENV MYSQL_DOWNLOAD_URL=https://dev.mysql.com/get/Downloads/MySQL-8.0/mysql-${MYSQL_VERSION}.tar.gz

# MySQL 用户和组配置
ENV MYSQL_USER=mysql
ENV MYSQL_GROUP=mysql
ENV MYSQL_UID=999
ENV MYSQL_GID=999

# MySQL 安装路径配置
ENV MYSQL_PREFIX=/SunshineCloud/MySQL-Server
ENV MYSQL_DATADIR=/SunshineCloud/MySQL-Data
ENV MYSQL_LOGDIR=/var/log/mysql
ENV MYSQL_RUNDIR=/var/run/mysqld

# MySQL 编译选项配置 - 使用环境变量便于定制
# 存储引擎相关选项
ENV CMAKE_WITH_INNOBASE_STORAGE_ENGINE=1
ENV CMAKE_WITH_PARTITION_STORAGE_ENGINE=1
ENV CMAKE_WITH_MYISAM_STORAGE_ENGINE=1
ENV CMAKE_WITH_MEMORY_STORAGE_ENGINE=1
ENV CMAKE_WITH_CSV_STORAGE_ENGINE=1
ENV CMAKE_WITH_ARCHIVE_STORAGE_ENGINE=1
ENV CMAKE_WITH_BLACKHOLE_STORAGE_ENGINE=1
ENV CMAKE_WITH_FEDERATED_STORAGE_ENGINE=1

# 功能特性选项
ENV CMAKE_ENABLE_DOWNLOADS=1
ENV CMAKE_WITH_SSL=system
ENV CMAKE_WITH_ZLIB=system
ENV CMAKE_WITH_LIBWRAP=0
ENV CMAKE_WITH_MYSQLX=1
ENV CMAKE_WITH_UNIT_TESTS=0
ENV CMAKE_WITH_EMBEDDED_SERVER=0

# 性能和调试选项
ENV CMAKE_WITH_DEBUG=0
ENV CMAKE_WITH_VALGRIND=0
ENV CMAKE_ENABLE_PROFILING=0
ENV CMAKE_ENABLE_GCOV=0

# 字符集和排序规则
ENV CMAKE_DEFAULT_CHARSET=utf8mb4
ENV CMAKE_DEFAULT_COLLATION=utf8mb4_unicode_ci

# 其他编译选项
ENV CMAKE_FORCE_INSOURCE_BUILD=1
ENV CMAKE_BUILD_TYPE=RelWithDebInfo

# 更新包管理器并安装基础依赖
RUN apt-get update && \
    apt-get install -y \
    # 编译工具链
    build-essential \
    cmake \
    make \
    gcc \
    g++ \
    # 下载工具
    wget \
    curl \
    # MySQL 编译依赖
    libssl-dev \
    libncurses5-dev \
    libncursesw5-dev \
    zlib1g-dev \
    libevent-dev \
    libreadline-dev \
    # Boost 库依赖
    libboost-all-dev \
    # 其他必要库
    libnuma-dev \
    libaio-dev \
    libmecab-dev \
    # 系统工具
    pkg-config \
    bison \
    # 清理包缓存
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# 创建 MySQL 用户和组
RUN groupadd -r -g ${MYSQL_GID} ${MYSQL_GROUP} && \
    useradd -r -u ${MYSQL_UID} -g ${MYSQL_GROUP} -s /bin/false \
    -c "MySQL Server" ${MYSQL_USER}

# 创建必要的目录结构
RUN mkdir -p ${MYSQL_PREFIX} \
             ${MYSQL_DATADIR} \
             ${MYSQL_LOGDIR} \
             ${MYSQL_RUNDIR} \
             /tmp/mysql-build && \
    # 设置目录权限
    chown -R ${MYSQL_USER}:${MYSQL_GROUP} ${MYSQL_DATADIR} \
                                          ${MYSQL_LOGDIR} \
                                          ${MYSQL_RUNDIR}

# 设置工作目录
WORKDIR /tmp/mysql-build

# 下载 MySQL 源码
RUN echo "正在下载 MySQL ${MYSQL_VERSION} 源码..." && \
    wget -O mysql-${MYSQL_VERSION}.tar.gz ${MYSQL_DOWNLOAD_URL} && \
    echo "源码下载完成，开始解压..." && \
    tar -xzf mysql-${MYSQL_VERSION}.tar.gz && \
    cd mysql-${MYSQL_VERSION} && \
    echo "源码解压完成"

# 切换到源码目录
WORKDIR /tmp/mysql-build/mysql-${MYSQL_VERSION}

# 下载 Boost 库（MySQL 8.0 需要特定版本的 Boost）
RUN echo "正在下载 Boost 库..." && \
    mkdir boost && cd boost && \
    wget -O boost_1_77_0.tar.gz https://sourceforge.net/projects/boost/files/boost/1.77.0/boost_1_77_0.tar.gz/download && \
    tar -xzf boost_1_77_0.tar.gz && \
    echo "Boost 库下载完成"

# 配置编译选项
RUN echo "开始配置 MySQL 编译选项..." && \
    cmake . \
    # 基本安装路径配置
    -DCMAKE_INSTALL_PREFIX=${MYSQL_PREFIX} \
    -DMYSQL_DATADIR=${MYSQL_DATADIR} \
    -DSYSCONFDIR=/etc/mysql \
    -DMYSQL_UNIX_ADDR=${MYSQL_RUNDIR}/mysqld.sock \
    # 存储引擎配置
    -DWITH_INNOBASE_STORAGE_ENGINE=${CMAKE_WITH_INNOBASE_STORAGE_ENGINE} \
    -DWITH_PARTITION_STORAGE_ENGINE=${CMAKE_WITH_PARTITION_STORAGE_ENGINE} \
    -DWITH_MYISAM_STORAGE_ENGINE=${CMAKE_WITH_MYISAM_STORAGE_ENGINE} \
    -DWITH_MEMORY_STORAGE_ENGINE=${CMAKE_WITH_MEMORY_STORAGE_ENGINE} \
    -DWITH_CSV_STORAGE_ENGINE=${CMAKE_WITH_CSV_STORAGE_ENGINE} \
    -DWITH_ARCHIVE_STORAGE_ENGINE=${CMAKE_WITH_ARCHIVE_STORAGE_ENGINE} \
    -DWITH_BLACKHOLE_STORAGE_ENGINE=${CMAKE_WITH_BLACKHOLE_STORAGE_ENGINE} \
    -DWITH_FEDERATED_STORAGE_ENGINE=${CMAKE_WITH_FEDERATED_STORAGE_ENGINE} \
    # 功能特性配置
    -DENABLED_LOCAL_INFILE=1 \
    -DWITH_SSL=${CMAKE_WITH_SSL} \
    -DWITH_ZLIB=${CMAKE_WITH_ZLIB} \
    -DWITH_LIBWRAP=${CMAKE_WITH_LIBWRAP} \
    -DWITH_MYSQLX=${CMAKE_WITH_MYSQLX} \
    -DWITH_UNIT_TESTS=${CMAKE_WITH_UNIT_TESTS} \
    -DWITH_EMBEDDED_SERVER=${CMAKE_WITH_EMBEDDED_SERVER} \
    # 字符集配置
    -DDEFAULT_CHARSET=${CMAKE_DEFAULT_CHARSET} \
    -DDEFAULT_COLLATION=${CMAKE_DEFAULT_COLLATION} \
    # 性能和调试配置
    -DWITH_DEBUG=${CMAKE_WITH_DEBUG} \
    -DWITH_VALGRIND=${CMAKE_WITH_VALGRIND} \
    -DENABLE_PROFILING=${CMAKE_ENABLE_PROFILING} \
    -DENABLE_GCOV=${CMAKE_ENABLE_GCOV} \
    # Boost 库路径
    -DWITH_BOOST=/tmp/mysql-build/mysql-${MYSQL_VERSION}/boost/boost_1_77_0 \
    -DDOWNLOAD_BOOST=${CMAKE_ENABLE_DOWNLOADS} \
    # 构建类型
    -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE} \
    -DFORCE_INSOURCE_BUILD=${CMAKE_FORCE_INSOURCE_BUILD} && \
    echo "MySQL 配置完成"

# 编译 MySQL（使用多核编译加速）
RUN echo "开始编译 MySQL，这可能需要较长时间..." && \
    make -j$(nproc) && \
    echo "MySQL 编译完成"

# 安装 MySQL
RUN echo "开始安装 MySQL..." && \
    make install && \
    echo "MySQL 安装完成"

# 创建 MySQL 配置文件
RUN mkdir -p /etc/mysql && \
    echo '[mysqld]' > /etc/mysql/my.cnf && \
    echo '# 基本配置' >> /etc/mysql/my.cnf && \
    echo 'user = mysql' >> /etc/mysql/my.cnf && \
    echo 'port = 3306' >> /etc/mysql/my.cnf && \
    echo 'basedir = /SunshineCloud/MySQL-Server' >> /etc/mysql/my.cnf && \
    echo 'datadir = /SunshineCloud/MySQL-Data' >> /etc/mysql/my.cnf && \
    echo 'socket = /var/run/mysqld/mysqld.sock' >> /etc/mysql/my.cnf && \
    echo 'pid-file = /var/run/mysqld/mysqld.pid' >> /etc/mysql/my.cnf && \
    echo '' >> /etc/mysql/my.cnf && \
    echo '# 字符集配置' >> /etc/mysql/my.cnf && \
    echo 'character-set-server = utf8mb4' >> /etc/mysql/my.cnf && \
    echo 'collation-server = utf8mb4_unicode_ci' >> /etc/mysql/my.cnf && \
    echo '' >> /etc/mysql/my.cnf && \
    echo '# 日志配置' >> /etc/mysql/my.cnf && \
    echo 'log-error = /var/log/mysql/error.log' >> /etc/mysql/my.cnf && \
    echo 'slow_query_log = 1' >> /etc/mysql/my.cnf && \
    echo 'slow_query_log_file = /var/log/mysql/slow.log' >> /etc/mysql/my.cnf && \
    echo 'long_query_time = 2' >> /etc/mysql/my.cnf && \
    echo '' >> /etc/mysql/my.cnf && \
    echo '# InnoDB 配置' >> /etc/mysql/my.cnf && \
    echo 'innodb_buffer_pool_size = 128M' >> /etc/mysql/my.cnf && \
    echo 'innodb_log_file_size = 64M' >> /etc/mysql/my.cnf && \
    echo 'innodb_flush_log_at_trx_commit = 1' >> /etc/mysql/my.cnf && \
    echo 'innodb_lock_wait_timeout = 50' >> /etc/mysql/my.cnf && \
    echo '' >> /etc/mysql/my.cnf && \
    echo '# 连接配置' >> /etc/mysql/my.cnf && \
    echo 'max_connections = 200' >> /etc/mysql/my.cnf && \
    echo 'max_connect_errors = 10' >> /etc/mysql/my.cnf && \
    echo '' >> /etc/mysql/my.cnf && \
    echo '[mysql]' >> /etc/mysql/my.cnf && \
    echo 'default-character-set = utf8mb4' >> /etc/mysql/my.cnf && \
    echo '' >> /etc/mysql/my.cnf && \
    echo '[client]' >> /etc/mysql/my.cnf && \
    echo 'default-character-set = utf8mb4' >> /etc/mysql/my.cnf && \
    echo 'socket = /var/run/mysqld/mysqld.sock' >> /etc/mysql/my.cnf

# 设置环境变量，将 MySQL 二进制文件路径加入 PATH
ENV PATH=${MYSQL_PREFIX}/bin:$PATH

# 初始化 MySQL 数据库
RUN echo "正在初始化 MySQL 数据库..." && \
    ${MYSQL_PREFIX}/bin/mysqld --initialize-insecure \
    --user=${MYSQL_USER} \
    --basedir=${MYSQL_PREFIX} \
    --datadir=${MYSQL_DATADIR} && \
    echo "MySQL 数据库初始化完成"

# 创建启动脚本
RUN echo '#!/bin/bash' > /usr/local/bin/docker-entrypoint.sh && \
    echo 'set -eo pipefail' >> /usr/local/bin/docker-entrypoint.sh && \
    echo '' >> /usr/local/bin/docker-entrypoint.sh && \
    echo '# 确保目录权限正确' >> /usr/local/bin/docker-entrypoint.sh && \
    echo 'chown -R mysql:mysql /SunshineCloud/MySQL-Data /var/log/mysql /var/run/mysqld' >> /usr/local/bin/docker-entrypoint.sh && \
    echo '' >> /usr/local/bin/docker-entrypoint.sh && \
    echo '# 如果数据目录为空，重新初始化' >> /usr/local/bin/docker-entrypoint.sh && \
    echo 'if [ ! -d "/SunshineCloud/MySQL-Data/mysql" ]; then' >> /usr/local/bin/docker-entrypoint.sh && \
    echo '    echo "初始化 MySQL 数据库..."' >> /usr/local/bin/docker-entrypoint.sh && \
    echo '    mysqld --initialize-insecure --user=mysql --basedir=/SunshineCloud/MySQL-Server --datadir=/SunshineCloud/MySQL-Data' >> /usr/local/bin/docker-entrypoint.sh && \
    echo 'fi' >> /usr/local/bin/docker-entrypoint.sh && \
    echo '' >> /usr/local/bin/docker-entrypoint.sh && \
    echo '# 启动 MySQL 服务器' >> /usr/local/bin/docker-entrypoint.sh && \
    echo 'echo "启动 MySQL 服务器..."' >> /usr/local/bin/docker-entrypoint.sh && \
    echo 'exec mysqld --user=mysql --console' >> /usr/local/bin/docker-entrypoint.sh

# 设置启动脚本权限
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# 清理临时文件
RUN rm -rf /tmp/mysql-build

# 暴露 MySQL 端口
EXPOSE 3306

# 设置数据卷
VOLUME ["/SunshineCloud/MySQL-Data", "/var/log/mysql"]

# 设置启动命令
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
