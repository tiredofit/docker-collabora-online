FROM tiredofit/debian:buster as builder
LABEL maintainer="Dave Conroy (dave at tiredofit dot ca) - some changes by joerg dot schulz at elternserver dot de"
# changes stretch->buster. nodejs from debian repo. parameters for lool repositories (to be finalized)

ARG lo_src_commit
ARG lool_src_branch
ARG lo_src_branch
ARG lo_src_repo

### Set Environment Variables
ENV LIBREOFFICE_BRANCH=$lo_src_branch \
    LO_REPOSITORY=$lo_src_repo \
    ## cp-6.0.30
    LIBREOFFICE_COMMIT=$lo_src_commit \
    # LIBREOFFICE_COMMIT=3ef1164bc3a13af481102e0abef06929c53bad8b \
    LOOL_BRANCH=master \
    ## 4.0.4.1
    # LOOL_COMMIT=a2132266584381c875fa707446417e259753e2f5 \
    LOOL_COMMIT=$lool_src_commit \
    MAX_CONNECTIONS=5000 \
    ## Uses Approximately 20mb per document open
    MAX_DOCUMENTS=5000 \
    POCO_VERSION=1.9.0

### Get Updates
RUN set -x && \
### Add Repositories
    find /var/lib/apt/lists/ -mtime -1 |grep -q partial || apt-get update && apt-get upgrade -y && \
    # apt-get update && \
    apt-get -o Dpkg::Options::="--force-confold" upgrade -y && \
    echo "deb-src http://deb.debian.org/debian buster main" >> /etc/apt/sources.list && \
    echo "deb http://deb.debian.org/debian buster contrib" >> /etc/apt/sources.list && \
    # curl -sL https://deb.nodesource.com/setup_6.x | bash - && \
    \
### Setup Distribution
    echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true | debconf-set-selections && \
    apt-get update && \
    \
    mkdir -p /home/lool && \
    useradd lool -G sudo && \
    chown lool:lool /home/lool -R && \
    \
    ## Add Build Dependencies
    apt-get install -y \
            cpio \
            git \
            libcap-dev \
            libghc-zlib-dev \
            libpam0g-dev \
            libssl-dev \
            libtool \
            nasm \
            nodejs \
            openssl \
            python-polib \
            sudo \
            make \
            translate-toolkit \
            ttf-mscorefonts-installer \
            wget \
            ## stolen from husisusi
              wget zip make procps automake bison ccache \
              flex g++ git gperf graphviz junit4 libcap-dev libcppunit-dev build-essential \
              libcppunit-doc libcunit1 libcunit1-dev libegl1-mesa-dev libfontconfig1-dev libgl1-mesa-dev \
              libgtk-3-dev libgtk2.0-dev libkrb5-dev libpcap0.8 libpcap0.8-dev libtool libpam0g-dev \
              libxml2-utils libxrandr-dev libxrender-dev libxslt1-dev libxt-dev m4 nasm openssl libssl-dev \
              pkg-config python-dev python-polib python3-dev uuid-runtime xsltproc libcap2-bin python-lxml  openjdk-11-jdk libpng-dev libpng16.16 && \
    \
    apt-get build-dep -y \
            libreoffice \
            && \
    \
    ### Build and Install Poco Libraries
    mkdir -p /usr/src/poco && \
    curl -sSL https://pocoproject.org/releases/poco-${POCO_VERSION}/poco-${POCO_VERSION}-all.tar.gz | tar xvfz - --strip 1 -C /usr/src/poco && \
    cd /usr/src/poco && \
    ./configure \
                --no-samples \
                --no-tests \
                --prefix=/opt/poco \
                && \
    make install
# --- continue here


RUN set -x && \
### Build Fetch LibreOffice - This will take a while..
    git clone -b ${LIBREOFFICE_BRANCH}  ${LO_REPOSITORY}  /usr/src/libreoffice-core && \
    cd /usr/src/libreoffice-core && \
    echo "lo_sources_ver="`env | grep LIBREOFFICE_VERSION | cut -d'-' -f2` > sources.ver && \
    git reset --hard ${LIBREOFFICE_COMMIT} && \
    git submodule init && \
    git submodule update translations && \
    git submodule update dictionaries
### --- continue here


