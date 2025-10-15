# ================================
# Apache HTTP Server 源码编译 Dockerfile
# ================================
# 基于 Debian Bookworm 构建的 Apache HTTP Server 源码编译镜像
# 特点：
# 1. 完整的环境变量配置管理
# 2. 并行编译优化
# 3. 从零开始编译 Apache 2.4.58
# 4. 集成 Supervisor 进程管理
# 5. 生产级配置和优化
# ================================
ARG VARIANT="bookworm"
FROM buildpack-deps:${VARIANT}-curl
# ================================
# 镜像元信息
# ================================
LABEL maintainer="SunshineCloudTech <support@sunshinecloud.tech>"
LABEL version="1.0.0"
LABEL description="Apache HTTP Server 2.4.58 compiled from source with parallel compilation optimization"
LABEL apache.version="2.4.58"
LABEL apr.version="1.7.4"
LABEL apr-util.version="1.6.3"

# ================================
# Apache 版本控制环境变量
# ================================
ENV APACHE_VERSION=2.4.58
ENV APR_VERSION=1.7.4
ENV APR_UTIL_VERSION=1.6.3
ENV PCRE_VERSION=8.45

# ================================
# 编译器和构建工具配置
# ================================
ENV CC=gcc
ENV CXX=g++
ENV CFLAGS="-O3 -march=native -mtune=native"
ENV CXXFLAGS="-O3 -march=native -mtune=native"
ENV LDFLAGS="-Wl,-O1 -Wl,--as-needed"

# ================================
# 编译并行配置
# ================================
ENV MAKE_PARALLEL_JOBS=4

# ================================
# 安装路径配置
# ================================
ENV APACHE_PREFIX=/usr/local/apache2
ENV APR_PREFIX=/usr/local/apr
ENV APR_UTIL_PREFIX=/usr/local/apr-util
ENV PCRE_PREFIX=/usr/local/pcre

# ================================
# Apache 编译配置选项
# ================================
ENV APACHE_ENABLE_MODULES="--enable-so --enable-ssl --enable-http2 --enable-proxy --enable-proxy-http --enable-proxy-fcgi --enable-proxy-http2 --enable-rewrite --enable-headers --enable-deflate --enable-expires --enable-mime-magic --enable-unique-id --enable-setenvif --enable-status --enable-info"
ENV APACHE_ENABLE_MPMS="--enable-mpms-shared=all"
ENV APACHE_WITH_OPTIONS="--with-mpm=event --with-included-apr --with-pcre=${PCRE_PREFIX}"
ENV APACHE_SSL_OPTIONS="--enable-ssl-staticlib-deps --with-ssl=/usr"

# ================================
# Apache 运行时配置
# ================================
ENV APACHE_USER=www-data
ENV APACHE_GROUP=www-data
ENV APACHE_UID=33
ENV APACHE_GID=33
ENV APACHE_SERVER_NAME=localhost
ENV APACHE_SERVER_ADMIN=admin@localhost
ENV APACHE_DOCUMENT_ROOT=/usr/local/apache2/htdocs
ENV APACHE_LISTEN_PORT=80
ENV APACHE_SSL_PORT=443

# ================================
# Apache 运行目录配置
# ================================
ENV APACHE_RUN_DIR=/var/run/apache2
ENV APACHE_LOG_DIR=/var/log/apache2
ENV APACHE_LOCK_DIR=/var/lock/apache2
ENV APACHE_CACHE_DIR=/var/cache/apache2
ENV APACHE_PID_FILE=/var/run/apache2/httpd.pid

# ================================
# Supervisor 配置
# ================================
ENV SUPERVISOR_CONF_DIR=/etc/supervisor/conf.d
ENV SUPERVISOR_LOG_DIR=/var/log/supervisor
ENV SUPERVISOR_PID_FILE=/var/run/supervisord.pid

# ================================
# 构建临时目录
# ================================
ENV BUILD_DIR=/tmp/apache-build
ENV SOURCES_DIR=/tmp/sources

# ================================
# 下载 URL 配置
# ================================
ENV APACHE_DOWNLOAD_URL=https://archive.apache.org/dist/httpd/httpd-${APACHE_VERSION}.tar.gz
ENV APR_DOWNLOAD_URL=https://archive.apache.org/dist/apr/apr-${APR_VERSION}.tar.gz
ENV APR_UTIL_DOWNLOAD_URL=https://archive.apache.org/dist/apr/apr-util-${APR_UTIL_VERSION}.tar.gz
ENV PCRE_DOWNLOAD_URL=https://sourceforge.net/projects/pcre/files/pcre/${PCRE_VERSION}/pcre-${PCRE_VERSION}.tar.gz/download

# ================================
# 系统软件包更新和依赖安装
# ================================
RUN set -eux && \
    echo "=== 更新软件包索引 ===" && \
    apt-get update && \
    echo "=== 安装编译依赖包 ===" && \
    apt-get install -y --no-install-recommends \
        # 编译工具链
        build-essential \
        gcc \
        g++ \
        make \
        autoconf \
        automake \
        libtool \
        pkg-config \
        # Apache 编译依赖
        libssl-dev \
        libexpat1-dev \
        libxml2-dev \
        zlib1g-dev \
        libbrotli-dev \
        libnghttp2-dev \
        # 下载和解压工具
        wget \
        curl \
        tar \
        gzip \
        # Python 和 Supervisor
        python3 \
        python3-pip \
        python3-setuptools \
        # 系统工具
        procps \
        net-tools \
        vim \
        htop \
        tree \
        ca-certificates && \
    echo "=== 清理 APT 缓存 ===" && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# ================================
# 安装 Supervisor
# ================================
# RUN set -eux && \
#     echo "=== 安装 Supervisor ===" && \
#     pip3 install --no-cache-dir supervisor && \
#     echo "=== 创建 Supervisor 目录 ===" && \
#     mkdir -p ${SUPERVISOR_CONF_DIR} ${SUPERVISOR_LOG_DIR}

# ================================
# 创建系统用户和目录
# ================================
RUN set -eux && \
    echo "=== 创建 Apache 运行用户 ===" && \
    groupadd -g ${APACHE_GID} ${APACHE_GROUP} || true && \
    useradd -u ${APACHE_UID} -g ${APACHE_GROUP} -s /bin/false -r -M ${APACHE_USER} || true && \
    echo "=== 创建必要目录 ===" && \
    mkdir -p \
        ${BUILD_DIR} \
        ${SOURCES_DIR} \
        ${APACHE_RUN_DIR} \
        ${APACHE_LOG_DIR} \
        ${APACHE_LOCK_DIR} \
        ${APACHE_CACHE_DIR} && \
    echo "=== 设置目录权限 ===" && \
    chown -R ${APACHE_USER}:${APACHE_GROUP} \
        ${APACHE_RUN_DIR} \
        ${APACHE_LOG_DIR} \
        ${APACHE_LOCK_DIR} \
        ${APACHE_CACHE_DIR}

