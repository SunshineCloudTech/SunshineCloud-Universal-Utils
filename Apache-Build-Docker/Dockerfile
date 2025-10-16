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
ENV APACHE_PREFIX=/SunshineCloud/Apache/apache2
ENV APR_PREFIX=/SunshineCloud/Apache/apr
ENV APR_UTIL_PREFIX=/SunshineCloud/Apache/apr-util
ENV PCRE_PREFIX=/SunshineCloud/Apache/pcre

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
ENV APACHE_DOCUMENT_ROOT=/SunshineCloud/Apache/apache2/htdocs
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
    # # ls -la ${APACHE_PREFIX}/conf/ && \
    echo "=== Apache HTTP Server 编译安装完成 ==="

# ================================
# 配置 Apache
# ================================
RUN set -eux && \
    echo "=== 验证 Apache 配置文件 ===" && \
    # ls -la ${APACHE_PREFIX}/conf/ && \
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
# 清理构建文件
# ================================
# RUN set -eux && \
#     echo "=== 清理构建文件和缓存 ===" && \
#     # 清理源码目录
#     rm -rf ${SOURCES_DIR} ${BUILD_DIR} /tmp/* && \
#     # 清理编译工具（可选，会减小镜像体积但降低调试能力）
#     # apt-get purge -y gcc g++ make autoconf automake libtool && \
#     # apt-get autoremove -y && \
#     # 清理包管理器缓存
#     apt-get clean && \
#     rm -rf /var/lib/apt/lists/* && \
#     echo "=== 清理完成 ==="

# ================================
# 设置环境变量和路径
# ================================
ENV PATH=${APACHE_PREFIX}/bin:${APR_PREFIX}/bin:${APR_UTIL_PREFIX}/bin:${PCRE_PREFIX}/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
ENV LD_LIBRARY_PATH=${APACHE_PREFIX}/lib:${APR_PREFIX}/lib:${APR_UTIL_PREFIX}/lib:${PCRE_PREFIX}/lib
ENV PKG_CONFIG_PATH=${APACHE_PREFIX}/lib/pkgconfig:${APR_PREFIX}/lib/pkgconfig:${APR_UTIL_PREFIX}/lib/pkgconfig:${PCRE_PREFIX}/lib/pkgconfig
