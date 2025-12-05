FROM fedora:43

# Configuration
ENV INSTALL_PREFIX=/out
ENV HYPRLAND_VERSION=v0.52.1

# Environment
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
        jemalloc-devel \
        libX11-devel \
        libXcursor-devel \
        libdisplay-info-devel \
        libdrm-devel \
        libinput-devel \
        libjpeg-turbo-devel \
        libpng-devel \
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
        pugixml-devel \
        python3 \
        qt6-qtbase-devel \
        qt6-qtbase-private-devel \
        qt6-qtdeclarative-devel \
        qt6-qtdeclarative-private-devel \
        qt6-qtsvg-devel \
        qt6-qtwayland-devel \
        qt6-qtshadertools-devel \
        re2-devel \
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
    && dnf clean all

# Build hyprwayland-scanner
RUN git clone --recursive https://github.com/hyprwm/hyprwayland-scanner.git /src/hyprwayland-scanner
WORKDIR /src/hyprwayland-scanner
RUN cmake -B build -S . ${CMAKE_COMMON_FLAGS}
RUN cmake --build build -j$(nproc)
RUN cmake --install build

# Build hyprutils
RUN git clone https://github.com/hyprwm/hyprutils.git /src/hyprutils
WORKDIR /src/hyprutils
RUN cmake -B build -S . ${CMAKE_COMMON_FLAGS}
RUN cmake --build build -j$(nproc)
RUN cmake --install build

# Build Aquamarine
RUN git clone --recursive https://github.com/hyprwm/aquamarine.git /src/aquamarine
WORKDIR /src/aquamarine
RUN git submodule update --init --recursive
RUN cmake -B build -S . ${CMAKE_COMMON_FLAGS}
RUN cmake --build build -j$(nproc)
RUN cmake --install build

# Build hyprlang
RUN git clone https://github.com/hyprwm/hyprlang.git /src/hyprlang
WORKDIR /src/hyprlang
RUN cmake -B build -S . ${CMAKE_COMMON_FLAGS}
RUN cmake --build build -j$(nproc)
RUN cmake --install build

# Build hyprcursor
RUN git clone https://github.com/hyprwm/hyprcursor.git /src/hyprcursor
WORKDIR /src/hyprcursor
RUN cmake -B build -S . ${CMAKE_COMMON_FLAGS}
RUN cmake --build build -j$(nproc)
RUN cmake --install build

# Build hyprgraphics
RUN git clone https://github.com/hyprwm/hyprgraphics.git /src/hyprgraphics
WORKDIR /src/hyprgraphics
RUN cmake -B build -S . ${CMAKE_COMMON_FLAGS}
RUN cmake --build build -j$(nproc)
RUN cmake --install build

# Build Hyprland
RUN git clone --recursive https://github.com/hyprwm/Hyprland.git /src/Hyprland
WORKDIR /src/Hyprland
RUN git fetch --tags && git checkout ${HYPRLAND_VERSION}
RUN git submodule update --init --recursive
RUN cmake -B build -G Ninja ${CMAKE_COMMON_FLAGS} -DNO_TESTS=TRUE -DBUILD_TESTING=FALSE
RUN cmake --build build -j$(nproc)
RUN cmake --install build

# Build QuickShell
RUN git clone --recursive https://github.com/quickshell-mirror/quickshell.git /src/quickshell
WORKDIR /src/quickshell
RUN cmake -B build -G Ninja ${CMAKE_COMMON_FLAGS} -DDISTRIBUTOR=karboggy -DCRASH_REPORTER=OFF
RUN cmake --build build -j$(nproc)
RUN cmake --install build