# ================================
# 下载源码包
# ================================
WORKDIR ${SOURCES_DIR}

RUN set -eux && \
    echo "=== 下载 PCRE 源码 ===" && \
    wget -O pcre-${PCRE_VERSION}.tar.gz "${PCRE_DOWNLOAD_URL}" && \
    echo "=== 下载 APR 源码 ===" && \
    wget -O apr-${APR_VERSION}.tar.gz "${APR_DOWNLOAD_URL}" && \
    echo "=== 下载 APR-Util 源码 ===" && \
    wget -O apr-util-${APR_UTIL_VERSION}.tar.gz "${APR_UTIL_DOWNLOAD_URL}" && \
    echo "=== 下载 Apache HTTP Server 源码 ===" && \
    wget -O httpd-${APACHE_VERSION}.tar.gz "${APACHE_DOWNLOAD_URL}" && \
    echo "=== 验证下载文件 ===" && \
    ls -la *.tar.gz

# ================================
# 解压源码包
# ================================
RUN set -eux && \
    echo "=== 解压源码包 ===" && \
    tar -zxf pcre-${PCRE_VERSION}.tar.gz && \
    tar -zxf apr-${APR_VERSION}.tar.gz && \
    tar -zxf apr-util-${APR_UTIL_VERSION}.tar.gz && \
    tar -zxf httpd-${APACHE_VERSION}.tar.gz && \
    echo "=== 清理压缩包 ===" && \
    rm -f *.tar.gz && \
    echo "=== 查看解压结果 ===" && \
    ls -la

# ================================
# 设置编译并行任务数
# ================================
RUN set -eux && \
    echo "=== 设置编译配置 ===" && \
    echo "MAKE_PARALLEL_JOBS=${MAKE_PARALLEL_JOBS}" > /tmp/build-config.env && \
    echo "export PATH=\"\${PATH:-/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin}\"" >> /tmp/build-config.env && \
    echo "export PKG_CONFIG_PATH=\"\${PKG_CONFIG_PATH:-}\"" >> /tmp/build-config.env && \
    echo "export LD_LIBRARY_PATH=\"\${LD_LIBRARY_PATH:-}\"" >> /tmp/build-config.env && \
    echo "将使用 ${MAKE_PARALLEL_JOBS} 个并行任务进行编译"

# ================================
# 编译安装 PCRE
# ================================
WORKDIR ${SOURCES_DIR}/pcre-${PCRE_VERSION}

RUN set -eux && \
    echo "=== 开始编译 PCRE ===" && \
    . /tmp/build-config.env && \
    echo "=== 配置 PCRE 编译选项 ===" && \
    ./configure \
        --prefix=${PCRE_PREFIX} \
        --enable-utf8 \
        --enable-unicode-properties \
        --enable-pcre16 \
        --enable-pcre32 \
        --enable-jit && \
    echo "=== 编译 PCRE (使用 ${MAKE_PARALLEL_JOBS} 个并行任务) ===" && \
    make -j${MAKE_PARALLEL_JOBS} && \
    echo "=== 安装 PCRE ===" && \
    make install && \
    echo "=== 更新环境变量和库路径 ===" && \
    echo "export PATH=\"${PCRE_PREFIX}/bin:\${PATH:-}\"" >> /tmp/build-config.env && \
    echo "export PKG_CONFIG_PATH=\"${PCRE_PREFIX}/lib/pkgconfig:\${PKG_CONFIG_PATH:-}\"" >> /tmp/build-config.env && \
    echo "export LD_LIBRARY_PATH=\"${PCRE_PREFIX}/lib:\${LD_LIBRARY_PATH:-}\"" >> /tmp/build-config.env && \
    echo "=== 验证 PCRE 安装 ===" && \
    ${PCRE_PREFIX}/bin/pcre-config --version && \
    echo "=== PCRE 编译完成 ==="

# ================================
# 编译安装 APR
# ================================
WORKDIR ${SOURCES_DIR}/apr-${APR_VERSION}

RUN set -eux && \
    echo "=== 开始编译 APR ===" && \
    . /tmp/build-config.env && \
    echo "=== 配置 APR 编译选项 ===" && \
    ./configure \
        --prefix=${APR_PREFIX} \
        --enable-shared \
        --enable-static && \
    echo "=== 编译 APR (使用 ${MAKE_PARALLEL_JOBS} 个并行任务) ===" && \
    make -j${MAKE_PARALLEL_JOBS} && \
    echo "=== 安装 APR ===" && \
    make install && \
    echo "=== 更新环境变量和库路径 ===" && \
    echo "export PATH=\"${APR_PREFIX}/bin:\${PATH:-}\"" >> /tmp/build-config.env && \
    echo "export PKG_CONFIG_PATH=\"${APR_PREFIX}/lib/pkgconfig:\${PKG_CONFIG_PATH:-}\"" >> /tmp/build-config.env && \
    echo "export LD_LIBRARY_PATH=\"${APR_PREFIX}/lib:\${LD_LIBRARY_PATH:-}\"" >> /tmp/build-config.env && \
    echo "=== APR 编译完成 ==="

# ================================
# 编译安装 APR-Util
# ================================
WORKDIR ${SOURCES_DIR}/apr-util-${APR_UTIL_VERSION}

RUN set -eux && \
    echo "=== 开始编译 APR-Util ===" && \
    . /tmp/build-config.env && \
    echo "=== 配置 APR-Util 编译选项 ===" && \
    ./configure \
        --prefix=${APR_UTIL_PREFIX} \
        --with-apr=${APR_PREFIX} \
        --enable-shared \
        --enable-static && \
    echo "=== 编译 APR-Util (使用 ${MAKE_PARALLEL_JOBS} 个并行任务) ===" && \
    make -j${MAKE_PARALLEL_JOBS} && \
    echo "=== 安装 APR-Util ===" && \
    make install && \
    echo "=== 更新环境变量和库路径 ===" && \
    echo "export PATH=\"${APR_UTIL_PREFIX}/bin:\${PATH:-}\"" >> /tmp/build-config.env && \
    echo "export PKG_CONFIG_PATH=\"${APR_UTIL_PREFIX}/lib/pkgconfig:\${PKG_CONFIG_PATH:-}\"" >> /tmp/build-config.env && \
    echo "export LD_LIBRARY_PATH=\"${APR_UTIL_PREFIX}/lib:\${LD_LIBRARY_PATH:-}\"" >> /tmp/build-config.env && \
    echo "=== APR-Util 编译完成 ==="

