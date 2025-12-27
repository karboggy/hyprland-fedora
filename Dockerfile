FROM fedora:43

# Environment
ENV INSTALL_PREFIX=/usr
ENV PATH="${INSTALL_PREFIX}/bin:${PATH}"
ENV CMAKE_COMMON_FLAGS="-DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX}"
ENV CMAKE_PREFIX_PATH="${INSTALL_PREFIX}:${INSTALL_PREFIX}/lib64/cmake:${INSTALL_PREFIX}/lib/cmake"
ENV PKG_CONFIG_PATH="${INSTALL_PREFIX}/lib/pkgconfig:${INSTALL_PREFIX}/lib64/pkgconfig"

# Install dependencies
RUN dnf -y update && \
    dnf -y install \
        cairo-devel \
        cli11-devel \
        cmake \
        file-devel \
        file-libs \
        gcc \
        gcc-c++ \
        git \
        glib2-devel \
        glslang \
        glslang-devel \
        hwdata-devel \
        iniparser-devel \
        jemalloc-devel \
        libX11-devel \
        libXcursor-devel \
        libdisplay-info-devel \
        libdrm-devel \
        libinput-devel \
        libjpeg-turbo-devel \
        libpng-devel \
        libqalculate-devel \
        librsvg2-devel \
        libseat-devel \
        libuuid-devel \
        libwebp-devel \
        libxcb-devel \
        libxkbcommon-devel \
        libzip-devel \
        mesa-libEGL-devel \
        mesa-libgbm-devel \
        meson \
        muParser-devel \
        ninja \
        ninja-build \
        pam-devel \
        pango-devel \
        pipewire-devel \
        pixman-devel \
        pkg-config \
        pkgconf \
        pkgconf-pkg-config \
        polkit-devel \
        polkit-qt6-1-devel \
        pugixml-devel \
        python3 \
        qt6-qtbase-devel \
        qt6-qtbase-private-devel \
        qt6-qtdeclarative-devel \
        qt6-qtdeclarative-private-devel \
        qt6-qtsvg-devel \
        qt6-qtshadertools-devel \
        qt6-qtwayland-devel \
        re2-devel \
        sdbus-cpp \
        sdbus-cpp-devel \
        spirv-tools \
        spirv-tools-devel \
        systemd-devel \
        tomlplusplus-devel \
        vulkan-headers \
        vulkan-loader-devel \
        wayland-devel \
        wayland-protocols-devel \
        which \
        xcb-util-devel \
        xcb-util-errors-devel \
        xcb-util-image-devel \
        xcb-util-keysyms-devel \
        xcb-util-renderutil-devel \
        xcb-util-wm-devel \
        xorg-x11-server-Xwayland-devel \
        rpm-build \
        rpmdevtools \
        tar \
        gzip \
        python3-dbus \
        dbus-devel \
        python3-pyxdg \
        util-linux \
        desktop-file-utils \
        scdoc \
    && dnf clean all

COPY scripts/ /root/
RUN find /root -name "*.sh" -exec chmod +x {} +

RUN /root/build.sh
RUN /root/craft-rpm-files.sh