FROM docker.io/tiredofit/debian:bookworm as builder
LABEL maintainer="Dave Conroy (dave at tiredofit dot ca)"
LABEL org.opencontainers.image.source="https://github.com/tiredofit/docker-collabora-online"

### Buildtime arguments
ARG COLLABORA_ONLINE_VERSION
ARG COLLABORA_ONLINE_REPO_URL
ARG LIBREOFFICE_VERSION
ARG LIBREOFFICE_REPO_URL
ARG MAX_CONNECTIONS
ARG MAX_DOCUMENTS
ARG APP_NAME
ARG APP_BRAND

### Environment Variables
ENV COLLABORA_ONLINE_VERSION=${COLLABORA_ONLINE_VERSION:-"cp-23.05.7-1"} \
    COLLABORA_ONLINE_REPO_URL=${COLLABORA_ONLINE_REPO_URL:-"https://github.com/CollaboraOnline/online"} \
    #
    LIBREOFFICE_VERSION=${LIBREOFFICE_VERSION:-"cp-23.05.7-1"} \
    LIBREOFFICE_REPO_URL=${LIBREOFFICE_REPO_URL:-"https://github.com/LibreOffice/core"} \
    #
    APP_NAME=${APP_NAME:-"Document Editor"} \
    APP_BRAND=${APP_BRAND:-"unbranded"} \
    #
    POCO_VERSION=${POCO_VERSION:-"poco-1.12.5p2-release.tar.gz"} \
    POCO_URL=${POCO_URL:-"https://github.com/pocoproject/poco/archive/"} \
    #
    MAX_CONNECTIONS=${MAX_CONNECTIONS:-"100000"} \
    ## Uses Approximately 20mb per document open
    MAX_DOCUMENTS=${MAX_DOCUMENTS:-"100000"}

COPY build-assets /build-assets

RUN source /assets/functions/00-container && \
    set -x && \
    echo "deb-src http://deb.debian.org/debian $(cat /etc/os-release |grep "VERSION=" | awk 'NR>1{print $1}' RS='(' FS=')') main" >> /etc/apt/sources.list && \
    echo "deb http://deb.debian.org/debian $(cat /etc/os-release |grep "VERSION=" | awk 'NR>1{print $1}' RS='(' FS=')') contrib" >> /etc/apt/sources.list && \
    package update && \
    apt-get -o Dpkg::Options::="--force-confold" upgrade -y && \
    \
### Setup Distribution
    echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true | debconf-set-selections && \
    \
    mkdir -p /home/cool && \
    useradd cool -G sudo && \
    chown cool:cool /home/cool -R && \
    \
    BUILD_DEPS=' \
                    adduser \
                    automake \
                    build-essential \
                    bison \
                    cpio \
                    default-jre \
                    devscripts \
                    flex \
                    fontconfig \
                    g++ \
                    git \
                    gperf \
                    inotify-tools \
                    libcap-dev \
                    libcap2-bin \
                    libcppunit-dev \
                    libghc-zlib-dev \
                    libkrb5-dev \
                    libpam-dev \
                    libpam0g-dev \
                    libpng-dev \
                    libssl-dev \
                    libtool \
                    libubsan1 \
                    libx11-dev \
                    libzstd-dev \
                    locales-all \
                    m4 \
                    nasm \
                    nodejs \
                    npm \
                    openssl \
                    pkg-config \
                    procps \
                    python3-lxml \
                    python3-polib \
                    rsync \
                    sudo \
                    translate-toolkit \
                    ttf-mscorefonts-installer \
                    unzip \
                    wget \
                    zip \
                ' && \
    ## Add Build Dependencies
    package install -y \
                            ${BUILD_DEPS} \
                        && \
    \
    package build-dep -y \
                            libreoffice \
                        && \
    \
