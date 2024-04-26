FROM base-image

LABEL maintainer="Balázs Varga <warnyul@gmail.com>"
LABEL description="Android Build Tools"

ARG ANDROID_COMMAND_LINE_TOOLS_VERSION=11076708
ARG ANDROID_PLATFORM_VERSION=34
ARG ANDROID_BUILD_TOOLS_VERSION=34.0.0

ENV ANDROID_SDK_FILE_NAME commandlinetools-linux-${ANDROID_COMMAND_LINE_TOOLS_VERSION}_latest.zip
ENV ANDROID_SDK_URL https://dl.google.com/android/repository/${ANDROID_SDK_FILE_NAME}
ENV ANDROID_HOME /opt/android-sdk-linux
ENV ANDROID_SDK ${ANDROID_HOME}
ENV ANDROID_BUILD_TOOLS ${ANDROID_HOME}/build-tools/${ANDROID_BUILD_TOOLS_VERSION}
ENV PATH ${PATH}:${ANDROID_HOME}/tools:${ANDROID_HOME}/platform-tools:${ANDROID_BUILD_TOOLS}:${ANDROID_HOME}/cmdline-tools/latest/bin:${ANDROID_HOME}/tools/bin:${ANDROID_HOME}/tools/proguard/bin

# Install requirements
RUN dpkg --add-architecture i386 && \
    apt-get update -q && \
    apt-get -q --no-install-recommends -y install openjdk-17-jdk-headless wget unzip

# Download Android SDK
RUN mkdir -p ${ANDROID_HOME} && \
    cd ${ANDROID_HOME} && \
    wget -q ${ANDROID_SDK_URL} && \
    unzip ${ANDROID_SDK_FILE_NAME} && \
    rm ${ANDROID_SDK_FILE_NAME}

# Fix cmdline-tools location
# https://stackoverflow.com/questions/60925741/cant-execute-apkanalyzer
# https://stackoverflow.com/questions/65262340/cmdline-tools-could-not-determine-sdk-root
RUN mkdir -p ${ANDROID_HOME}/latest && \
    mv ${ANDROID_HOME}/cmdline-tools/* ${ANDROID_HOME}/latest && \
    mv ${ANDROID_HOME}/latest ${ANDROID_HOME}/cmdline-tools

# Remove all packages from sdk manager
RUN yes | sdkmanager --licenses --sdk_root="${ANDROID_HOME}" && \
    for package in $(sdkmanager --list_installed --sdk_root="${ANDROID_HOME}" | cut -d'|' -f1 | tail -n +5 | head -n -1 | tr -d ' '); do \
        sdkmanager --uninstall --sdk_root="${ANDROID_HOME}" "$package"; \
    done

# Install Android SDK
RUN sdkmanager --sdk_root="${ANDROID_HOME}" "tools" "platforms;android-${ANDROID_PLATFORM_VERSION}" "build-tools;${ANDROID_BUILD_TOOLS_VERSION}" && \
    # Remove emulator
    sdkmanager --uninstall --sdk_root="${ANDROID_HOME}" emulator

# Clean
RUN apt-get -y remove wget unzip && \
    apt-get -y autoremove && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    unset ANDROID_SDK_FILE_NAME && \
    unset ANDROID_SDK_URL