# ================================
# 编译安装 Apache HTTP Server
# ================================
WORKDIR ${SOURCES_DIR}/httpd-${APACHE_VERSION}

# 复制 APR 和 APR-Util 到 Apache 源码目录（备用方案）
RUN set -eux && \
    echo "=== 准备 Apache 编译环境 ===" && \
    cp -r ${SOURCES_DIR}/apr-${APR_VERSION} srclib/apr && \
    cp -r ${SOURCES_DIR}/apr-util-${APR_UTIL_VERSION} srclib/apr-util

# 配置和编译 Apache
RUN set -eux && \
    echo "=== 开始编译 Apache HTTP Server ===" && \
    . /tmp/build-config.env && \
    echo "=== 验证编译环境 ===" && \
    echo "PATH: $PATH" && \
    echo "PKG_CONFIG_PATH: $PKG_CONFIG_PATH" && \
    echo "LD_LIBRARY_PATH: $LD_LIBRARY_PATH" && \
    echo "=== 检查 pcre-config ===" && \
    which pcre-config && \
    pcre-config --version && \
    echo "=== 配置 Apache 编译选项 ===" && \
    ./configure \
        --prefix=${APACHE_PREFIX} \
        --with-apr=${APR_PREFIX} \
        --with-apr-util=${APR_UTIL_PREFIX} \
        --with-pcre=${PCRE_PREFIX} \
        ${APACHE_ENABLE_MODULES} \
        ${APACHE_ENABLE_MPMS} \
        ${APACHE_WITH_OPTIONS} \
        ${APACHE_SSL_OPTIONS} \
        --enable-layout=Debian \
        --enable-shared=max \
        --enable-static=no && \
    echo "=== 编译 Apache (使用 ${MAKE_PARALLEL_JOBS} 个并行任务) ===" && \
    make -j${MAKE_PARALLEL_JOBS} && \
    echo "=== 安装 Apache ===" && \
    make install && \
    echo "=== 安装 Apache 配置文件 ===" && \
    make install-conf && \
    echo "=== 验证安装结果 ===" && \
    ls -la ${APACHE_PREFIX}/conf/ && \
    echo "=== Apache HTTP Server 编译安装完成 ==="

# ================================
# 配置 Apache
# ================================
RUN set -eux && \
    echo "=== 验证 Apache 配置文件 ===" && \
    ls -la ${APACHE_PREFIX}/conf/ && \
    test -f ${APACHE_PREFIX}/conf/httpd.conf && \
    echo "=== 配置 Apache HTTP Server ===" && \
    # 创建基本配置
    sed -i "s/^#ServerName .*/ServerName ${APACHE_SERVER_NAME}:${APACHE_LISTEN_PORT}/" ${APACHE_PREFIX}/conf/httpd.conf && \
    sed -i "s/^ServerAdmin .*/ServerAdmin ${APACHE_SERVER_ADMIN}/" ${APACHE_PREFIX}/conf/httpd.conf && \
    sed -i "s/^User .*/User ${APACHE_USER}/" ${APACHE_PREFIX}/conf/httpd.conf && \
    sed -i "s/^Group .*/Group ${APACHE_GROUP}/" ${APACHE_PREFIX}/conf/httpd.conf && \
    # 启用常用模块
    sed -i 's/#LoadModule rewrite_module/LoadModule rewrite_module/' ${APACHE_PREFIX}/conf/httpd.conf && \
    sed -i 's/#LoadModule ssl_module/LoadModule ssl_module/' ${APACHE_PREFIX}/conf/httpd.conf && \
    sed -i 's/#LoadModule deflate_module/LoadModule deflate_module/' ${APACHE_PREFIX}/conf/httpd.conf && \
    sed -i 's/#LoadModule expires_module/LoadModule expires_module/' ${APACHE_PREFIX}/conf/httpd.conf && \
    sed -i 's/#LoadModule headers_module/LoadModule headers_module/' ${APACHE_PREFIX}/conf/httpd.conf && \
    # 配置日志目录
    mkdir -p ${APACHE_LOG_DIR} && \
    echo "=== Apache 基本配置完成 ==="

