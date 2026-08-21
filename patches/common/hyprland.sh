apply_common_hyprland_patches() {
    sed -i 's/lua55/lua/g' CMakeLists.txt
}
