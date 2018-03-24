FROM tiredofit/debian:stretch
LABEL maintainer="Dave Conroy (dave at tiredofit dot ca)"

### Set Environment Variables
ENV ADMIN_USER=admin \
    ADMIN_PASS=libreoffice \
    LIBREOFFICE_BRANCH=master \
    LIBREOFFICE_COMMIT=376eaac300a303c4ad2193fb7f6a7522caf550b9 \
    LOOL_BRANCH=master \
    LOOL_COMMIT=fba8488b2549f531fcc0d4e1e7228a7345c2f57d \
    MAX_CONNECTIONS=2000 \
    MAX_DOCUMENTS=1000 \
    POCO_VERSION=1.9.0

### Add User Accounts
RUN useradd lool -G sudo && \
    mkdir /home/lool && \
    chown lool:lool /home/lool -R && \

### Add Repositories
    echo "deb http://ftp.us.debian.org/debian/ jessie-backports main" >>/etc/apt/sources.list && \
    echo "deb-src http://ftp.us.debian.org/debian/ jessie-backports main" >>/etc/apt/sources.list && \
    echo "deb http://deb.debian.org/debian stretch contrib" >> /etc/apt/sources.list && \
    curl -sL https://deb.nodesource.com/setup_6.x | bash - && \
    
### Downgrade LibSSL
    echo "Package: openssl libssl1.0.0 libssl-dev libssl-doc" >> /etc/apt/preferences.d/00_ssl && \
    echo "Pin: release a=jessie-backports" >> /etc/apt/preferences.d/00_ssl && \
    echo "Pin-Priority: 1001" >> /etc/apt/preferences.d/00_ssl && \
    apt-get update && \
    apt-get install openssl libssl-dev locales -y --allow-downgrades && \

### Setup Distribution
    echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true | debconf-set-selections && \
    apt-get upgrade -y && \
    apt-get install -y \
            ant \
            automake \
            bison \
            build-essential \
            ccache \
            cpio \
            doxygen \
            flex \
            g++ \
            git \
            gperf \
            graphviz \
            junit4 \
            libcap2-bin \
            libcap-dev \
            libcppunit-dev \
            libcppunit-doc \
            libcunit1 \
            libcunit1-dev \
            libcups2-dev \
            libegl1-mesa-dev \
            libfontconfig1-dev \
            libgl1-mesa-dev \
            libgstreamer1.0-dev \
            libgstreamer-plugins-base1.0-dev \
            libgtk2.0-dev \
            libgtk-3-dev \
            libkrb5-dev \
            libpam0g-dev \
            libpcap0.8 \
            libpcap0.8-dev \
            libpng16.16 \
            libpng-dev \
            libssl-dev \
            libtool \
            libxml2-utils \
            libxrandr-dev \
            libxrender-dev \
            libxslt1-dev \
            libxt-dev \
            lsof \
            m4 \
            make \
            nasm \
            nodejs \
            openjdk-8-jdk \
            openssl \
            pkg-config \
            procps \
            python3-dev \
            python-dev \
            python-lxml \
            python-polib \
            sudo \
            ttf-mscorefonts-installer \
            uuid-runtime \
            wget \
            xsltproc \
            zip \
            && \
            
    apt-get build-dep -y \
            libreoffice \
            && \
            

### Build and Install Poco Libraries
    mkdir -p /usr/src/poco && \
    curl -sSL https://pocoproject.org/releases/poco-${POCO_VERSION}/poco-${POCO_VERSION}-all.tar.gz | tar xvfz - --strip 1 -C /usr/src/poco && \
    cd /usr/src/poco && \
    ./configure --prefix=/opt/poco && \
    make install

### Build and Install Libreoffice (This'll take a while)
RUN git clone -b ${LIBREOFFICE_BRANCH} https://github.com/LibreOffice/core.git /usr/src/libreoffice-core && \
    cd /usr/src/libreoffice-core && \
    git reset --hard ${LIBREOFFICE_COMMIT} && \
    chown -R lool /usr/src/libreoffice-core && \
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
--with-lang=\n\
--with-linker-hash-style=both \n\
--with-system-dicts \n\
--with-system-zlib \n\
--with-theme=tango \n\
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
    sudo -u lool ./autogen.sh --with-distro="LibreOfficeOnline" && \
    sudo -u lool make && \
    cd /usr/src/libreoffice-core && \
    mkdir -p /opt/libreoffice && \
    chown -R lool /opt/libreoffice && \
    sudo -u lool make install && \
    sudo -u lool cp -R /usr/src/libreoffice-core/instdir /opt/libreoffice/ && \
    cd /usr/src 