RUN set -x && \
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
# --disable-kde4 \n\
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
--with-lang=en-GB en-US de\n\
--with-linker-hash-style=both \n\
--with-system-dicts \n\
--with-system-zlib \n\
#--with-theme=galaxy \n\
#--with-system-xmlsec \n\
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
    cd /usr/src/libreoffice-core && \
    sed -i "s/export XMLSEC_TARBALL := xmlsec1-1.2.26.tar.gz/export XMLSEC_TARBALL := xmlsec1-1.2.25.tar.gz/g" download.lst && \
    chown -R lool /usr/src/libreoffice-core && \
    sudo -u lool make && \
    cd /usr/src/libreoffice-core && \
    mkdir -p /opt/libreoffice && \
    chown -R lool /opt/libreoffice && \
    sudo -u lool make install && \
    cp -R /usr/src/libreoffice-core/instdir/* /opt/libreoffice/ && \
    \
### Build LibreOffice Online (Not as long as above)
    git clone -b ${LOOL_BRANCH} https://github.com/LibreOffice/online.git /usr/src/libreoffice-online && \
    cd /usr/src/libreoffice-online && \
    git reset --hard ${LOOL_COMMIT}  && \
    apt-get install -y npm && \
    npm i npm@latest -g && \
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
                uglify-js && \
    cd /usr/src/libreoffice-online &&   \
    ./autogen.sh && \
    ./configure --enable-silent-rules \
                                    --with-lokit-path=/usr/src/libreoffice-online/bundled/include \
                                    --with-lo-path=/opt/libreoffice \
                                    --with-max-connections=${MAX_CONNECTIONS} \
                                    --with-max-documents=${MAX_DOCUMENTS} \
                                    --with-poco-includes=/opt/poco/include \
                                    --with-poco-libs=/opt/poco/lib \
                                    --with-logfile=/var/log/lool/lool.log \
                                    --prefix=/opt/lool \
                                    --sysconfdir=/etc \
                                    --disable-werror \
                                    --localstatedir=/var && \
    ( cd loleaflet/po && ../../scripts/downloadpootle.sh ) && \
    ( cd loleaflet && make l10n) || exit 1 && \
    ( scripts/locorestrings.py /usr/src/libreoffice-online /usr/src/libreoffice-core/translations ) && \
    make -j`nproc` && \
    mkdir -p /opt/lool && \
    chown -R lool /opt/lool && \
    mkdir /var/cache/loolwsd && \
    chown -R lool /var/cache/loolwsd && \
    cp -R loolwsd.xml /opt/lool/ && \
    cp -R loolkitconfig.xcu /opt/lool && \
    make install && \
    cd / && \
    setcap cap_fowner,cap_mknod,cap_sys_chroot=ep /opt/lool/bin/loolforkit && \
    apt-get autoremove -y && \
    apt-get clean && \
    ### Cleanup
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
    LOG_LEVEL=warning \
    DICTIONARIES="en_GB en_US" \
    ENABLE_SMTP=false \
    PYTHONWARNINGS=ignore

### Grab Compiled Assets from builder image
COPY --from=builder /opt/ /opt/
COPY fonts/local /usr/share/fonts/truetype/

### Install Dependencies
RUN set -x && \
    adduser --quiet --system --group --home /opt/lool lool && \
    \
### Add Repositories
    echo "deb http://deb.debian.org/debian buster contrib" >> /etc/apt/sources.list && \
    curl -sL https://deb.nodesource.com/setup_10.x | bash - && \
    \
    echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true | debconf-set-selections && \
    apt-get -o Dpkg::Options::="--force-confold" upgrade -y && \
    apt-get install -y\
             adduser \
             apt-transport-https \
             cpio \
             findutils \
             fonts-droid-fallback \
             fonts-noto-cjk \
             hunspell \
             hunspell-en-us \
             hunspell-en-gb \
	     libcap2-bin \
             libcups2 \
             libfontconfig1 \
             libfreetype6 \
             libgl1-mesa-glx \
             libpam0g \
             libpng16-16 \
             libsm6 \
             libxcb-render0 \
             libxcb-shm0 \
             libxinerama1 \
             libxrender1 \
             locales \
             locales-all \
             openssl \
             python3-polib \
             python3-requests \
             python3-websocket \
             sudo \
             ttf-mscorefonts-installer \
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
#    setcap cap_sys_admin=ep /opt/lool/bin/loolmount && \
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
    rm -rf /tmp/* && \
    mkdir -p /var/log/lool && \
    touch /var/log/lool/loolwsd.log && \
    chown -R lool /var/log/lool

### Networking Configuration
EXPOSE 9980

### Assets
ADD install /