### Build Poco
    mkdir -p /usr/src/poco && \
    curl -sSL ${POCO_URL}${POCO_VERSION} | tar xvfz - --strip 1 -C /usr/src/poco && \
    cd /usr/src/poco && \
    ./configure \
        --static \
        --no-tests \
        --no-samples \
        --no-sharedlibs \
        --cflags="-fPIC" \
        --omit=Zip,Data,Data/SQLite,Data/ODBC,Data/MySQL,MongoDB,PDF,CppParser,PageCompiler,Redis,Encodings \
        --prefix=/opt/poco \
        && \
    make -j$(nproc) && \
    make install && \
    \
    ### Build Fetch LibreOffice - This will take a while..
    clone_git_repo ${LIBREOFFICE_REPO_URL} ${LIBREOFFICE_VERSION} ${GIT_REPO_SRC_CORE} && \
    if [ -d "/build-assets/core/src" ] && [ -n "$(ls -A "/build-assets/core/src" 2>/dev/null)" ]; then cp -R /build-assets/core/src/* / ; fi; \
    if [ -d "/build-assets/core/scripts" ] && [ -n "$(ls -A "/build-assets/core/scripts" 2>/dev/null)" ]; then for script in /build-assets/core/scripts/*.sh; do echo "** Applying $script"; bash $script; done && \ ; fi ; \
    sed -i "s|--enable-symbols|--disable-symbols|g" ${GIT_REPO_SRC_CORE}/distro-configs/CPLinux-LOKit.conf && \
    \
    echo "--prefix=/opt/libreoffice" >> ${GIT_REPO_SRC_CORE}/distro-configs/CPLinux-LOKit.conf && \
    ./autogen.sh \
            --with-distro="CPLinux-LOKit" \
            --disable-epm \
            --without-package-format && \
    chown -R cool ${GIT_REPO_SRC_CORE} && \
    sudo -u cool make fetch && \
    sudo -u cool make -j$(nproc) build && \
    mkdir -p /opt/libreoffice && \
    chown -R cool /opt/libreoffice && \
    cp -R ${GIT_REPO_SRC_CORE}/instdir/* /opt/libreoffice/ && \
    \
    ### Build LibreOffice Online (Not as long as above)
    clone_git_repo ${COLLABORA_ONLINE_REPO_URL} ${COLLABORA_ONLINE_VERSION} ${GIT_REPO_SRC_ONLINE} && \
    if [ -d "/build-assets/online/src" ] ; then cp -R /build-assets/online/src/* ${GIT_REPO_SRC_ONLINE} ; fi; \
    if [ -d "/build-assets/online/scripts" ] ; then for script in /build-assets/online/scripts/*.sh; do echo "** Applying $script"; bash $script; done && \ ; fi ; \
    sed -i \
        -e "s|Collabora Online Development Edition|${APP_NAME}|g" \
        -e "s|unbranded|${APP_BRAND}|g" \
        ${GIT_REPO_SRC_ONLINE}/configure.ac \
        ${GIT_REPO_SRC_ONLINE}/browser/admin/admin.strings.js \
        ${GIT_REPO_SRC_ONLINE}/browser/src/control/Toolbar.js \
        ${GIT_REPO_SRC_ONLINE}/browser/src/core/Socket.js \
        ${GIT_REPO_SRC_ONLINE}/browser/src/layer/marker/ProgressOverlay.js \
        ${GIT_REPO_SRC_ONLINE}/browser/src/map/Clipboard.js \
        ${GIT_REPO_SRC_ONLINE}/browser/welcome/*.html \
        && \
    ./autogen.sh && \
    ./configure --enable-silent-rules \
                --with-lokit-path="${GIT_REPO_SRC_CORE}/include" \
                --with-lo-path=/opt/libreoffice \
                --with-max-connections=${MAX_CONNECTIONS} \
                --with-max-documents=${MAX_DOCUMENTS} \
                --with-logfile=/var/log/cool/cool.log \
                --prefix=/opt/cool \
                --sysconfdir=/etc \
                --localstatedir=/var \
                --with-poco-includes=/opt/poco/include \
                --with-poco-libs=/opt/poco/lib \
                --with-app-name="${APP_NAME}" \
                --with-vendor="tiredofit@github" \
                ${COOL_CONFIGURE_ARGS} \
                && \
    make -j$(nproc) && \
    mkdir -p /opt/cool && \
    chown -R cool /opt/cool && \
    cp -R coolwsd.xml /opt/cool/ && \
    cp -R coolkitconfig.xcu /opt/cool && \
    make install && \
    \
    ### Cleanup
    cd / && \
    package cleanup && \
    rm -rf \
            /usr/share/doc \
            /usr/share/locale \
            /usr/share/man \
            /usr/src/* \
            /var/log/*

FROM docker.io/tiredofit/debian:bookworm
LABEL maintainer="Dave Conroy (dave at tiredofit dot ca)"
LABEL org.opencontainers.image.source="https://github.com/tiredofit/docker-collabora-online"

ENV ADMIN_USER=admin \
    ADMIN_PASS=collaboraonline \
    CONTAINER_ENABLE_MESSAGING=FALSE \
    IMAGE_NAME="tiredofit/collabora-online" \
    IMAGE_REPO_URL="https://github.com/tiredofit/docker-collabora-online/"

COPY --from=builder /opt/ /opt/
COPY CHANGELOG.md /assets/.changelogs/tiredofit_docker-collabora-online.md

COPY build-assets /build-assets

RUN source /assets/functions/00-container && \
    set -x && \
    adduser --quiet --system --group --home /opt/cool cool && \
    \
    echo "deb http://deb.debian.org/debian $(cat /etc/os-release |grep "VERSION=" | awk 'NR>1{print $1}' RS='(' FS=')') contrib" >> /etc/apt/sources.list && \
    echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true | debconf-set-selections && \
    package update && \
    apt-get -o Dpkg::Options::="--force-confold" upgrade -y && \
    package install \
                        apt-transport-https \
                        cpio \
                        findutils \
                        fontconfig \
                        hunspell \
                        hunspell-en-ca \
                        hunspell-en-gb \
                        hunspell-en-us \
                        inotify-tools \
                        libcap2-bin \
                        libcups2 \
                        libfontconfig1 \
                        libfreetype6 \
                        libgl1-mesa-glx \
                        libpam0g \
                        libpng16-16 \
                        libsm6 \
                        libubsan1 \
                        libxcb-render0 \
                        libxcb-shm0 \
                        libxinerama1 \
                        libxrender1 \
                        locales \
                        locales-all \
                        openssl \
                        openssh-client \
                        procps \
                        python3-requests \
                        python3-websocket \
                        ttf-mscorefonts-installer \
                        && \
    \
    mkdir -p /etc/coolwsd && \
    mv /opt/cool/coolwsd.xml /etc/coolwsd/ && \
    mv /opt/cool/coolkitconfig.xcu /etc/coolwsd/ && \
    chown -R cool /etc/coolwsd && \
    mkdir -p /opt/cool/child-roots && \
    chown -R cool /opt/* && \
    mkdir -p /var/cache/coolwsd && \
    chown -R cool /var/cache/coolwsd && \
    setcap cap_fowner,cap_chown,cap_mknod,cap_sys_chroot=ep /opt/cool/bin/coolforkit && \
    setcap cap_sys_admin=ep /opt/cool/bin/coolmount && \
    mkdir -p /usr/share/hunspell && \
    mkdir -p /usr/share/hyphen && \
    mkdir -p /usr/share/mythes && \
    mkdir -p /var/cache/coolwsd && \
    chown -R cool /var/cache/coolwsd && \
    mkdir -p /var/log/cool && \
    touch /var/log/cool/coolwsd.log && \
    chown -R cool /var/log/cool && \
    \
    sudo -u cool /opt/cool/bin/coolwsd-systemplate-setup /opt/cool/systemplate /opt/libreoffice && \
    \
    if [ -d "/build-assets/container/src" ] && [ -n "$(ls -A "/build-assets/container/src" 2>/dev/null)" ]; then cp -R /build-assets/container/src/* / ; fi; \
    if [ -d "/build-assets/container/scripts" ] && [ -n "$(ls -A "/build-assets/container/scripts" 2>/dev/null)" ]; then for script in /build-assets/container/scripts/*.sh; do echo "** Applying $script"; bash $script; done && \ ; fi ; \
    package cleanup && \
    rm -rf \
            /build-assets \
            /tmp/* \
            /usr/src/* \
            /usr/share/doc \
            /usr/share/man \
            /var/lib/apt/lists/* \
            /var/log/*

EXPOSE 9980

### Assets
COPY install /
