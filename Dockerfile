FROM tiredofit/debian:buster as builder
LABEL maintainer="Dave Conroy (dave at tiredofit dot ca)"

### Buildtime arguments
ARG COLLABORA_ONLINE_BRANCH
ARG COLLABORA_ONLINE_VERSION
ARG COLLABORA_ONLINE_REPO_URL
ARG LIBREOFFICE_BRANCH
ARG LIBREOFFICE_VERSION
ARG LIBREOFFICE_REPO_URL
ARG MAX_CONNECTIONS
ARG MAX_DOCUMENTS
ARG APP_NAME

### Environment Variables
ENV COLLABORA_ONLINE_BRANCH=${COLLABORA_ONLINE_BRANCH:-"master"} \
    COLLABORA_ONLINE_VERSION=${COLLABORA_ONLINE_VERSION:-"cp-6.4.10-5"} \
    COLLABORA_ONLINE_REPO_URL=${COLLABORA_ONLINE_REPO_URL:-"https://github.com/CollaboraOnline/online"} \
    #
    LIBREOFFICE_BRANCH=${LIBREOFFICE_BRANCH:-"master"} \
    LIBREOFFICE_VERSION=${LIBREOFFICE_VERSION:-"cp-6.4-45"} \
    LIBREOFFICE_REPO_URL=${LIBREOFFICE_REPO_URL:-"https://github.com/LibreOffice/core"} \
    #
    APP_NAME=${APP_NAME:-"Document Editor"} \
    #
    POCO_VERSION=${POCO_VERSION:-"poco-1.11.0-release.tar.gz"} \
    POCO_URL=${POCO_URL:-"https://github.com/pocoproject/poco/archive/"} \
    #
    MAX_CONNECTIONS=${MAX_CONNECTIONS:-"100000"} \
    ## Uses Approximately 20mb per document open
    MAX_DOCUMENTS=${MAX_DOCUMENTS:-"100000"}

ADD build-assets /build-assets

### Get Updates
RUN set -x && \
### Add Repositories
    apt-get update && \
    apt-get -o Dpkg::Options::="--force-confold" upgrade -y && \
    echo "deb-src http://deb.debian.org/debian buster main" >> /etc/apt/sources.list && \
    echo "deb http://deb.debian.org/debian buster contrib" >> /etc/apt/sources.list && \
    curl -sL https://deb.nodesource.com/setup_14.x | bash - && \
    \
