#!/bin/bash
set -xe

# Based on http://doc.qt.io/archives/qt-5.10/opensslsupport.html and 
# https://wiki.openssl.org/index.php/Android

OPENSSL_VERSION="1.0.2p"
wget -q -O openssl-$OPENSSL_VERSION.tar.gz https://www.openssl.org/source/openssl-$OPENSSL_VERSION.tar.gz

export ANDROID_NDK="$ANDROID_NDK_ROOT"
export HOSTCC="gcc"
export SYSTEM=android
export RELEASE="2.6.37"

function build {
    export MACHINE="$1"
    export ARCH="$2"
    TOOLCHAIN="$3"
    COMPILER_PREFIX="$4"

    export NDK_SYSROOT="$ANDROID_NDK_ROOT/platforms/$ANDROID_API/arch-$ARCH"
    export CROSS_COMPILE="$COMPILER_PREFIX-"
    export CROSS_SYSROOT="$ANDROID_NDK_ROOT/platforms/$ANDROID_API/arch-$ARCH"
    export ANDROID_DEV="$ANDROID_NDK_ROOT/platforms/$ANDROID_API/arch-$ARCH/usr"
    export ANDROID_NDK_SYSROOT="$ANDROID_NDK_ROOT/platforms/$ANDROID_API/arch-$ARCH"
    export ANDROID_SYSROOT="$ANDROID_NDK_ROOT/platforms/$ANDROID_API/arch-$ARCH"
    export ANDROID_TOOLCHAIN="$ANDROID_NDK_ROOT/toolchains/$TOOLCHAIN/prebuilt/linux-x86_64/bin"
    export PATH="$ANDROID_TOOLCHAIN":"$PATH"
    export SYSROOT="$ANDROID_SYSROOT"

    tar xf openssl-$OPENSSL_VERSION.tar.gz
    pushd openssl-$OPENSSL_VERSION
    ./config shared
    make depend -j$(nproc)
    make all -j$(nproc)

    popd

    mkdir -p libs/$ARCH/
    cp openssl-$OPENSSL_VERSION/lib{ssl,crypto}.so libs/$ARCH/
    rm -r openssl-$OPENSSL_VERSION/
}

rm -rf libs/

build "armv7" "arm" "arm-linux-androideabi-4.9" "arm-linux-androideabi"
build "i686" "x86" "x86-4.9" "i686-linux-android"

rm openssl-$OPENSSL_VERSION.tar.gz