# ================================
# 创建 Apache 扩展配置文件
# ================================
RUN set -eux && \
    echo "=== 创建 Apache 扩展配置 ===" && \
    echo '# Apache 性能优化配置' > ${APACHE_PREFIX}/conf/extra/httpd-performance.conf && \
    echo '# 启用压缩' >> ${APACHE_PREFIX}/conf/extra/httpd-performance.conf && \
    echo '<IfModule mod_deflate.c>' >> ${APACHE_PREFIX}/conf/extra/httpd-performance.conf && \
    echo '    # 压缩 HTML、CSS、JavaScript、XML、JSON 等文件' >> ${APACHE_PREFIX}/conf/extra/httpd-performance.conf && \
    echo '    AddOutputFilterByType DEFLATE text/plain' >> ${APACHE_PREFIX}/conf/extra/httpd-performance.conf && \
    echo '    AddOutputFilterByType DEFLATE text/html' >> ${APACHE_PREFIX}/conf/extra/httpd-performance.conf && \
    echo '    AddOutputFilterByType DEFLATE text/xml' >> ${APACHE_PREFIX}/conf/extra/httpd-performance.conf && \
    echo '    AddOutputFilterByType DEFLATE text/css' >> ${APACHE_PREFIX}/conf/extra/httpd-performance.conf && \
    echo '    AddOutputFilterByType DEFLATE application/xml' >> ${APACHE_PREFIX}/conf/extra/httpd-performance.conf && \
    echo '    AddOutputFilterByType DEFLATE application/xhtml+xml' >> ${APACHE_PREFIX}/conf/extra/httpd-performance.conf && \
    echo '    AddOutputFilterByType DEFLATE application/rss+xml' >> ${APACHE_PREFIX}/conf/extra/httpd-performance.conf && \
    echo '    AddOutputFilterByType DEFLATE application/javascript' >> ${APACHE_PREFIX}/conf/extra/httpd-performance.conf && \
    echo '    AddOutputFilterByType DEFLATE application/x-javascript' >> ${APACHE_PREFIX}/conf/extra/httpd-performance.conf && \
    echo '    AddOutputFilterByType DEFLATE application/json' >> ${APACHE_PREFIX}/conf/extra/httpd-performance.conf && \
    echo '</IfModule>' >> ${APACHE_PREFIX}/conf/extra/httpd-performance.conf && \
    echo '' >> ${APACHE_PREFIX}/conf/extra/httpd-performance.conf && \
    echo '# 启用缓存控制' >> ${APACHE_PREFIX}/conf/extra/httpd-performance.conf && \
    echo '<IfModule mod_expires.c>' >> ${APACHE_PREFIX}/conf/extra/httpd-performance.conf && \
    echo '    ExpiresActive On' >> ${APACHE_PREFIX}/conf/extra/httpd-performance.conf && \
    echo '    ' >> ${APACHE_PREFIX}/conf/extra/httpd-performance.conf && \
    echo '    # 图片文件缓存 1 个月' >> ${APACHE_PREFIX}/conf/extra/httpd-performance.conf && \
    echo '    ExpiresByType image/jpg "access plus 1 month"' >> ${APACHE_PREFIX}/conf/extra/httpd-performance.conf && \
    echo '    ExpiresByType image/jpeg "access plus 1 month"' >> ${APACHE_PREFIX}/conf/extra/httpd-performance.conf && \
    echo '    ExpiresByType image/gif "access plus 1 month"' >> ${APACHE_PREFIX}/conf/extra/httpd-performance.conf && \
    echo '    ExpiresByType image/png "access plus 1 month"' >> ${APACHE_PREFIX}/conf/extra/httpd-performance.conf && \
    echo '    ' >> ${APACHE_PREFIX}/conf/extra/httpd-performance.conf && \
    echo '    # CSS 和 JavaScript 文件缓存 1 周' >> ${APACHE_PREFIX}/conf/extra/httpd-performance.conf && \
    echo '    ExpiresByType text/css "access plus 1 week"' >> ${APACHE_PREFIX}/conf/extra/httpd-performance.conf && \
    echo '    ExpiresByType application/javascript "access plus 1 week"' >> ${APACHE_PREFIX}/conf/extra/httpd-performance.conf && \
    echo '    ExpiresByType application/x-javascript "access plus 1 week"' >> ${APACHE_PREFIX}/conf/extra/httpd-performance.conf && \
    echo '    ' >> ${APACHE_PREFIX}/conf/extra/httpd-performance.conf && \
    echo '    # HTML 文件缓存 1 小时' >> ${APACHE_PREFIX}/conf/extra/httpd-performance.conf && \
    echo '    ExpiresByType text/html "access plus 1 hour"' >> ${APACHE_PREFIX}/conf/extra/httpd-performance.conf && \
    echo '</IfModule>' >> ${APACHE_PREFIX}/conf/extra/httpd-performance.conf && \
    echo '' >> ${APACHE_PREFIX}/conf/extra/httpd-performance.conf && \
    echo '# 安全头设置' >> ${APACHE_PREFIX}/conf/extra/httpd-performance.conf && \
    echo '<IfModule mod_headers.c>' >> ${APACHE_PREFIX}/conf/extra/httpd-performance.conf && \
    echo '    Header always set X-Frame-Options "SAMEORIGIN"' >> ${APACHE_PREFIX}/conf/extra/httpd-performance.conf && \
    echo '    Header always set X-Content-Type-Options "nosniff"' >> ${APACHE_PREFIX}/conf/extra/httpd-performance.conf && \
    echo '    Header always set X-XSS-Protection "1; mode=block"' >> ${APACHE_PREFIX}/conf/extra/httpd-performance.conf && \
    echo '    Header always set Referrer-Policy "strict-origin-when-cross-origin"' >> ${APACHE_PREFIX}/conf/extra/httpd-performance.conf && \
    echo '</IfModule>' >> ${APACHE_PREFIX}/conf/extra/httpd-performance.conf

# ================================
# 创建 SSL 配置文件
# ================================
RUN set -eux && \
    echo "=== 创建 SSL 配置文件 ===" && \
    echo '# Apache SSL 配置' > ${APACHE_PREFIX}/conf/extra/httpd-ssl-custom.conf && \
    echo '<IfModule mod_ssl.c>' >> ${APACHE_PREFIX}/conf/extra/httpd-ssl-custom.conf && \
    echo '    # SSL 引擎开启' >> ${APACHE_PREFIX}/conf/extra/httpd-ssl-custom.conf && \
    echo '    SSLEngine on' >> ${APACHE_PREFIX}/conf/extra/httpd-ssl-custom.conf && \
    echo '    ' >> ${APACHE_PREFIX}/conf/extra/httpd-ssl-custom.conf && \
    echo '    # SSL 协议配置 - 只允许 TLS 1.2 和 1.3' >> ${APACHE_PREFIX}/conf/extra/httpd-ssl-custom.conf && \
    echo '    SSLProtocol all -SSLv3 -TLSv1 -TLSv1.1' >> ${APACHE_PREFIX}/conf/extra/httpd-ssl-custom.conf && \
    echo '    ' >> ${APACHE_PREFIX}/conf/extra/httpd-ssl-custom.conf && \
    echo '    # SSL 加密套件配置' >> ${APACHE_PREFIX}/conf/extra/httpd-ssl-custom.conf && \
    echo '    SSLCipherSuite ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256' >> ${APACHE_PREFIX}/conf/extra/httpd-ssl-custom.conf && \
    echo '    SSLHonorCipherOrder off' >> ${APACHE_PREFIX}/conf/extra/httpd-ssl-custom.conf && \
    echo '    ' >> ${APACHE_PREFIX}/conf/extra/httpd-ssl-custom.conf && \
    echo '    # SSL 会话缓存' >> ${APACHE_PREFIX}/conf/extra/httpd-ssl-custom.conf && \
    echo '    SSLSessionCache "shmcb:${APACHE_RUN_DIR}/ssl_scache(512000)"' >> ${APACHE_PREFIX}/conf/extra/httpd-ssl-custom.conf && \
    echo '    SSLSessionCacheTimeout 300' >> ${APACHE_PREFIX}/conf/extra/httpd-ssl-custom.conf && \
    echo '    ' >> ${APACHE_PREFIX}/conf/extra/httpd-ssl-custom.conf && \
    echo '    # OCSP Stapling' >> ${APACHE_PREFIX}/conf/extra/httpd-ssl-custom.conf && \
    echo '    SSLUseStapling On' >> ${APACHE_PREFIX}/conf/extra/httpd-ssl-custom.conf && \
    echo '    SSLStaplingCache "shmcb:${APACHE_RUN_DIR}/ssl_stapling(32768)"' >> ${APACHE_PREFIX}/conf/extra/httpd-ssl-custom.conf && \
    echo '</IfModule>' >> ${APACHE_PREFIX}/conf/extra/httpd-ssl-custom.conf

# ================================
# 在主配置文件中包含扩展配置
# ================================
RUN set -eux && \
    echo "=== 启用扩展配置文件 ===" && \
    echo "" >> ${APACHE_PREFIX}/conf/httpd.conf && \
    echo "# 包含性能优化配置" >> ${APACHE_PREFIX}/conf/httpd.conf && \
    echo "Include conf/extra/httpd-performance.conf" >> ${APACHE_PREFIX}/conf/httpd.conf && \
    echo "" >> ${APACHE_PREFIX}/conf/httpd.conf && \
    echo "# 包含 SSL 配置" >> ${APACHE_PREFIX}/conf/httpd.conf && \
    echo "Include conf/extra/httpd-ssl-custom.conf" >> ${APACHE_PREFIX}/conf/httpd.conf

