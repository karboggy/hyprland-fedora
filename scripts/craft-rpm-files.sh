#!/usr/bin/env bash
set -euxo pipefail

# Setup RPM (/root/rpmbuild/{SOURCES,SPECS,RPMS,SRPMS})
rpmdev-setuptree

for pkgdir in /out/packages/*; do
    name="$(basename "$pkgdir")"
    srcdir="/src/$name"

    if [ -d "$srcdir/.git" ]; then
        version="$(cd "$srcdir" && git describe --tags --long \
            | sed -E 's/^v//; s/-([0-9]+)-g/^\1.git/')"
        url="$(cd "$srcdir" && git remote get-url origin)"
    else
        version="0.0.0"
        url="UNKNOWN"
    fi

    echo "Packaging $name-$version"

    buildsrc="/tmp/${name}-${version}"
    rm -rf "$buildsrc"
    mkdir -p "$buildsrc"
    cp -a "$pkgdir/usr" "$buildsrc/"

    # Find all files under usr to list in %files
    filelist=$(find "$buildsrc/usr" \( -type f -o -type l \) | sed "s|$buildsrc||")

    tar -C /tmp -czf \
        "/root/rpmbuild/SOURCES/${name}-${version}.tar.gz" \
        "${name}-${version}"

    cat > "/root/rpmbuild/SPECS/${name}.spec" <<SPEC
%global debug_package %{nil}

Name:           ${name}
Version:        ${version}
Release:        1%{?dist}
Summary:        ${name} auto-built by karboggy

License:        UNKNOWN
URL:            ${url}
BuildArch:      x86_64

Source0:        %{name}-%{version}.tar.gz

%description
${name} package auto-built from sources on GitHub. (https://github.com/karboggy/hyprland-fedora)

%prep
%autosetup -n %{name}-%{version}

%build
# nothing

%install
mkdir -p %{buildroot}
cp -a usr %{buildroot}/

%files
$(for f in $filelist; do
    # rpmbuild will compress man pages from /usr/share/man/man1
    if [[ $f =~ ^/usr/share/man/man1/.*\.1$ ]]; then
        echo "${f}.gz"
    else
        echo "$f"
    fi
done)

%changelog
* $(date +"%a %b %d %Y") Builder <builder@local> - %{version}-1
- Automated build
SPEC

    rpmbuild -bb "/root/rpmbuild/SPECS/${name}.spec"
done

mkdir -p /out/rpms && cp -rv /root/rpmbuild/RPMS/* /out/rpms

# Change permission to host user
chown -R "$HOST_UID":"$HOST_GID" /out/rpms