### Build LibreOffice Online (Not as long as above)
RUN git clone -b ${LOOL_BRANCH} https://github.com/LibreOffice/online.git /usr/src/libreoffice-online && \
    npm install -g npm && \
    npm install -g jake && \
    chown -R lool /usr/src/libreoffice-online && \
    cd /usr/src/libreoffice-online && \
    sudo -u lool git reset --hard ${LOOL_COMMIT} && \
    sudo -u lool ./autogen.sh && \
    sudo -u lool ./configure --enable-silent-rules \
                --with-lokit-path=/usr/src/libreoffice-online/bundled/include \
                --with-lo-path=/usr/src/libreoffice-online/instdir \
                --with-max-connections=${MAX_CONNECTIONS} \
                --with-max-documents=${MAX_DOCUMENTS} \
                --with-poco-includes=/opt/poco/include \
                --with-poco-libs=/opt/poco/lib \
                --with-logfile=/var/log/lool/lool.log \
                --prefix=/opt/lool \
                --sysconfdir=/etc \
                --localstatedir=/var && \
    sudo -u lool make -j$cpu && \
    mkdir -p /opt/lool && \
    chown -R lool /opt/lool && \
    sudo -u lool make install && \
    cd /usr/src && \

### Setup Directories and Permissions
    mkdir -p /opt/lool/jails && \
    chown -R lool /opt/* && \
    mkdir -p /var/cache/loolwsd && \
    chown -R lool /var/cache/loolwsd && \
    mkdir -p /var/log/lool && \
    chown -R lool /var/log/lool && \
    setcap cap_fowner,cap_mknod,cap_sys_chroot=ep /opt/lool/bin/loolforkit && \
    setcap cap_sys_admin=ep /opt/lool/bin/loolmount && \
    mkdir -p /usr/share/hunspell && \
    mkdir -p /usr/share/hyphen && \
    mkdir -p /usr/share/mythes && \

### Setup LibreOffice Online Jails
    sudo -u lool /opt/lool/bin/loolwsd-systemplate-setup /opt/lool/systemplate /opt/libreoffice/instdir/

### Cleanup
RUN npm uninstall -g npm jake && \
    apt-get purge -y \
            ant \
            automake \
            binutils-mingw-w64-i686 \
            bison \
            build-essential \
            ccache \
            coinor-libcbc-dev \
            coinor-libcoinmp-dev \
            flex \
            g++ \
            gcc \
            gcc-6 \
            git \
            gperf \
            graphviz \
            java-common \
            junit4 \
            libcap-dev \
            libcppunit-dev \
            libcppunit-doc \
            libcunit1-dev \
            libegl1-mesa-dev \
            libfontconfig1-dev \
            libgl1-mesa-dev \
            libgtk-3-dev \
            libgtk2.0-dev \
            libkrb5-dev \
            libpam0g-dev \
            libpcap0.8 \
            libpcap0.8-dev \
            libpng-dev \
            librevenge-dev \
            libsane-dev \
            libssl-dev \
            libstdc++-6-dev \
            libvisio-dev \
            libwpg-dev \
            libxrandr-dev \
            libxrender-dev \
            libxslt1-dev \
            libxt-dev \
            linux-libc-dev \
            m4 \
            make \
            manpages \
            manpages-dev \
            mingw-w64-i686-dev \
            nasm \
            nodejs \
            openjdk-8-jdk \
            perl \
            pkg-config \
            python \
            python-dev \
            python-lxml \
            python-polib \
            python2.7-minimal \
            python3 \
            python3-dev \
            unixodbc-dev \
            wget \
            x11-* \
            zlib1g-dev \
            doxygen \
            libx11-doc \
            ucpp \
            libapache-pom-java \
            libx11-dev \
            libxdmcp-dev \
            libc-l10n \
            locales \
            lp-solve \
            fastjar \
            x11proto-core-dev \
            && \

    apt-get purge --auto-remove -y && \

## Install Last little bit of packages that may have been removed during cleanup
    apt-get install -y \
            cups \
            libgl1-mesa-glx \
            libsm6 \
            libx11-6 \
            && \

    apt-get clean && \

## Filesystem Cleanup
    rm -rf /usr/src/* && \
    rm -rf /home/lool/.npm /root/.npm && \
    rm -rf /home/lool/.ccache /root/.ccache && \
    rm -rf /usr/share/doc && \
    rm -rf /usr/share/man && \
    rm -rf /usr/share/locale && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /var/log/*

### Networking Configuration
EXPOSE 9980

### Assets
ADD install /