# ================================
# 设置目录权限
# ================================
RUN set -eux && \
    echo "=== 设置目录权限 ===" && \
    chown -R root:root ${APACHE_PREFIX} && \
    chown -R ${APACHE_USER}:${APACHE_GROUP} \
        ${APACHE_PREFIX}/logs \
        ${APACHE_PREFIX}/htdocs \
        ${APACHE_RUN_DIR} \
        ${APACHE_LOG_DIR} \
        ${APACHE_LOCK_DIR} \
        ${APACHE_CACHE_DIR} && \
    chmod -R 755 ${APACHE_PREFIX}/bin && \
    chmod -R 644 ${APACHE_PREFIX}/conf && \
    chmod 755 ${APACHE_PREFIX}/conf

# ================================
# 生成 Supervisor 主配置文件
# ================================
# RUN set -eux && \
#     echo "=== 生成 Supervisor 主配置文件 ===" && \
#     echo '; Supervisor 主配置文件' > /etc/supervisord.conf && \
#     echo '; 用于管理 Apache HTTP Server 进程' >> /etc/supervisord.conf && \
#     echo '; ================================' >> /etc/supervisord.conf && \
#     echo '' >> /etc/supervisord.conf && \
#     echo '[supervisord]' >> /etc/supervisord.conf && \
#     echo '; Supervisor 守护进程配置' >> /etc/supervisord.conf && \
#     echo 'nodaemon=true' >> /etc/supervisord.conf && \
#     echo 'user=root' >> /etc/supervisord.conf && \
#     echo 'logfile=/var/log/supervisor/supervisord.log' >> /etc/supervisord.conf && \
#     echo 'logfile_maxbytes=50MB' >> /etc/supervisord.conf && \
#     echo 'logfile_backups=10' >> /etc/supervisord.conf && \
#     echo 'loglevel=info' >> /etc/supervisord.conf && \
#     echo 'pidfile=/var/run/supervisord.pid' >> /etc/supervisord.conf && \
#     echo 'childlogdir=/var/log/supervisor' >> /etc/supervisord.conf && \
#     echo 'silent=false' >> /etc/supervisord.conf && \
#     echo '' >> /etc/supervisord.conf && \
#     echo '; Unix socket 配置' >> /etc/supervisord.conf && \
#     echo '[unix_http_server]' >> /etc/supervisord.conf && \
#     echo 'file=/var/run/supervisor.sock' >> /etc/supervisord.conf && \
#     echo 'chmod=0700' >> /etc/supervisord.conf && \
#     echo '' >> /etc/supervisord.conf && \
#     echo '; Web 管理界面配置（可选）' >> /etc/supervisord.conf && \
#     echo '[inet_http_server]' >> /etc/supervisord.conf && \
#     echo 'port=127.0.0.1:9001' >> /etc/supervisord.conf && \
#     echo 'username=admin' >> /etc/supervisord.conf && \
#     echo 'password=admin123' >> /etc/supervisord.conf && \
#     echo '' >> /etc/supervisord.conf && \
#     echo '; RPC 接口配置' >> /etc/supervisord.conf && \
#     echo '[rpcinterface:supervisor]' >> /etc/supervisord.conf && \
#     echo 'supervisor.rpcinterface_factory = supervisor.rpcinterface:make_main_rpcinterface' >> /etc/supervisord.conf && \
#     echo '' >> /etc/supervisord.conf && \
#     echo '; supervisorctl 配置' >> /etc/supervisord.conf && \
#     echo '[supervisorctl]' >> /etc/supervisord.conf && \
#     echo 'serverurl=unix:///var/run/supervisor.sock' >> /etc/supervisord.conf && \
#     echo '' >> /etc/supervisord.conf && \
#     echo '; 包含子配置文件' >> /etc/supervisord.conf && \
#     echo '[include]' >> /etc/supervisord.conf && \
#     echo 'files = /etc/supervisor/conf.d/*.conf' >> /etc/supervisord.conf