### Setup Distribution
    echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true | debconf-set-selections && \
    \
    mkdir -p /home/lool && \
    useradd lool -G sudo && \
    chown lool:lool /home/lool -R && \
    \
    BUILD_DEPS=' \
            adduser \
            automake \
            build-essential \
            cpio \
            default-jre \
            devscripts \
            fontconfig \
            g++ \
            git \
            inotify-tools \
            libcap-dev \
            libcap2-bin \
            libcppunit-dev \
            libghc-zlib-dev \
            libkrb5-dev \
            libpam-dev \
            libpam0g-dev \
            libpng16-16 \
            libssl-dev \
            libtool \
            libubsan1 \
            locales-all \
            m4 \
            nasm \
            nodejs \
            openssl \
            pkg-config \
            procps \
            python3-lxml \
            python3-polib \
            python-polib \
            sudo \
            translate-toolkit \
            ttf-mscorefonts-installer \
            wget \
    ' && \
    ## Add Build Dependencies
    apt-get install -y \
            ${BUILD_DEPS} \
            && \
    \
    apt-get build-dep -y \
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
    git clone -b ${LIBREOFFICE_BRANCH} ${LIBREOFFICE_REPO_URL} /usr/src/libreoffice-core && \
    cd /usr/src/libreoffice-core && \
    git checkout ${LIBREOFFICE_VERSION} && \
    if [ -d "/build-assets/core/src" ] ; then cp -R /build-assets/core/src/* /usr/src/libreoffice-core ; fi; \
    if [ -d "/build-assets/core/scripts" ] ; then for script in /build-assets/core/scripts/*.sh; do echo "** Applying $script"; bash $script; done && \ ; fi ; \
    sed -i "s|--enable-symbols|--disable-symbols|g" /usr/src/libreoffice-core/distro-configs/CPLinux-LOKit.conf && \
    \
    echo "--prefix=/opt/libreoffice" >> /usr/src/libreoffice-core/distro-configs/CPLinux-LOKit.conf  && \
    ./autogen.sh \
            --with-distro="CPLinux-LOKit" \
            --disable-epm \
            --without-package-format && \
    chown -R lool /usr/src/libreoffice-core && \
    sudo -u lool make fetch && \
    sudo -u lool make -j$(nproc) build-nocheck && \
    mkdir -p /opt/libreoffice && \
    chown -R lool /opt/libreoffice && \
    cp -R /usr/src/libreoffice-core/instdir/* /opt/libreoffice/ && \
    \
    ### Build LibreOffice Online (Not as long as above)
    git clone -b ${COLLABORA_ONLINE_BRANCH} ${COLLABORA_ONLINE_REPO_URL} /usr/src/libreoffice-online && \
    cd /usr/src/libreoffice-online && \
    git checkout ${COLLABORA_ONLINE_VERSION} && \
    if [ -d "/build-assets/online/src" ] ; then cp -R /build-assets/online/src/* /usr/src/libreoffice-online ; fi; \
    if [ -d "/build-assets/online/scripts" ] ; then for script in /build-assets/online/scripts/*.sh; do echo "** Applying $script"; bash $script; done && \ ; fi ; \
    sed -i "s|Collabora Online Development Edition|${APP_NAME}|g" /usr/src/libreoffice-online/configure.ac && \
    sed -i "s|Collabora Online Development Edition|${APP_NAME}|g" /usr/src/libreoffice-online/loleaflet/admin/admin.strings.js && \
    sed -i "s|Collabora Online Development Edition|${APP_NAME}|g" /usr/src/libreoffice-online/loleaflet/src/control/Toolbar.js && \
    sed -i "s|Collabora Online Development Edition|${APP_NAME}|g" /usr/src/libreoffice-online/loleaflet/src/core/Socket.js && \
    sed -i "s|Collabora Online Development Edition|${APP_NAME}|g" /usr/src/libreoffice-online/loleaflet/src/layer/marker/ProgressOverlay.js && \
    sed -i "s|Collabora Online Development Edition|${APP_NAME}|g" /usr/src/libreoffice-online/loleaflet/src/map/Clipboard.js && \
    sed -i "s|Collabora Online Development Edition|${APP_NAME}|g" /usr/src/libreoffice-online/loleaflet/welcome/*.html && \
    ./autogen.sh && \
    ./configure --enable-silent-rules \
                --with-lokit-path="/usr/src/libreoffice-core/include" \
                --with-lo-path=/opt/libreoffice \
                --with-max-connections=${MAX_CONNECTIONS} \
                --with-max-documents=${MAX_DOCUMENTS} \
                --with-logfile=/var/log/lool/lool.log \
                --prefix=/opt/lool \
                --sysconfdir=/etc \
                --localstatedir=/var \
                --with-poco-includes=/opt/poco/include \
                --with-poco-libs=/opt/poco/lib \
                --with-app-name="${APP_NAME}" \
                --with-vendor="tiredofit@github" \
                && \
    ( scripts/locorestrings.py /usr/src/libreoffice-online /usr/src/libreoffice-core/translations ) && \
    ( scripts/unocommands.py --update /usr/src/libreoffice-online /usr/src/libreoffice-core ) && \
    ( scripts/unocommands.py --translate /usr/src/libreoffice-online /usr/src/libreoffice-core/translations ) && \
    make -j$(nproc) && \
    mkdir -p /opt/lool && \
    chown -R lool /opt/lool && \
    cp -R loolwsd.xml /opt/lool/ && \
    cp -R loolkitconfig.xcu /opt/lool && \
    make install && \
    \
    ### Cleanup
    cd / && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /usr/src/* && \
    rm -rf /usr/share/doc && \
    rm -rf /usr/share/man && \
    rm -rf /usr/share/locale && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /var/log/*

FROM tiredofit/debian:buster
LABEL maintainer="Dave Conroy (dave at tiredofit dot ca)"

### Set Defaults
ENV ADMIN_USER=admin \
    ADMIN_PASS=libreoffice \
    CONTAINER_ENABLE_MESSAGING=FALSE

### Grab Compiled Assets from builder image
COPY --from=builder /opt/ /opt/

ADD build-assets /build-assets

### Install Dependencies
RUN set -x && \
    adduser --quiet --system --group --home /opt/lool lool && \
    \
### Add Repositories
    echo "deb http://deb.debian.org/debian buster contrib" >> /etc/apt/sources.list && \
    echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true | debconf-set-selections && \
    apt-get update && \
    apt-get -o Dpkg::Options::="--force-confold" upgrade -y && \
    apt-get install -y\
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
             libubsan0 \
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
### Setup Directories and Permissions
    mkdir -p /etc/loolwsd && \
    mv /opt/lool/loolwsd.xml /etc/loolwsd/ && \
    mv /opt/lool/loolkitconfig.xcu /etc/loolwsd/ && \
    chown -R lool /etc/loolwsd && \
    mkdir -p /opt/lool/child-roots && \
    chown -R lool /opt/* && \
    mkdir -p /var/cache/loolwsd && \
    chown -R lool /var/cache/loolwsd && \
    setcap cap_fowner,cap_chown,cap_mknod,cap_sys_chroot=ep /opt/lool/bin/loolforkit && \
    setcap cap_sys_admin=ep /opt/lool/bin/loolmount && \
    mkdir -p /usr/share/hunspell && \
    mkdir -p /usr/share/hyphen && \
    mkdir -p /usr/share/mythes && \
    mkdir -p /var/cache/loolwsd && \
    chown -R lool /var/cache/loolwsd && \
    mkdir -p /var/log/lool && \
    touch /var/log/lool/loolwsd.log && \
    chown -R lool /var/log/lool && \
    \
### Setup LibreOffice Online Jails
    sudo -u lool /opt/lool/bin/loolwsd-systemplate-setup /opt/lool/systemplate /opt/libreoffice && \
    \
    if [ -d "/build-assets/container/src" ] ; then cp -R /build-assets/container/src/* /usr/src/libreoffice-container ; fi; \
    if [ -d "/build-assets/container/scripts" ] ; then for script in /build-assets/container/scripts/*.sh; do echo "** Applying $script"; bash $script; done && \ ; fi ; \
    apt-get autoremove -y && \
    apt-get clean && \
    \
    rm -rf /usr/src/* && \
    rm -rf /usr/share/doc && \
    rm -rf /usr/share/man && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /var/log/* && \
    rm -rf /build-assets && \
    rm -rf /tmp/*

### Networking Configuration
EXPOSE 9980

### Assets
ADD install /
