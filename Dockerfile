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
        cmake \
        file-devel \
        file-libs \
        gcc \
        gcc-c++ \
        git \
        glslang \
        glslang-devel \
        hwdata-devel \
        libX11-devel \
        libXcursor-devel \
        libdrm-devel \
        libdisplay-info-devel \
        libinput-devel \
        libjpeg-turbo-devel \
        libpng-devel \
        librsvg2-devel \
        libseat-devel \
        libuuid-devel \
        libwebp-devel \
        libxkbcommon-devel \
        libzip-devel \
        mesa-libEGL-devel \
        mesa-libgbm-devel \
        meson \
        muParser-devel \
        ninja-build \
        pango-devel \
        pixman-devel \
        pkgconf \
        pkgconf-pkg-config \
        pugixml-devel \
        python3 \
        re2-devel \
        systemd-devel \
        tomlplusplus-devel \
        vulkan-headers \
        vulkan-loader-devel \
        wayland-devel \
        wayland-protocols-devel \
        xcb-util-devel \
        xcb-util-errors-devel \
        xcb-util-image-devel \
        xcb-util-keysyms-devel \
        xcb-util-renderutil-devel \
        xcb-util-wm-devel \
        libxcb-devel \
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