# # ================================
# # 生成 Apache Supervisor 配置文件
# # ================================
# RUN set -eux && \
#     echo "=== 生成 Apache Supervisor 配置文件 ===" && \
#     echo '; ================================' > ${SUPERVISOR_CONF_DIR}/apache.conf && \
#     echo '; Apache HTTP Server Supervisor 配置文件' >> ${SUPERVISOR_CONF_DIR}/apache.conf && \
#     echo '; ================================' >> ${SUPERVISOR_CONF_DIR}/apache.conf && \
#     echo '; 此配置文件用于通过 Supervisor 管理 Apache HTTP Server 进程' >> ${SUPERVISOR_CONF_DIR}/apache.conf && \
#     echo '; 确保 Apache 在容器中稳定运行，并提供自动重启功能' >> ${SUPERVISOR_CONF_DIR}/apache.conf && \
#     echo '; ================================' >> ${SUPERVISOR_CONF_DIR}/apache.conf && \
#     echo '' >> ${SUPERVISOR_CONF_DIR}/apache.conf && \
#     echo '[program:apache]' >> ${SUPERVISOR_CONF_DIR}/apache.conf && \
#     echo '; ================================' >> ${SUPERVISOR_CONF_DIR}/apache.conf && \
#     echo '; 程序基本配置' >> ${SUPERVISOR_CONF_DIR}/apache.conf && \
#     echo '; ================================' >> ${SUPERVISOR_CONF_DIR}/apache.conf && \
#     echo '; 执行命令 - 使用前台模式运行 Apache' >> ${SUPERVISOR_CONF_DIR}/apache.conf && \
#     echo 'command=/usr/local/apache2/bin/httpd -D FOREGROUND' >> ${SUPERVISOR_CONF_DIR}/apache.conf && \
#     echo '; 程序名称，用于 supervisorctl 管理' >> ${SUPERVISOR_CONF_DIR}/apache.conf && \
#     echo 'process_name=%(program_name)s' >> ${SUPERVISOR_CONF_DIR}/apache.conf && \
#     echo '; 程序数量，Apache 只需要一个主进程' >> ${SUPERVISOR_CONF_DIR}/apache.conf && \
#     echo 'numprocs=1' >> ${SUPERVISOR_CONF_DIR}/apache.conf && \
#     echo '' >> ${SUPERVISOR_CONF_DIR}/apache.conf && \
#     echo '; ================================' >> ${SUPERVISOR_CONF_DIR}/apache.conf && \
#     echo '; 进程管理配置' >> ${SUPERVISOR_CONF_DIR}/apache.conf && \
#     echo '; ================================' >> ${SUPERVISOR_CONF_DIR}/apache.conf && \
#     echo '; Supervisor 启动时自动启动 Apache' >> ${SUPERVISOR_CONF_DIR}/apache.conf && \
#     echo 'autostart=true' >> ${SUPERVISOR_CONF_DIR}/apache.conf && \
#     echo '; 进程异常退出时自动重启' >> ${SUPERVISOR_CONF_DIR}/apache.conf && \
#     echo 'autorestart=true' >> ${SUPERVISOR_CONF_DIR}/apache.conf && \
#     echo '; 程序启动后等待时间，超过此时间未退出视为启动成功' >> ${SUPERVISOR_CONF_DIR}/apache.conf && \
#     echo 'startsecs=10' >> ${SUPERVISOR_CONF_DIR}/apache.conf && \
#     echo '; 启动失败时的重试次数' >> ${SUPERVISOR_CONF_DIR}/apache.conf && \
#     echo 'startretries=3' >> ${SUPERVISOR_CONF_DIR}/apache.conf && \
#     echo '; 程序正常退出的返回码，只有这些返回码被认为是正常退出' >> ${SUPERVISOR_CONF_DIR}/apache.conf && \
#     echo 'exitcodes=0,2' >> ${SUPERVISOR_CONF_DIR}/apache.conf && \
#     echo '; 发送 SIGTERM 信号后等待进程退出的最大时间' >> ${SUPERVISOR_CONF_DIR}/apache.conf && \
#     echo 'stopwaitsecs=10' >> ${SUPERVISOR_CONF_DIR}/apache.conf && \
#     echo '; 如果进程在 stopwaitsecs 时间内没有退出，发送 SIGKILL 信号' >> ${SUPERVISOR_CONF_DIR}/apache.conf && \
#     echo 'stopsignal=TERM' >> ${SUPERVISOR_CONF_DIR}/apache.conf && \
#     echo '; 停止进程时是否杀死整个进程组（包括子进程）' >> ${SUPERVISOR_CONF_DIR}/apache.conf && \
#     echo 'stopasgroup=true' >> ${SUPERVISOR_CONF_DIR}/apache.conf && \
#     echo '; 发送 SIGKILL 时是否杀死整个进程组' >> ${SUPERVISOR_CONF_DIR}/apache.conf && \
#     echo 'killasgroup=true' >> ${SUPERVISOR_CONF_DIR}/apache.conf && \
#     echo '' >> ${SUPERVISOR_CONF_DIR}/apache.conf && \
#     echo '; ================================' >> ${SUPERVISOR_CONF_DIR}/apache.conf && \
#     echo '; 用户和目录配置' >> ${SUPERVISOR_CONF_DIR}/apache.conf && \
#     echo '; ================================' >> ${SUPERVISOR_CONF_DIR}/apache.conf && \
#     echo '; 运行用户 - Apache 需要以 root 启动以绑定特权端口，之后会降权' >> ${SUPERVISOR_CONF_DIR}/apache.conf && \
#     echo 'user=root' >> ${SUPERVISOR_CONF_DIR}/apache.conf && \
#     echo '; 工作目录' >> ${SUPERVISOR_CONF_DIR}/apache.conf && \
#     echo 'directory=/usr/local/apache2' >> ${SUPERVISOR_CONF_DIR}/apache.conf && \
#     echo '' >> ${SUPERVISOR_CONF_DIR}/apache.conf && \
#     echo '; ================================' >> ${SUPERVISOR_CONF_DIR}/apache.conf && \
#     echo '; 标准输出日志配置' >> ${SUPERVISOR_CONF_DIR}/apache.conf && \
#     echo '; ================================' >> ${SUPERVISOR_CONF_DIR}/apache.conf && \
#     echo '; 标准输出日志文件路径' >> ${SUPERVISOR_CONF_DIR}/apache.conf && \
#     echo 'stdout_logfile=/var/log/supervisor/apache-stdout.log' >> ${SUPERVISOR_CONF_DIR}/apache.conf && \
#     echo '; 标准输出日志文件最大大小' >> ${SUPERVISOR_CONF_DIR}/apache.conf && \
#     echo 'stdout_logfile_maxbytes=50MB' >> ${SUPERVISOR_CONF_DIR}/apache.conf && \
#     echo '; 标准输出日志文件备份数量' >> ${SUPERVISOR_CONF_DIR}/apache.conf && \
#     echo 'stdout_logfile_backups=10' >> ${SUPERVISOR_CONF_DIR}/apache.conf && \
#     echo '; 是否启用标准输出日志捕获' >> ${SUPERVISOR_CONF_DIR}/apache.conf && \
#     echo 'stdout_capture_maxbytes=0' >> ${SUPERVISOR_CONF_DIR}/apache.conf && \
#     echo '; 标准输出日志事件大小' >> ${SUPERVISOR_CONF_DIR}/apache.conf && \
#     echo 'stdout_events_enabled=false' >> ${SUPERVISOR_CONF_DIR}/apache.conf && \
#     echo '' >> ${SUPERVISOR_CONF_DIR}/apache.conf && \
#     echo '; ================================' >> ${SUPERVISOR_CONF_DIR}/apache.conf && \
#     echo '; 标准错误日志配置' >> ${SUPERVISOR_CONF_DIR}/apache.conf && \
#     echo '; ================================' >> ${SUPERVISOR_CONF_DIR}/apache.conf && \
#     echo '; 标准错误日志文件路径' >> ${SUPERVISOR_CONF_DIR}/apache.conf && \
#     echo 'stderr_logfile=/var/log/supervisor/apache-stderr.log' >> ${SUPERVISOR_CONF_DIR}/apache.conf && \
#     echo '; 标准错误日志文件最大大小' >> ${SUPERVISOR_CONF_DIR}/apache.conf && \
#     echo 'stderr_logfile_maxbytes=50MB' >> ${SUPERVISOR_CONF_DIR}/apache.conf && \
#     echo '; 标准错误日志文件备份数量' >> ${SUPERVISOR_CONF_DIR}/apache.conf && \
#     echo 'stderr_logfile_backups=10' >> ${SUPERVISOR_CONF_DIR}/apache.conf && \
#     echo '; 是否启用标准错误日志捕获' >> ${SUPERVISOR_CONF_DIR}/apache.conf && \
#     echo 'stderr_capture_maxbytes=0' >> ${SUPERVISOR_CONF_DIR}/apache.conf && \
#     echo '; 标准错误日志事件大小' >> ${SUPERVISOR_CONF_DIR}/apache.conf && \
#     echo 'stderr_events_enabled=false' >> ${SUPERVISOR_CONF_DIR}/apache.conf && \
#     echo '' >> ${SUPERVISOR_CONF_DIR}/apache.conf && \
#     echo '; ================================' >> ${SUPERVISOR_CONF_DIR}/apache.conf && \
#     echo '; 优先级和环境变量配置' >> ${SUPERVISOR_CONF_DIR}/apache.conf && \
#     echo '; ================================' >> ${SUPERVISOR_CONF_DIR}/apache.conf && \
#     echo '; 启动优先级，数字越小优先级越高' >> ${SUPERVISOR_CONF_DIR}/apache.conf && \
#     echo 'priority=999' >> ${SUPERVISOR_CONF_DIR}/apache.conf && \
#     echo '; 环境变量设置' >> ${SUPERVISOR_CONF_DIR}/apache.conf && \
#     echo 'environment=APACHE_RUN_DIR="/var/run/apache2",APACHE_LOG_DIR="/var/log/apache2",APACHE_LOCK_DIR="/var/lock/apache2",APACHE_PID_FILE="/var/run/apache2/httpd.pid",LANG="C.UTF-8"' >> ${SUPERVISOR_CONF_DIR}/apache.conf && \
#     echo '' >> ${SUPERVISOR_CONF_DIR}/apache.conf && \
#     echo '; ================================' >> ${SUPERVISOR_CONF_DIR}/apache.conf && \
#     echo '; 服务器配置标识' >> ${SUPERVISOR_CONF_DIR}/apache.conf && \
#     echo '; ================================' >> ${SUPERVISOR_CONF_DIR}/apache.conf && \
#     echo '; 服务器配置标识，用于区分不同的 Apache 实例' >> ${SUPERVISOR_CONF_DIR}/apache.conf && \
#     echo 'serverurl=AUTO' >> ${SUPERVISOR_CONF_DIR}/apache.conf

