FROM fedora:29

ENV QT_MAJOR 5
ENV QT_MINOR 11
ENV QT_PATCH 2
ENV NDK_VERSION r15c
ENV ANDROID_API android-19
ENV OPENSSL_VERSION 1.0.2p
ENV SDK_VERSION 4333796

ENV QT_CI_PACKAGES qt.qt$QT_MAJOR.${QT_MAJOR}${QT_MINOR}${QT_PATCH}.android_armv7

RUN dnf install -y git wget fontconfig libX11 libX11-xcb java-1.8.0-openjdk-devel unzip make which \
    && dnf clean all && rm -rf /var/cache/dnf/*

# https://github.com/benlau/qtci/pull/13
RUN git clone https://github.com/mrgreywater/qtci.git \
    && cd qtci && git checkout cb95275fdab475e46c32a7fe9a1a60897c0229d9

ENV PATH "/opt/Qt/$QT_MAJOR.$QT_MINOR.$QT_PATCH/android_armv7/bin:/android-sdk-linux/tools/bin/:/qtci/bin/:/qtci/recipes/:$PATH"
ENV VERBOSE 1
ENV INSTALLER_FILE qt-opensource-linux-x64-$QT_MAJOR.$QT_MINOR.$QT_PATCH.run
RUN wget -q https://download.qt.io/archive/qt/$QT_MAJOR.$QT_MINOR/$QT_MAJOR.$QT_MINOR.$QT_PATCH/$INSTALLER_FILE \
    && extract-qt-installer --disable-progress-report $INSTALLER_FILE /opt/Qt \
    && rm $INSTALLER_FILE
RUN wget -q https://dl.google.com/android/repository/sdk-tools-linux-$SDK_VERSION.zip \
    && mkdir /android-sdk-linux && cd /android-sdk-linux \
    && unzip -q /sdk-tools-linux-$SDK_VERSION.zip && rm /sdk-tools-linux-$SDK_VERSION.zip
RUN yes | sdkmanager "platform-tools" "build-tools;28.0.2" "platforms;$ANDROID_API" | (grep -v = || true)
RUN wget -q https://dl.google.com/android/repository/android-ndk-${NDK_VERSION}-linux-x86_64.zip \
    && unzip -q android-ndk-${NDK_VERSION}-linux-x86_64.zip && rm android-ndk-${NDK_VERSION}-linux-x86_64.zip

ENV ANDROID_NDK_ROOT /android-ndk-$NDK_VERSION
ENV ANDROID_SDK_ROOT /android-sdk-linux

ENV QT_HOME /opt/Qt/$QT_MAJOR.$QT_MINOR.$QT_PATCH

ADD build-openssh.sh /
RUN /build-openssh.sh