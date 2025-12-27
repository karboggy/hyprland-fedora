#!/usr/bin/env bash
set -euxo pipefail

# HYPRLAND_VERSION=v0.52.1

# Build hyprwayland-scanner
git clone --recursive https://github.com/hyprwm/hyprwayland-scanner.git /src/hyprwayland-scanner
cd /src/hyprwayland-scanner
cmake -B build -S . ${CMAKE_COMMON_FLAGS}
cmake --build build -j$(nproc)
cmake --install build
DESTDIR=/out/packages/hyprwayland-scanner cmake --install build

# Build hyprutils
git clone https://github.com/hyprwm/hyprutils.git /src/hyprutils
cd /src/hyprutils
cmake -B build -S . ${CMAKE_COMMON_FLAGS}
cmake --build build -j$(nproc)
cmake --install build
DESTDIR=/out/packages/hyprutils cmake --install build

# Build Aquamarine
git clone --recursive https://github.com/hyprwm/aquamarine.git /src/aquamarine
cd /src/aquamarine
git submodule update --init --recursive
cmake -B build -S . ${CMAKE_COMMON_FLAGS}
cmake --build build -j$(nproc)
cmake --install build
DESTDIR=/out/packages/aquamarine cmake --install build

# Build hyprlang
git clone https://github.com/hyprwm/hyprlang.git /src/hyprlang
cd /src/hyprlang
cmake -B build -S . ${CMAKE_COMMON_FLAGS}
cmake --build build -j$(nproc)
cmake --install build
DESTDIR=/out/packages/hyprlang cmake --install build

# Build hyprcursor
git clone https://github.com/hyprwm/hyprcursor.git /src/hyprcursor
cd /src/hyprcursor
cmake -B build -S . ${CMAKE_COMMON_FLAGS}
cmake --build build -j$(nproc)
cmake --install build
DESTDIR=/out/packages/hyprcursor cmake --install build

# Build hyprgraphics
git clone https://github.com/hyprwm/hyprgraphics.git /src/hyprgraphics
cd /src/hyprgraphics
cmake -B build -S . ${CMAKE_COMMON_FLAGS}
cmake --build build -j$(nproc)
cmake --install build
DESTDIR=/out/packages/hyprgraphics cmake --install build

# Build hyprland-protocols
git clone https://github.com/hyprwm/hyprland-protocols.git /src/hyprland-protocols
cd /src/hyprland-protocols
cmake -B build -S . ${CMAKE_COMMON_FLAGS}
cmake --build build -j$(nproc)
cmake --install build
DESTDIR=/out/packages/hyprland-protocols cmake --install build

# Build hyprwire
git clone https://github.com/hyprwm/hyprwire.git /src/hyprwire
cd /src/hyprwire
cmake -B build -S . ${CMAKE_COMMON_FLAGS}
cmake --build build -j$(nproc)
cmake --install build
DESTDIR=/out/packages/hyprwire cmake --install build

# Build hyprtoolkit
git clone https://github.com/hyprwm/hyprtoolkit.git /src/hyprtoolkit
cd /src/hyprtoolkit
cmake -B build -S . ${CMAKE_COMMON_FLAGS}
cmake --build build -j$(nproc)
cmake --install build
DESTDIR=/out/packages/hyprtoolkit cmake --install build

# Build Hyprland
git clone --recursive https://github.com/hyprwm/Hyprland.git /src/hyprland
cd /src/hyprland
# git fetch --tags && git checkout ${HYPRLAND_VERSION}
git submodule update --init --recursive
cmake -B build -G Ninja ${CMAKE_COMMON_FLAGS} -DNO_TESTS=TRUE -DBUILD_TESTING=FALSE
cmake --build build -j$(nproc)
cmake --install build
DESTDIR=/out/packages/hyprland cmake --install build

# Build QuickShell
git clone --recursive https://github.com/quickshell-mirror/quickshell.git /src/quickshell
cd /src/quickshell
cmake -B build -G Ninja ${CMAKE_COMMON_FLAGS} -DDISTRIBUTOR=karboggy -DCRASH_REPORTER=OFF
cmake --build build -j$(nproc)
cmake --install build
DESTDIR=/out/packages/quickshell cmake --install build

# Build hypridle
git clone https://github.com/hyprwm/hypridle.git /src/hypridle
cd /src/hypridle
cmake -B build -S . ${CMAKE_COMMON_FLAGS}
cmake --build build -j$(nproc)
cmake --install build
DESTDIR=/out/packages/hypridle cmake --install build

