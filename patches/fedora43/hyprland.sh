apply_fedora43_hyprland_patches() {
    if grep -q 'std::ranges::starts_with(str_view, prefixes)' src/helpers/MiscFunctions.cpp; then
        sed -i 's/std::ranges::starts_with(str_view, prefixes)/std::ranges::equal(str_view | std::views::take(prefixes.size()), prefixes)/' src/helpers/MiscFunctions.cpp
    fi

    if [[ -f src/ipc/s1/S1.cpp ]] && grep -q 'request.subview(i, 2)' src/ipc/s1/S1.cpp; then
        sed -i 's/request.subview(i, 2)/request.substr(i, 2)/' src/ipc/s1/S1.cpp
    fi
}
