FROM fedora:29

ENV QT_MAJOR 5
ENV QT_MINOR 13
ENV QT_PATCH 0
ENV NDK_VERSION r19c
ENV ANDROID_API 28
ENV OPENSSL_VERSION 1.1.1c
ENV SDK_VERSION 4333796
ENV SPEC android-clang

RUN dnf install -q -y git wget fontconfig libX11 libX11-xcb java-1.8.0-openjdk-devel unzip make imake which findutils /usr/bin/7z \
    && dnf clean all -q && rm -rf /var/cache/dnf/*

ENV PATH "/opt/Qt/$QT_MAJOR.$QT_MINOR.$QT_PATCH/android_armv7/bin:/android-sdk-linux/tools/bin/:/qtci/bin/:/qtci/recipes/:$PATH"
ENV VERBOSE 1

ADD install-qt.sh /
RUN bash /install-qt.sh \
        --version ${QT_MAJOR}.${QT_MINOR}.${QT_PATCH} \
        --host linux_x64 \
        --target android \
        --toolchain android_arm64_v8a \
        qtbase qtdeclarative qtscript qtsvg qtimageformats qttools

RUN wget -q https://dl.google.com/android/repository/sdk-tools-linux-$SDK_VERSION.zip \
    && mkdir /android-sdk-linux && cd /android-sdk-linux \
    && unzip -q /sdk-tools-linux-$SDK_VERSION.zip && rm /sdk-tools-linux-$SDK_VERSION.zip
RUN yes | sdkmanager "platform-tools" "build-tools;28.0.2" "platforms;android-$ANDROID_API" | (grep -v = || true)
RUN wget -q https://dl.google.com/android/repository/android-ndk-${NDK_VERSION}-linux-x86_64.zip \
    && unzip -q android-ndk-${NDK_VERSION}-linux-x86_64.zip && rm android-ndk-${NDK_VERSION}-linux-x86_64.zip

ENV ANDROID_NDK_ROOT /android-ndk-$NDK_VERSION
ENV ANDROID_SDK_ROOT /android-sdk-linux

ENV QT_HOME /opt/Qt/$QT_MAJOR.$QT_MINOR.$QT_PATCH

ADD build-openssl.sh /
RUN /build-openssl.sh
