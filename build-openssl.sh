#!/bin/bash
set -xe

# Based on http://doc.qt.io/archives/qt-5.10/opensslsupport.html and 
# https://wiki.openssl.org/index.php/Android

wget -q -O openssl-$OPENSSL_VERSION.tar.gz https://www.openssl.org/source/openssl-$OPENSSL_VERSION.tar.gz

export ANDROID_NDK="$ANDROID_NDK_ROOT"

function build {
    export MACHINE="$1"
    export ARCH="$2"
    COMPILER_PREFIX="$3"
    LIBS_FOLDER_NAME="$4"

    export ANDROID_DEV="$ANDROID_NDK_ROOT/platforms/$ANDROID_API/arch-$ARCH/usr"
    export ANDROID_TOOLCHAIN="$ANDROID_NDK_ROOT/toolchains/llvm/prebuilt/linux-x86_64/bin"
    export PATH="$ANDROID_TOOLCHAIN":"$PATH"

    tar xf openssl-$OPENSSL_VERSION.tar.gz
    pushd openssl-$OPENSSL_VERSION
    CC=$COMPILER_PREFIX$ANDROID_API-clang ./config shared
    make CALC_VERSIONS="SHLIB_COMPAT=; SHLIB_SOVER=" build_libs -j$(nproc)

    popd

    mkdir -p libs/$LIBS_FOLDER_NAME/
    cp openssl-$OPENSSL_VERSION/lib{ssl,crypto}.so libs/$LIBS_FOLDER_NAME/
    rm -r openssl-$OPENSSL_VERSION/
}

rm -rf libs/

build "android-x86_64" "x86_64" "x86_64-linux-android" "x86_64"
build "android-i686" "x86" "i686-linux-android" "x86"
build "aarch64" "arm" "aarch64-linux-android" "arm64-v8a"
build "armv7" "arm" "armv7a-linux-androideabi" "armeabi-v7a"


rm openssl-$OPENSSL_VERSION.tar.gz
