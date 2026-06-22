#!/usr/bin/env bash
set -euxo pipefail

VERSION_MANIFEST="${VERSION_MANIFEST:-}"

if [[ -n "$VERSION_MANIFEST" ]]; then
    if [[ ! -f "$VERSION_MANIFEST" ]]; then
        echo "ERROR: VERSION_MANIFEST does not exist: $VERSION_MANIFEST" >&2
        exit 1
    fi

    # shellcheck disable=SC1090
    source "$VERSION_MANIFEST"
fi

checkout_ref() {
    local key="$1"
    local ref_var="REF_${key}"
    local ref="${!ref_var:-}"

    if [[ -n "$ref" ]]; then
        git fetch --tags --force
        git checkout --detach "$ref"
    fi
}

qt6_qml_install_dir() {
    local qtpaths qml_dir
    for qtpaths in qtpaths6 qtpaths-qt6 /usr/lib64/qt6/bin/qtpaths /usr/lib/qt6/bin/qtpaths; do
        if command -v "$qtpaths" >/dev/null 2>&1; then
            if qml_dir="$("$qtpaths" --query QT_INSTALL_QML 2>/dev/null)" && [[ -n "$qml_dir" ]]; then
                echo "$qml_dir"
                return
            fi
        fi
    done

    echo "${INSTALL_PREFIX}/lib64/qt6/qml"
}

QT6_QML_INSTALL_DIR="$(qt6_qml_install_dir)"

# Build glaze
git clone https://github.com/stephenberry/glaze.git /src/glaze
cd /src/glaze
checkout_ref GLAZE
cmake -B build -S . \
    ${CMAKE_COMMON_FLAGS} \
    -Dglaze_INSTALL_CMAKEDIR=/usr/share/cmake/glaze \
    -Dglaze_DISABLE_SIMD_WHEN_SUPPORTED=ON \
    -Dglaze_DEVELOPER_MODE=OFF \
    -Dglaze_ENABLE_FUZZING=OFF
cmake --build build -j$(nproc)
cmake --install build
DESTDIR=/out/packages/glaze cmake --install build

# Build hyprwayland-scanner
git clone --recursive https://github.com/hyprwm/hyprwayland-scanner.git /src/hyprwayland-scanner
cd /src/hyprwayland-scanner
checkout_ref HYPRWAYLAND_SCANNER
git submodule update --init --recursive
cmake -B build -S . ${CMAKE_COMMON_FLAGS}
cmake --build build -j$(nproc)
cmake --install build
DESTDIR=/out/packages/hyprwayland-scanner cmake --install build

# Build hyprutils
git clone https://github.com/hyprwm/hyprutils.git /src/hyprutils
cd /src/hyprutils
checkout_ref HYPRUTILS
cmake -B build -S . ${CMAKE_COMMON_FLAGS}
cmake --build build -j$(nproc)
cmake --install build
DESTDIR=/out/packages/hyprutils cmake --install build

# Build Aquamarine
git clone --recursive https://github.com/hyprwm/aquamarine.git /src/aquamarine
cd /src/aquamarine
checkout_ref AQUAMARINE
git submodule update --init --recursive
cmake -B build -S . ${CMAKE_COMMON_FLAGS}
cmake --build build -j$(nproc)
cmake --install build
DESTDIR=/out/packages/aquamarine cmake --install build

# Build hyprlang
git clone https://github.com/hyprwm/hyprlang.git /src/hyprlang
cd /src/hyprlang
checkout_ref HYPRLANG
cmake -B build -S . ${CMAKE_COMMON_FLAGS}
cmake --build build -j$(nproc)
cmake --install build
DESTDIR=/out/packages/hyprlang cmake --install build

# Build hyprcursor
git clone https://github.com/hyprwm/hyprcursor.git /src/hyprcursor
cd /src/hyprcursor
checkout_ref HYPRCURSOR
cmake -B build -S . ${CMAKE_COMMON_FLAGS}
cmake --build build -j$(nproc)
cmake --install build
DESTDIR=/out/packages/hyprcursor cmake --install build

