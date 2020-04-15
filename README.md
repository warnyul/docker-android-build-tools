# docker-android-build-tools

![build](https://github.com/warnyul/docker-android-build-tools/workflows/build/badge.svg) ![Docker Image Version (tag latest semver)](https://img.shields.io/docker/v/warnyul/android-build-tools/latest) ![Docker Image Size (tag)](https://img.shields.io/docker/image-size/warnyul/android-build-tools/latest) [![License](https://img.shields.io/badge/License-Apache%202.0-green.svg)](LICENSE)

This is an Ubuntu Xential based Docker image and is image only contains Open JDK 8 JRE, Android SDK Tools and Android SDK Build Tools.

## Usage

You can use all commands from [Android SDK Tools or Android SDK Build Tools](https://developer.android.com/studio/command-line). You can mount a volume optionally, if you would like to pass files to commands.

```
docker run --rm -v "$(pwd)":"$(pwd)" warnyul/android-build-tools apkanalyzer
```

Or if you want to use platform tools or other Android SDK components, just use this image as parent:

```
FROM warnyul/android-build-tools:{VERSION or latest}

# Install platform tools
RUN yes | sdkmanager "platforms;android-29"

```

## Build

```
git clone https://github.com/warnyul/docker-android-build-tools.git
cd docker-android-build-tools
./build.sh --build-tools-version=29.0.3 --latest
```

## Why Ubuntu Xential?

I use this image to build [redex](https://fbredex.com) in a Docker container. [The documentation of redex](https://fbredex.com/docs/installation) refers to this.

## License

    Copyright 2020 Balázs Varga

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