# # ================================
# # 创建 Apache 启动脚本
# # ================================
# RUN set -eux && \
#     echo "=== 创建 Apache 启动脚本 ===" && \
#     echo '#!/bin/bash' > /usr/local/bin/apache-start.sh && \
#     echo '# Apache HTTP Server 启动脚本' >> /usr/local/bin/apache-start.sh && \
#     echo '# 用于在容器启动时进行必要的初始化' >> /usr/local/bin/apache-start.sh && \
#     echo '' >> /usr/local/bin/apache-start.sh && \
#     echo 'set -e' >> /usr/local/bin/apache-start.sh && \
#     echo '' >> /usr/local/bin/apache-start.sh && \
#     echo 'echo "=== Apache HTTP Server 启动初始化 ==="' >> /usr/local/bin/apache-start.sh && \
#     echo '' >> /usr/local/bin/apache-start.sh && \
#     echo '# 创建运行时目录' >> /usr/local/bin/apache-start.sh && \
#     echo 'echo "创建运行时目录..."' >> /usr/local/bin/apache-start.sh && \
#     echo 'mkdir -p /var/run/apache2 /var/log/apache2 /var/lock/apache2 /var/cache/apache2' >> /usr/local/bin/apache-start.sh && \
#     echo '' >> /usr/local/bin/apache-start.sh && \
#     echo '# 设置权限' >> /usr/local/bin/apache-start.sh && \
#     echo 'echo "设置目录权限..."' >> /usr/local/bin/apache-start.sh && \
#     echo 'chown -R www-data:www-data /var/run/apache2 /var/log/apache2 /var/lock/apache2 /var/cache/apache2' >> /usr/local/bin/apache-start.sh && \
#     echo '' >> /usr/local/bin/apache-start.sh && \
#     echo '# 检查配置文件语法' >> /usr/local/bin/apache-start.sh && \
#     echo 'echo "检查 Apache 配置文件语法..."' >> /usr/local/bin/apache-start.sh && \
#     echo 'if /usr/local/apache2/bin/httpd -t; then' >> /usr/local/bin/apache-start.sh && \
#     echo '    echo "Apache 配置文件语法正确"' >> /usr/local/bin/apache-start.sh && \
#     echo 'else' >> /usr/local/bin/apache-start.sh && \
#     echo '    echo "错误: Apache 配置文件语法错误"' >> /usr/local/bin/apache-start.sh && \
#     echo '    exit 1' >> /usr/local/bin/apache-start.sh && \
#     echo 'fi' >> /usr/local/bin/apache-start.sh && \
#     echo '' >> /usr/local/bin/apache-start.sh && \
#     echo '# 显示 Apache 版本信息' >> /usr/local/bin/apache-start.sh && \
#     echo 'echo "Apache 版本信息:"' >> /usr/local/bin/apache-start.sh && \
#     echo '/usr/local/apache2/bin/httpd -v' >> /usr/local/bin/apache-start.sh && \
#     echo '' >> /usr/local/bin/apache-start.sh && \
#     echo '# 显示编译模块信息' >> /usr/local/bin/apache-start.sh && \
#     echo 'echo "已编译的模块:"' >> /usr/local/bin/apache-start.sh && \
#     echo '/usr/local/apache2/bin/httpd -l' >> /usr/local/bin/apache-start.sh && \
#     echo '' >> /usr/local/bin/apache-start.sh && \
#     echo 'echo "=== Apache HTTP Server 初始化完成 ==="' >> /usr/local/bin/apache-start.sh && \
#     echo '' >> /usr/local/bin/apache-start.sh && \
#     echo '# 启动 Supervisor' >> /usr/local/bin/apache-start.sh && \
#     echo 'echo "启动 Supervisor..."' >> /usr/local/bin/apache-start.sh && \
#     echo 'exec /usr/local/bin/supervisord -c /etc/supervisord.conf' >> /usr/local/bin/apache-start.sh

# RUN chmod +x /usr/local/bin/apache-start.sh

# ================================
# 创建健康检查脚本
# ================================
# RUN set -eux && \
#     echo "=== 创建健康检查脚本 ===" && \
#     echo '#!/bin/bash' > /usr/local/bin/health-check.sh && \
#     echo '# Apache HTTP Server 健康检查脚本' >> /usr/local/bin/health-check.sh && \
#     echo '' >> /usr/local/bin/health-check.sh && \
#     echo '# 检查 Apache 进程是否运行' >> /usr/local/bin/health-check.sh && \
#     echo 'if ! pgrep -f "httpd" > /dev/null; then' >> /usr/local/bin/health-check.sh && \
#     echo '    echo "错误: Apache 进程未运行"' >> /usr/local/bin/health-check.sh && \
#     echo '    exit 1' >> /usr/local/bin/health-check.sh && \
#     echo 'fi' >> /usr/local/bin/health-check.sh && \
#     echo '' >> /usr/local/bin/health-check.sh && \
#     echo '# 检查 Apache 是否响应 HTTP 请求' >> /usr/local/bin/health-check.sh && \
#     echo 'if ! curl -f -s http://localhost/ > /dev/null; then' >> /usr/local/bin/health-check.sh && \
#     echo '    echo "错误: Apache HTTP 服务无响应"' >> /usr/local/bin/health-check.sh && \
#     echo '    exit 1' >> /usr/local/bin/health-check.sh && \
#     echo 'fi' >> /usr/local/bin/health-check.sh && \
#     echo '' >> /usr/local/bin/health-check.sh && \
#     echo 'echo "Apache HTTP Server 健康检查通过"' >> /usr/local/bin/health-check.sh && \
#     echo 'exit 0' >> /usr/local/bin/health-check.sh