# Build hyprgraphics
git clone https://github.com/hyprwm/hyprgraphics.git /src/hyprgraphics
cd /src/hyprgraphics
checkout_ref HYPRGRAPHICS
cmake -B build -S . ${CMAKE_COMMON_FLAGS}
cmake --build build -j$(nproc)
cmake --install build
DESTDIR=/out/packages/hyprgraphics cmake --install build

# Build hyprland-protocols
git clone https://github.com/hyprwm/hyprland-protocols.git /src/hyprland-protocols
cd /src/hyprland-protocols
checkout_ref HYPRLAND_PROTOCOLS
cmake -B build -S . ${CMAKE_COMMON_FLAGS}
cmake --build build -j$(nproc)
cmake --install build
DESTDIR=/out/packages/hyprland-protocols cmake --install build

# Build hyprwire
git clone https://github.com/hyprwm/hyprwire.git /src/hyprwire
cd /src/hyprwire
checkout_ref HYPRWIRE
cmake -B build -S . ${CMAKE_COMMON_FLAGS}
cmake --build build -j$(nproc)
cmake --install build
DESTDIR=/out/packages/hyprwire cmake --install build

# Build hyprtoolkit
git clone https://github.com/hyprwm/hyprtoolkit.git /src/hyprtoolkit
cd /src/hyprtoolkit
checkout_ref HYPRTOOLKIT
cmake -B build -S . ${CMAKE_COMMON_FLAGS}
cmake --build build -j$(nproc)
cmake --install build
DESTDIR=/out/packages/hyprtoolkit cmake --install build

# Build Hyprland
git clone --recursive https://github.com/hyprwm/Hyprland.git /src/hyprland
cd /src/hyprland
checkout_ref HYPRLAND
sed -i 's/lua55/lua/g' CMakeLists.txt
git submodule update --init --recursive
cmake -B build -G Ninja ${CMAKE_COMMON_FLAGS} -DNO_TESTS=TRUE -DBUILD_TESTING=FALSE
cmake --build build -j$(nproc)
cmake --install build
DESTDIR=/out/packages/hyprland cmake --install build
rm -rf /out/packages/hyprland/usr/share/glaze
rm -rf /out/packages/hyprland/usr/include/glaze

# Build QuickShell
git clone --recursive https://github.com/quickshell-mirror/quickshell.git /src/quickshell
cd /src/quickshell
checkout_ref QUICKSHELL
git submodule update --init --recursive
cmake -B build -G Ninja ${CMAKE_COMMON_FLAGS} -DDISTRIBUTOR=karboggy -DCRASH_HANDLER=OFF
cmake --build build -j$(nproc)
cmake --install build
DESTDIR=/out/packages/quickshell cmake --install build

# Build hypridle
git clone https://github.com/hyprwm/hypridle.git /src/hypridle
cd /src/hypridle
checkout_ref HYPRIDLE
cmake -B build -S . ${CMAKE_COMMON_FLAGS}
cmake --build build -j$(nproc)
cmake --install build
DESTDIR=/out/packages/hypridle cmake --install build

# Build hyprlock
git clone https://github.com/hyprwm/hyprlock.git /src/hyprlock
cd /src/hyprlock
checkout_ref HYPRLOCK
cmake -B build -S . ${CMAKE_COMMON_FLAGS}
cmake --build build -j$(nproc)
cmake --install build
DESTDIR=/out/packages/hyprlock cmake --install build

# Build hyprpaper
git clone https://github.com/hyprwm/hyprpaper.git /src/hyprpaper
cd /src/hyprpaper
checkout_ref HYPRPAPER
cmake -B build -S . ${CMAKE_COMMON_FLAGS}
cmake --build build -j$(nproc)
cmake --install build
DESTDIR=/out/packages/hyprpaper cmake --install build

# Build hyprpicker
git clone https://github.com/hyprwm/hyprpicker.git /src/hyprpicker
cd /src/hyprpicker
checkout_ref HYPRPICKER
cmake -B build -S . ${CMAKE_COMMON_FLAGS}
cmake --build build -j$(nproc)
cmake --install build
DESTDIR=/out/packages/hyprpicker cmake --install build