# Build hyprlock
git clone https://github.com/hyprwm/hyprlock.git /src/hyprlock
cd /src/hyprlock
cmake -B build -S . ${CMAKE_COMMON_FLAGS}
cmake --build build -j$(nproc)
cmake --install build
DESTDIR=/out/packages/hyprlock cmake --install build

# Build hyprpaper
git clone https://github.com/hyprwm/hyprpaper.git /src/hyprpaper
cd /src/hyprpaper
cmake -B build -S . ${CMAKE_COMMON_FLAGS}
cmake --build build -j$(nproc)
cmake --install build
DESTDIR=/out/packages/hyprpaper cmake --install build

# Build hyprpicker
git clone https://github.com/hyprwm/hyprpicker.git /src/hyprpicker
cd /src/hyprpicker
cmake -B build -S . ${CMAKE_COMMON_FLAGS}
cmake --build build -j$(nproc)
cmake --install build
DESTDIR=/out/packages/hyprpicker cmake --install build

# Build hyprsunset
git clone https://github.com/hyprwm/hyprsunset.git /src/hyprsunset
cd /src/hyprsunset
cmake -B build -S . ${CMAKE_COMMON_FLAGS}
cmake --build build -j$(nproc)
cmake --install build
DESTDIR=/out/packages/hyprsunset cmake --install build

# Build hyprpolkitagent
git clone https://github.com/hyprwm/hyprpolkitagent.git /src/hyprpolkitagent
cd /src/hyprpolkitagent
cmake -B build -S . ${CMAKE_COMMON_FLAGS}
cmake --build build -j$(nproc)
cmake --install build
DESTDIR=/out/packages/hyprpolkitagent cmake --install build

# Build hyprsysteminfo
git clone https://github.com/hyprwm/hyprsysteminfo.git /src/hyprsysteminfo
cd /src/hyprsysteminfo
cmake -B build -S . ${CMAKE_COMMON_FLAGS}
cmake --build build -j$(nproc)
cmake --install build
DESTDIR=/out/packages/hyprsysteminfo cmake --install build

# Build hyprlauncher
git clone https://github.com/hyprwm/hyprlauncher.git /src/hyprlauncher
cd /src/hyprlauncher
cmake -B build -S . ${CMAKE_COMMON_FLAGS}
cmake --build build -j$(nproc)
cmake --install build
DESTDIR=/out/packages/hyprlauncher cmake --install build

# Build xdg-desktop-portal-hyprland
git clone https://github.com/hyprwm/xdg-desktop-portal-hyprland.git /src/xdg-desktop-portal-hyprland
cd /src/xdg-desktop-portal-hyprland
cmake -B build -S . ${CMAKE_COMMON_FLAGS}
cmake --build build -j$(nproc)
cmake --install build
DESTDIR=/out/packages/xdg-desktop-portal-hyprland cmake --install build

# Build hyprland-guiutils
git clone https://github.com/hyprwm/hyprland-guiutils.git /src/hyprland-guiutils
cd /src/hyprland-guiutils
cmake -B build -S . ${CMAKE_COMMON_FLAGS}
cmake --build build -j$(nproc)
cmake --install build
DESTDIR=/out/packages/hyprland-guiutils cmake --install build

# Build hyprland-qt-support
git clone https://github.com/hyprwm/hyprland-qt-support.git /src/hyprland-qt-support
cd /src/hyprland-qt-support
cmake -B build -S . ${CMAKE_COMMON_FLAGS}
cmake --build build -j$(nproc)
cmake --install build
DESTDIR=/out/packages/hyprland-qt-support cmake --install build

# Build hyprqt6engine
git clone https://github.com/hyprwm/hyprqt6engine.git /src/hyprqt6engine
cd /src/hyprqt6engine
cmake -B build -S . ${CMAKE_COMMON_FLAGS}
cmake --build build -j$(nproc)
cmake --install build
DESTDIR=/out/packages/hyprqt6engine cmake --install build

# Build uwsm
git clone https://github.com/Vladimir-csp/uwsm.git /src/uwsm
cd /src/uwsm
meson setup build -Duuctl=enabled -Dfumon=enabled -Duwsm-app=enabled
meson compile -C build -j$(nproc)
meson install -C build
DESTDIR=/out/packages/uwsm meson install -C build

# Hyprshot
git clone https://github.com/Gustash/Hyprshot.git /src/hyprshot
cd /src/hyprshot
mkdir -p /out/packages/hyprshot/usr/bin
install -Dpm0755 hyprshot -t /out/packages/hyprshot/usr/bin