# RUN chmod +x /usr/local/bin/health-check.sh

# # ================================
# # 创建管理脚本
# # ================================
# RUN set -eux && \
#     echo "=== 创建管理脚本 ===" && \
#     echo '#!/bin/bash' > /usr/local/bin/apache-ctl.sh && \
#     echo '# Apache 管理脚本' >> /usr/local/bin/apache-ctl.sh && \
#     echo '' >> /usr/local/bin/apache-ctl.sh && \
#     echo 'case "$1" in' >> /usr/local/bin/apache-ctl.sh && \
#     echo '    start)' >> /usr/local/bin/apache-ctl.sh && \
#     echo '        echo "启动 Apache..."' >> /usr/local/bin/apache-ctl.sh && \
#     echo '        /usr/local/bin/supervisorctl start apache' >> /usr/local/bin/apache-ctl.sh && \
#     echo '        ;;' >> /usr/local/bin/apache-ctl.sh && \
#     echo '    stop)' >> /usr/local/bin/apache-ctl.sh && \
#     echo '        echo "停止 Apache..."' >> /usr/local/bin/apache-ctl.sh && \
#     echo '        /usr/local/bin/supervisorctl stop apache' >> /usr/local/bin/apache-ctl.sh && \
#     echo '        ;;' >> /usr/local/bin/apache-ctl.sh && \
#     echo '    restart)' >> /usr/local/bin/apache-ctl.sh && \
#     echo '        echo "重启 Apache..."' >> /usr/local/bin/apache-ctl.sh && \
#     echo '        /usr/local/bin/supervisorctl restart apache' >> /usr/local/bin/apache-ctl.sh && \
#     echo '        ;;' >> /usr/local/bin/apache-ctl.sh && \
#     echo '    reload)' >> /usr/local/bin/apache-ctl.sh && \
#     echo '        echo "重新加载 Apache 配置..."' >> /usr/local/bin/apache-ctl.sh && \
#     echo '        /usr/local/bin/supervisorctl signal HUP apache' >> /usr/local/bin/apache-ctl.sh && \
#     echo '        ;;' >> /usr/local/bin/apache-ctl.sh && \
#     echo '    status)' >> /usr/local/bin/apache-ctl.sh && \
#     echo '        echo "Apache 状态:"' >> /usr/local/bin/apache-ctl.sh && \
#     echo '        /usr/local/bin/supervisorctl status apache' >> /usr/local/bin/apache-ctl.sh && \
#     echo '        ;;' >> /usr/local/bin/apache-ctl.sh && \
#     echo '    configtest)' >> /usr/local/bin/apache-ctl.sh && \
#     echo '        echo "检查 Apache 配置..."' >> /usr/local/bin/apache-ctl.sh && \
#     echo '        /usr/local/apache2/bin/httpd -t' >> /usr/local/bin/apache-ctl.sh && \
#     echo '        ;;' >> /usr/local/bin/apache-ctl.sh && \
#     echo '    *)' >> /usr/local/bin/apache-ctl.sh && \
#     echo '        echo "用法: $0 {start|stop|restart|reload|status|configtest}"' >> /usr/local/bin/apache-ctl.sh && \
#     echo '        exit 1' >> /usr/local/bin/apache-ctl.sh && \
#     echo '        ;;' >> /usr/local/bin/apache-ctl.sh && \
#     echo 'esac' >> /usr/local/bin/apache-ctl.sh

# RUN chmod +x /usr/local/bin/apache-ctl.sh

# ================================
# 清理构建文件
# ================================
RUN set -eux && \
    echo "=== 清理构建文件和缓存 ===" && \
    # 清理源码目录
    rm -rf ${SOURCES_DIR} ${BUILD_DIR} /tmp/* && \
    # 清理编译工具（可选，会减小镜像体积但降低调试能力）
    # apt-get purge -y gcc g++ make autoconf automake libtool && \
    # apt-get autoremove -y && \
    # 清理包管理器缓存
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    echo "=== 清理完成 ==="

# ================================
# 设置环境变量和路径
# ================================
ENV PATH=${APACHE_PREFIX}/bin:${APR_PREFIX}/bin:${APR_UTIL_PREFIX}/bin:${PCRE_PREFIX}/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
ENV LD_LIBRARY_PATH=${APACHE_PREFIX}/lib:${APR_PREFIX}/lib:${APR_UTIL_PREFIX}/lib:${PCRE_PREFIX}/lib
ENV PKG_CONFIG_PATH=${APACHE_PREFIX}/lib/pkgconfig:${APR_PREFIX}/lib/pkgconfig:${APR_UTIL_PREFIX}/lib/pkgconfig:${PCRE_PREFIX}/lib/pkgconfig

# ================================
# 暴露端口
# ================================
# HTTP 标准端口
EXPOSE 80
# HTTPS 标准端口
EXPOSE 443
# Supervisor Web 管理界面端口
EXPOSE 9001

# ================================
# 数据卷挂载点
# ================================
VOLUME ["${APACHE_PREFIX}/htdocs", "${APACHE_PREFIX}/conf", "${APACHE_LOG_DIR}"]

# ================================
# 健康检查配置
# ================================
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD /usr/local/bin/health-check.sh

# ================================
# 工作目录
# ================================
WORKDIR ${APACHE_PREFIX}

# ================================
# 容器启动命令
# ================================
# 使用自定义启动脚本，集成 Supervisor 管理
CMD ["/usr/local/bin/apache-start.sh"]

# ================================
# 构建完成标识
# ================================
RUN echo "=== Apache HTTP Server Docker 镜像构建完成 ===" && \
    echo "Apache 版本: ${APACHE_VERSION}" && \
    echo "APR 版本: ${APR_VERSION}" && \
    echo "APR-Util 版本: ${APR_UTIL_VERSION}" && \
    echo "PCRE 版本: ${PCRE_VERSION}" && \
    echo "安装路径: ${APACHE_PREFIX}" && \
    echo "构建时间: $(date)" && \
    echo "=== 构建信息记录完成 ==="
