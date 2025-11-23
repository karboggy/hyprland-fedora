FROM fedora:43

RUN dnf -y update && \
    dnf -y install \
        pugixml-devel \
        hwdata-devel \
        git meson ninja-build \
        cmake gcc gcc-c++ pkgconf pkgconf-pkg-config \
        python3 glslang glslang-devel \
        vulkan-headers vulkan-loader-devel \
        wayland-devel wayland-protocols-devel \
        libxkbcommon-devel libinput-devel libseat-devel \
        pixman-devel cairo-devel pango-devel \
        libdrm-devel mesa-libgbm-devel mesa-libEGL-devel \
        xcb-util-wm-devel xcb-util-image-devel xcb-util-keysyms-devel xcb-util-renderutil-devel \
        libX11-devel libxcb-devel \
        xorg-x11-server-Xwayland-devel systemd-devel \
        libdisplay-info-devel \
    && dnf clean all



# hyprwayland-scanner
RUN git clone --recursive https://github.com/hyprwm/hyprwayland-scanner.git /src/hyprwayland-scanner
WORKDIR /src/hyprwayland-scanner
RUN cmake -B build -S . -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr
RUN cmake --build build --target all -j$(nproc)
RUN cmake --install build

# hyprutils
RUN git clone https://github.com/hyprwm/hyprutils.git /src/hyprutils && \
    cd /src/hyprutils && \
    cmake -B build -S . -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr && \
    cmake --build build -j$(nproc) && \
    cmake --install build

# ============================
# Build Aquamarine dependency
# ============================
RUN mkdir -p /src && \
    git clone --recursive https://github.com/hyprwm/aquamarine.git /src/aquamarine

WORKDIR /src/aquamarine
RUN git submodule update --init --recursive

RUN cmake --no-warn-unused-cli \
          -DCMAKE_BUILD_TYPE:STRING=Release \
          -DCMAKE_INSTALL_PREFIX:PATH=/usr \
          -S . -B ./build
RUN cmake --build ./build --config Release --target all -j$(nproc 2>/dev/null || getconf _NPROCESSORS_CONF)
RUN cmake --install ./build

# hyprlang
RUN git clone https://github.com/hyprwm/hyprlang.git /src/hyprlang && \
    cd /src/hyprlang && \
    cmake -B build -S . -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr && \
    cmake --build build -j$(nproc) && \
    cmake --install build

RUN dnf -y update && \
    dnf -y install libzip-devel librsvg2-devel tomlplusplus-devel

# hyprcursor
RUN git clone https://github.com/hyprwm/hyprcursor.git /src/hyprcursor && \
    cd /src/hyprcursor && \
    cmake -B build -S . -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr && \
    cmake --build build -j$(nproc) && \
    cmake --install build

RUN dnf -y update && \
    dnf install -y cairo-devel \
    librsvg2-devel \
    libpng-devel \
    libjpeg-turbo-devel \
    libwebp-devel \
    file-devel \
    libuuid-devel \
    libXcursor-devel \
    re2-devel \
    muParser-devel \
    libX11-devel libxcb-devel xcb-util-devel xcb-util-wm-devel xcb-util-image-devel \
    xcb-util-keysyms-devel xcb-util-renderutil-devel xcb-util-errors-devel \
    file-libs 

# hyprgraphics
RUN git clone https://github.com/hyprwm/hyprgraphics.git /src/hyprgraphics && \
    cd /src/hyprgraphics && \
    cmake -B build -S . -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr && \
    cmake --build build -j$(nproc) && \
    cmake --install build

# ============================
# Build Hyprland
# ============================
RUN mkdir -p /src && \
    git clone --recursive https://github.com/hyprwm/Hyprland.git /src/Hyprland
WORKDIR /src/Hyprland
RUN git submodule update --init --recursive
RUN cmake -B build -G Ninja -DCMAKE_BUILD_TYPE=Release
RUN cmake --build build
RUN cmake --install build

ENV XDG_RUNTIME_DIR=/tmp/runtime-root
RUN mkdir -p $XDG_RUNTIME_DIR && chmod 700 $XDG_RUNTIME_DIR

CMD ["Hyprland", "--version"]
