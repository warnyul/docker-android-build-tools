FROM ubuntu:xenial

LABEL maintainer="Balázs Varga <warnyul@gmail.com>"
LABEL description="Android Build Tools"

ARG ANDROID_TOOLS_VERSION=6200805
ARG ANDROID_BUILD_TOOLS_VERSION=29.0.3

# Install requirements
RUN dpkg --add-architecture i386 && \
    apt-get -y update && \
    apt-get -y install \
    openjdk-8-jre \
    unzip \
    wget && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

ENV ANDROID_SDK_FILE_NAME commandlinetools-linux-${ANDROID_TOOLS_VERSION}_latest.zip
ENV ANDROID_SDK_URL https://dl.google.com/android/repository/${ANDROID_SDK_FILE_NAME}
ENV ANDROID_HOME /opt/android-sdk-linux
ENV ANDROID_SDK ${ANDROID_HOME}
ENV ANDROID_BUILD_TOOLS ${ANDROID_HOME}/build-tools/${ANDROID_BUILD_TOOLS_VERSION}
ENV PATH ${PATH}:${ANDROID_HOME}/tools:${ANDROID_HOME}/tools/bin:${ANDROID_HOME}/platform-tools:${ANDROID_BUILD_TOOLS}

# Download the android tools and install the build tools
RUN mkdir -p ${ANDROID_HOME} && \
    cd ${ANDROID_HOME} && \
    wget -q ${ANDROID_SDK_URL} && \
    unzip ${ANDROID_SDK_FILE_NAME} && \
    rm ${ANDROID_SDK_FILE_NAME} && \
    yes | sdkmanager --sdk_root=${ANDROID_HOME} "build-tools;${ANDROID_BUILD_TOOLS_VERSION}"
