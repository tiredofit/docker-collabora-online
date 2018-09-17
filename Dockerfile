FROM tiredofit/ubuntu:16.04 as builder
LABEL maintainer="Dave Conroy (dave at tiredofit dot ca)"

### Set Environment Variables
ENV LIBREOFFICE_BRANCH=master \
    ## 6.0.6.2
    LIBREOFFICE_COMMIT=0857a8f6d8dd1b5b9114e9e0c1e1b6b98394434f \
    LOOL_BRANCH=master \
    ## 3.2.0.4
    LOOL_COMMIT=9927458251fd069e11efc8e83c78449497cc2048 \
    MAX_CONNECTIONS=5000 \
    ## Uses Approximately 20mb per document open
    MAX_DOCUMENTS=5000 

### Get Updates
RUN apt-get update && \
    apt-get -y install apt-transport-https && \
    echo "deb https://collaboraoffice.com/repos/Poco/ /" >> /etc/apt/sources.list.d/poco.list && \
    echo "deb-src http://archive.ubuntu.com/ubuntu/ xenial main restricted" >> /etc/apt/sources.list && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 0C54D189F4BA284D && \
    curl -sL https://deb.nodesource.com/setup_6.x | bash - && \
    \
    ## Install Poco Libs
    apt-get -y install \
            libpoco-dev \
            libpocodata60 \
            libpocofoundation60 \
            libpocojson60 \
            libpocodataodbc60 \
            libpococrypto60 \
            libpoconet60 \
            libpoconetssl60 \
            libpocoutil60 \
            libpocoxml60 \
            libpocozip60 \
            && \
    \
    mkdir -p /home/lool && \
    useradd lool -G sudo && \
    chown lool:lool /home/lool -R && \
    echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true | debconf-set-selections && \
    \
    ## Add Build Dependencies
    apt-get install -y \
            cpio \
            git \
            libcap-dev \
            libghc-zlib-dev \
            libpam0g-dev \
            libtool \
            nodejs \
            python-polib \
            sudo \
            translate-toolkit \
            ttf-mscorefonts-installer \
            wget \
            && \
    \
    apt-get build-dep -y \
            libreoffice \
            && \
    \
