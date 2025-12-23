FROM fedora:43

# Configuration
ENV INSTALL_PREFIX=/usr
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
    && dnf clean all

# Build hyprwayland-scanner
RUN git clone --recursive https://github.com/hyprwm/hyprwayland-scanner.git /src/hyprwayland-scanner
WORKDIR /src/hyprwayland-scanner
RUN cmake -B build -S . ${CMAKE_COMMON_FLAGS}
RUN cmake --build build -j$(nproc)
RUN cmake --install build
RUN DESTDIR=/out/packages/hyprwayland-scanner cmake --install build

# Build hyprutils
RUN git clone https://github.com/hyprwm/hyprutils.git /src/hyprutils
WORKDIR /src/hyprutils
RUN cmake -B build -S . ${CMAKE_COMMON_FLAGS}
RUN cmake --build build -j$(nproc)
RUN cmake --install build
RUN DESTDIR=/out/packages/hyprutils cmake --install build

# Build Aquamarine
RUN git clone --recursive https://github.com/hyprwm/aquamarine.git /src/aquamarine
WORKDIR /src/aquamarine
RUN git submodule update --init --recursive
RUN cmake -B build -S . ${CMAKE_COMMON_FLAGS}
RUN cmake --build build -j$(nproc)
RUN cmake --install build
RUN DESTDIR=/out/packages/aquamarine cmake --install build

# Build hyprlang
RUN git clone https://github.com/hyprwm/hyprlang.git /src/hyprlang
WORKDIR /src/hyprlang
RUN cmake -B build -S . ${CMAKE_COMMON_FLAGS}
RUN cmake --build build -j$(nproc)
RUN cmake --install build
RUN DESTDIR=/out/packages/hyprlang cmake --install build

# Build hyprcursor
RUN git clone https://github.com/hyprwm/hyprcursor.git /src/hyprcursor
WORKDIR /src/hyprcursor
RUN cmake -B build -S . ${CMAKE_COMMON_FLAGS}
RUN cmake --build build -j$(nproc)
RUN cmake --install build
RUN DESTDIR=/out/packages/hyprcursor cmake --install build

# Build hyprgraphics
RUN git clone https://github.com/hyprwm/hyprgraphics.git /src/hyprgraphics
WORKDIR /src/hyprgraphics
RUN cmake -B build -S . ${CMAKE_COMMON_FLAGS}
RUN cmake --build build -j$(nproc)
RUN cmake --install build
RUN DESTDIR=/out/packages/hyprgraphics cmake --install build

# Build Hyprland
RUN git clone --recursive https://github.com/hyprwm/Hyprland.git /src/hyprland
WORKDIR /src/hyprland
RUN git fetch --tags && git checkout ${HYPRLAND_VERSION}
RUN git submodule update --init --recursive
RUN cmake -B build -G Ninja ${CMAKE_COMMON_FLAGS} -DNO_TESTS=TRUE -DBUILD_TESTING=FALSE
RUN cmake --build build -j$(nproc)
RUN cmake --install build
RUN DESTDIR=/out/packages/hyprland cmake --install build

# Build QuickShell
RUN git clone --recursive https://github.com/quickshell-mirror/quickshell.git /src/quickshell
WORKDIR /src/quickshell
RUN cmake -B build -G Ninja ${CMAKE_COMMON_FLAGS} -DDISTRIBUTOR=karboggy -DCRASH_REPORTER=OFF
RUN cmake --build build -j$(nproc)
RUN cmake --install build
RUN DESTDIR=/out/packages/quickshell cmake --install build

# Build hyprland-protocols
RUN git clone https://github.com/hyprwm/hyprland-protocols.git /src/hyprland-protocols
WORKDIR /src/hyprland-protocols
RUN cmake -B build -S . ${CMAKE_COMMON_FLAGS}
RUN cmake --build build -j$(nproc)
RUN cmake --install build
RUN DESTDIR=/out/packages/hyprland-protocols cmake --install build

# Build hyprwire
RUN git clone https://github.com/hyprwm/hyprwire.git /src/hyprwire
WORKDIR /src/hyprwire
RUN cmake -B build -S . ${CMAKE_COMMON_FLAGS}
RUN cmake --build build -j$(nproc)
RUN cmake --install build
RUN DESTDIR=/out/packages/hyprwire cmake --install build