# Build hyprsunset
git clone https://github.com/hyprwm/hyprsunset.git /src/hyprsunset
cd /src/hyprsunset
checkout_ref HYPRSUNSET
cmake -B build -S . ${CMAKE_COMMON_FLAGS}
cmake --build build -j$(nproc)
cmake --install build
DESTDIR=/out/packages/hyprsunset cmake --install build

# Build hyprland-qt-support
git clone https://github.com/hyprwm/hyprland-qt-support.git /src/hyprland-qt-support
cd /src/hyprland-qt-support
checkout_ref HYPRLAND_QT_SUPPORT
cmake -B build -S . ${CMAKE_COMMON_FLAGS} -DINSTALL_QMLDIR="${QT6_QML_INSTALL_DIR}"
cmake --build build -j$(nproc)
cmake --install build
DESTDIR=/out/packages/hyprland-qt-support cmake --install build

# Build hyprpolkitagent
git clone https://github.com/hyprwm/hyprpolkitagent.git /src/hyprpolkitagent
cd /src/hyprpolkitagent
checkout_ref HYPRPOLKITAGENT
cmake -B build -S . ${CMAKE_COMMON_FLAGS}
cmake --build build -j$(nproc)
cmake --install build
DESTDIR=/out/packages/hyprpolkitagent cmake --install build

# Build hyprsysteminfo
git clone https://github.com/hyprwm/hyprsysteminfo.git /src/hyprsysteminfo
cd /src/hyprsysteminfo
checkout_ref HYPRSYSTEMINFO
cmake -B build -S . ${CMAKE_COMMON_FLAGS}
cmake --build build -j$(nproc)
cmake --install build
DESTDIR=/out/packages/hyprsysteminfo cmake --install build

# Build hyprlauncher
git clone https://github.com/hyprwm/hyprlauncher.git /src/hyprlauncher
cd /src/hyprlauncher
checkout_ref HYPRLAUNCHER
cmake -B build -S . ${CMAKE_COMMON_FLAGS}
cmake --build build -j$(nproc)
cmake --install build
DESTDIR=/out/packages/hyprlauncher cmake --install build

# Build xdg-desktop-portal-hyprland
git clone https://github.com/hyprwm/xdg-desktop-portal-hyprland.git /src/xdg-desktop-portal-hyprland
cd /src/xdg-desktop-portal-hyprland
checkout_ref XDG_DESKTOP_PORTAL_HYPRLAND
cmake -B build -S . ${CMAKE_COMMON_FLAGS}
cmake --build build -j$(nproc)
cmake --install build
DESTDIR=/out/packages/xdg-desktop-portal-hyprland cmake --install build

# Build hyprland-guiutils
git clone https://github.com/hyprwm/hyprland-guiutils.git /src/hyprland-guiutils
cd /src/hyprland-guiutils
checkout_ref HYPRLAND_GUIUTILS
cmake -B build -S . ${CMAKE_COMMON_FLAGS}
cmake --build build -j$(nproc)
cmake --install build
DESTDIR=/out/packages/hyprland-guiutils cmake --install build

# Build hyprqt6engine
git clone https://github.com/hyprwm/hyprqt6engine.git /src/hyprqt6engine
cd /src/hyprqt6engine
checkout_ref HYPRQT6ENGINE
cmake -B build -S . ${CMAKE_COMMON_FLAGS}
cmake --build build -j$(nproc)
cmake --install build
DESTDIR=/out/packages/hyprqt6engine cmake --install build

# Build uwsm
git clone https://github.com/Vladimir-csp/uwsm.git /src/uwsm
cd /src/uwsm
checkout_ref UWSM
meson setup build -Duuctl=enabled -Dfumon=enabled -Duwsm-app=enabled
meson compile -C build -j$(nproc)
meson install -C build
DESTDIR=/out/packages/uwsm meson install -C build

# Hyprshot
git clone https://github.com/Gustash/Hyprshot.git /src/hyprshot
cd /src/hyprshot
checkout_ref HYPRSHOT
mkdir -p /out/packages/hyprshot/usr/bin
install -Dpm0755 hyprshot -t /out/packages/hyprshot/usr/bin

# Change permission to host user
chown -R "$HOST_UID":"$HOST_GID" /out/packages
