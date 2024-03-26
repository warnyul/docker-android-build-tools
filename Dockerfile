FROM ubuntu:bionic

LABEL maintainer="Balázs Varga <warnyul@gmail.com>"
LABEL description="Android Build Tools"

ARG ANDROID_COMMAND_LINE_TOOLS=11076708
ARG ANDROID_PLATFORM_VERSION=34
ARG ANDROID_BUILD_TOOLS_VERSION=34.0.0

ENV ANDROID_SDK_FILE_NAME commandlinetools-linux-${ANDROID_COMMAND_LINE_TOOLS}_latest.zip
ENV ANDROID_SDK_URL https://dl.google.com/android/repository/${ANDROID_SDK_FILE_NAME}
ENV ANDROID_HOME /opt/android-sdk-linux
ENV ANDROID_SDK ${ANDROID_HOME}
ENV ANDROID_BUILD_TOOLS ${ANDROID_HOME}/build-tools/${ANDROID_BUILD_TOOLS_VERSION}
ENV PATH ${PATH}:${ANDROID_HOME}/tools:${ANDROID_HOME}/platform-tools:${ANDROID_BUILD_TOOLS}:${ANDROID_HOME}/cmdline-tools/bin

# Install requirements
RUN dpkg --add-architecture i386 && \
    apt-get -y update && \
    apt-get -y install openjdk-17-jre wget unzip

# Download Android SDK
RUN mkdir -p ${ANDROID_HOME} && \
    cd ${ANDROID_HOME} && \
    wget -q ${ANDROID_SDK_URL} && \
    unzip ${ANDROID_SDK_FILE_NAME} && \
    rm ${ANDROID_SDK_FILE_NAME}
    
# Install Android SDK
RUN yes | sdkmanager --sdk_root=${ANDROID_HOME} "tools" "platforms;android-${ANDROID_PLATFORM_VERSION}" "build-tools;${ANDROID_BUILD_TOOLS_VERSION}"

# Clean
RUN apt-get -y remove wget unzip && \
    apt-get -y autoremove && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