# Build hyprtoolkit
RUN git clone https://github.com/hyprwm/hyprtoolkit.git /src/hyprtoolkit
WORKDIR /src/hyprtoolkit
RUN cmake -B build -S . ${CMAKE_COMMON_FLAGS}
RUN cmake --build build -j$(nproc)
RUN cmake --install build
RUN DESTDIR=/out/packages/hyprtoolkit cmake --install build


# Build hypridle
RUN git clone https://github.com/hyprwm/hypridle.git /src/hypridle
WORKDIR /src/hypridle
RUN cmake -B build -S . ${CMAKE_COMMON_FLAGS}
RUN cmake --build build -j$(nproc)
RUN cmake --install build
RUN DESTDIR=/out/packages/hypridle cmake --install build

# Build hyprlock
RUN git clone https://github.com/hyprwm/hyprlock.git /src/hyprlock
WORKDIR /src/hyprlock
RUN cmake -B build -S . ${CMAKE_COMMON_FLAGS}
RUN cmake --build build -j$(nproc)
RUN cmake --install build
RUN DESTDIR=/out/packages/hyprlock cmake --install build

# Build hyprpaper
RUN git clone https://github.com/hyprwm/hyprpaper.git /src/hyprpaper
WORKDIR /src/hyprpaper
RUN cmake -B build -S . ${CMAKE_COMMON_FLAGS}
RUN cmake --build build -j$(nproc)
RUN cmake --install build
RUN DESTDIR=/out/packages/hyprpaper cmake --install build

# Build hyprpicker
RUN git clone https://github.com/hyprwm/hyprpicker.git /src/hyprpicker
WORKDIR /src/hyprpicker
RUN cmake -B build -S . ${CMAKE_COMMON_FLAGS}
RUN cmake --build build -j$(nproc)
RUN cmake --install build
RUN DESTDIR=/out/packages/hyprpicker cmake --install build

# Build hyprsunset
RUN git clone https://github.com/hyprwm/hyprsunset.git /src/hyprsunset
WORKDIR /src/hyprsunset
RUN cmake -B build -S . ${CMAKE_COMMON_FLAGS}
RUN cmake --build build -j$(nproc)
RUN cmake --install build
RUN DESTDIR=/out/packages/hyprsunset cmake --install build

# Build hyprpolkitagent
RUN git clone https://github.com/hyprwm/hyprpolkitagent.git /src/hyprpolkitagent
WORKDIR /src/hyprpolkitagent
RUN cmake -B build -S . ${CMAKE_COMMON_FLAGS}
RUN cmake --build build -j$(nproc)
RUN cmake --install build
RUN DESTDIR=/out/packages/hyprpolkitagent cmake --install build

# Build hyprsysteminfo
RUN git clone https://github.com/hyprwm/hyprsysteminfo.git /src/hyprsysteminfo
WORKDIR /src/hyprsysteminfo
RUN cmake -B build -S . ${CMAKE_COMMON_FLAGS}
RUN cmake --build build -j$(nproc)
RUN cmake --install build
RUN DESTDIR=/out/packages/hyprsysteminfo cmake --install build

# Build hyprlauncher
RUN git clone https://github.com/hyprwm/hyprlauncher.git /src/hyprlauncher
WORKDIR /src/hyprlauncher
RUN cmake -B build -S . ${CMAKE_COMMON_FLAGS}
RUN cmake --build build -j$(nproc)
RUN cmake --install build
RUN DESTDIR=/out/packages/hyprlauncher cmake --install build

# Build xdg-desktop-portal-hyprland
RUN git clone https://github.com/hyprwm/xdg-desktop-portal-hyprland.git /src/xdg-desktop-portal-hyprland
WORKDIR /src/xdg-desktop-portal-hyprland
RUN cmake -B build -S . ${CMAKE_COMMON_FLAGS}
RUN cmake --build build -j$(nproc)
RUN cmake --install build
RUN DESTDIR=/out/packages/xdg-desktop-portal-hyprland cmake --install build