#!/bin/bash

LIBVA_REPO="https://github.com/intel/libva.git"
LIBVA_COMMIT="6e86b4fb4dafa123b1e31821f61da88f10cfbe91"

ffbuild_enabled() {
    [[ $TARGET != linux* ]] && return -1
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$LIBVA_REPO" "$LIBVA_COMMIT" libva
    cd libva

    autoreconf -i

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        --disable-shared
        --enable-static
        --with-pic
        --disable-docs
        --enable-drm
        --disable-x11
        --disable-glx
        --disable-wayland
    )

    if [[ $TARGET == linux64 ]]; then
        myconf+=(
            --host="$FFBUILD_TOOLCHAIN"
            --with-drivers-path="/usr/lib/x86_64-linux-gnu/dri"
        )
    else
        echo "Unknown target"
        return -1
    fi

    ./configure "${myconf[@]}"
    make -j$(nproc)
    make install

    echo "Libs.private: -ldl" >> "$FFBUILD_PREFIX"/lib/pkgconfig/libva.pc
}

ffbuild_configure() {
    echo --enable-vaapi
}

ffbuild_unconfigure() {
    echo --disable-vaapi
}