### Build Fetch LibreOffice - This will take a while..
    git clone -b ${LIBREOFFICE_BRANCH} https://github.com/LibreOffice/core.git /usr/src/libreoffice-core && \
    cd /usr/src/libreoffice-core && \
    echo "lo_sources_ver="`env | grep LIBREOFFICE_VERSION | cut -d'-' -f2` > sources.ver && \
    git reset --hard ${LIBREOFFICE_COMMIT} && \
    git submodule init && \
    git submodule update translations && \
    git submodule update dictionaries && \
    cd /usr/src/libreoffice-core && \
    echo "--disable-dbus \n\
--disable-dconf \n\
--disable-epm \n\
--disable-evolution2 \n\
--disable-ext-nlpsolver \n\
--disable-ext-wiki-publisher \n\
--disable-firebird-sdbc \n\
--disable-gio \n\
--disable-gstreamer-0-10 \n\
--disable-gstreamer-1-0 \n\
--disable-gtk \n\
--disable-gtk3 \n\
--disable-kde4 \n\
--disable-odk \n\
--disable-online-update \n\
--disable-pdfimport \n\
--disable-postgresql-sdbc \n\
--disable-report-builder \n\
--disable-scripting-beanshell \n\
--disable-scripting-javascript \n\
--disable-sdremote \n\
--disable-sdremote-bluetooth \n\
--enable-extension-integration \n\
--enable-mergelibs \n\
--enable-python=internal \n\
--enable-release-build \n\
--with-external-dict-dir=/usr/share/hunspell \n\
--with-external-hyph-dir=/usr/share/hyphen \n\
--with-external-thes-dir=/usr/share/mythes \n\
--with-fonts \n\
--with-galleries=no \n\
--with-lang=en-GB en-US\n\
--with-linker-hash-style=both \n\
--with-system-dicts \n\
--with-system-zlib \n\
--with-theme=galaxy \n\
--without-branding \n\
--without-help \n\
--without-java \n\
--without-junit \n\
--without-myspell-dicts \n\
--without-package-format \n\
--without-system-jars \n\
--without-system-jpeg \n\
--without-system-libpng \n\
--without-system-libxml \n\
--without-system-openssl \n\
--without-system-poppler \n\
--without-system-postgresql \n\
--prefix=/opt/libreoffice \n\
" > /usr/src/libreoffice-core/distro-configs/LibreOfficeOnline.conf && \
    ./autogen.sh --with-distro="LibreOfficeOnline" && \
    rm -rf /usr/src/libreoffice-core/translations /usr/src/lobreoffice-core/dictionaries && \
    chown -R lool /usr/src/libreoffice-core && \
    sudo -u lool make && \
    cd /usr/src/libreoffice-core && \
    mkdir -p /opt/libreoffice && \
    chown -R lool /opt/libreoffice && \
    sudo -u lool make install && \
    cp -R /usr/src/libreoffice-core/instdir/* /opt/libreoffice/ && \
    cd /usr/src && \
    \
### Build LibreOffice Online (Not as long as above)
    git clone -b ${LOOL_BRANCH} https://github.com/LibreOffice/online.git /usr/src/libreoffice-online && \
    cd /usr/src/libreoffice-online && \
    git reset --hard ${LOOL_COMMIT} && \
    npm install -g \
                bootstrap \
                browserify-css \
                d3 \
                d3 \
                eslint \
                evol-colorpicker \
                exorcist \
                jake \
                npm \
                uglify-js \
                && \
    \
    cd /usr/src/libreoffice-online && \
    ./autogen.sh && \
    ./configure --enable-silent-rules \
                --with-lokit-path=/usr/src/libreoffice-online/bundled/include \
                --with-lo-path=/opt/libreoffice \
                --with-max-connections=${MAX_CONNECTIONS} \
                --with-max-documents=${MAX_DOCUMENTS} \
                --with-logfile=/var/log/lool/lool.log \
                --prefix=/opt/lool \
                --sysconfdir=/etc \
                --localstatedir=/var && \
    ( cd loleaflet/po && ../../scripts/downloadpootle.sh ) && \
    ( cd loleaflet && make l10n) || exit 1 && \
    ( scripts/locorestrings.py /usr/src/libreoffice-online /usr/src/libreoffice-core/translations ) && \
    make -j`nproc` && \
    mkdir -p /opt/lool && \
    chown -R lool /opt/lool && \
    cp -R loolwsd.xml /opt/lool/ && \
    cp -R loolkitconfig.xcu /opt/lool && \
    make install && \
    cd /usr/src && \
    \
    apt-get autoremove -y && \
    apt-get clean && \
### Cleanup
    rm -rf /usr/src/* && \
    rm -rf /usr/share/doc && \
    rm -rf /usr/share/man && \
    rm -rf /usr/share/locale && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /var/log/*

FROM tiredofit/ubuntu:16.04
LABEL maintainer="Dave Conroy (dave at tiredofit dot ca)"

### Set Defaults
ENV ADMIN_USER=admin \
    ADMIN_PASS=libreoffice \
    LOG_LEVEL=warning \
    DICTIONARIES="en_GB en_US" \
    ENABLE_SMTP=false \
    PYTHONWARNINGS=ignore

### Grab Compiled Assets from builder image
COPY --from=builder /opt/ /opt/

### Install Dependencies
RUN adduser --quiet --system --group --home /opt/lool lool && \
    \
    apt-get update && \
    apt-get upgrade -y && \
    echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true | debconf-set-selections && \
    apt-get install -y\
             adduser \
             apt-transport-https \
             cpio \
             findutils \
             fonts-droid-fallback \
             fonts-noto-cjk \
             libcups2 \
             libfontconfig1 \
             libfreetype6 \
             libgl1-mesa-glx \
             libpam0g \
             libpng12-0 \
             libxcb-render0 \
             libxcb-shm0 \
             libxinerama1 \
             libxrender1 \
             locales-all \
             python3-requests \
             python3-websocket \
             sudo \
             ttf-mscorefonts-installer \
             && \
    \
    echo "deb https://collaboraoffice.com/repos/Poco/ /" >> /etc/apt/sources.list.d/poco.list && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 0C54D189F4BA284D && \
    apt-get update && \
    apt-get -y install \
                libpocodata60 \
                libpocofoundation60 \
                libpocojson60 \
                libpocodataodbc60 \
                libpococrypto60 \
                libpoconet60 \
                libpoconetssl60 \
                libpocoutil60 \
                libpocoxml60 \
                libpocozip60 \
                && \
    \
### Setup Directories and Permissions
    mkdir -p /etc/loolwsd && \
    mv /opt/lool/loolwsd.xml /etc/loolwsd/ && \
    mv /opt/lool/loolkitconfig.xcu /etc/loolwsd/ && \
    chown -R lool /etc/loolwsd && \
    mkdir -p /opt/lool/jails && \
    chown -R lool /opt/* && \
    mkdir -p /var/cache/loolwsd && \
    chown -R lool /var/cache/loolwsd && \
    setcap cap_fowner,cap_mknod,cap_sys_chroot=ep /opt/lool/bin/loolforkit && \
    setcap cap_sys_admin=ep /opt/lool/bin/loolmount && \
    mkdir -p /usr/share/hunspell && \
    mkdir -p /usr/share/hyphen && \
    mkdir -p /usr/share/mythes && \
    \
### Setup LibreOffice Online Jails
    sudo -u lool /opt/lool/bin/loolwsd-systemplate-setup /opt/lool/systemplate /opt/libreoffice && \
    \
    apt-get autoremove -y && \
    apt-get clean && \
    \
    rm -rf /usr/src/* && \
    rm -rf /usr/share/doc && \
    rm -rf /usr/share/man && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /var/log/* && \
    mkdir -p /var/log/lool && \
    touch /var/log/lool/lool.log && \
    chown -R lool /var/log/lool

### Networking Configuration
EXPOSE 9980

### Assets
ADD install /

