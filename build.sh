#!/usr/bin/env bash

set +e

read -r -d '' USAGE <<- EOM
    \n
    Usage: ./build.sh [OPTIONS]\n
    \n
    Options:\n
    --build-tools-version=VERSION \t Android build tools version. Default: 29.0.3\n
    --platform-version \t\t Android platform version. Default same as the build tools version.\n
    -l, --latest \t\t\t Flag build to latest\n
    -d, --dry-run \t\t Push to a local repository. (always flag build to latest). Without push the image to the docker hub.\
    -p, --push \t\t Push repository otherwise skips
    -h, --help \t\t\t Print usage description\n
EOM

IMAGE_NAME=android-build-tools
IMAGE=warnyul/"$IMAGE_NAME"

# Parameters
PUSH_TO_LOCAL=false
PUSH=false
LATEST=false
BUILD_TOOLS_VERSION="30.0.0"
PLATFORM_VERSION=$(echo "$BUILD_TOOLS_VERSION" | cut -d'.' -f1)

while [ $# -gt 0 ]; do
    case "$1" in
        --build-tools-version=*)
            BUILD_TOOLS_VERSION="${1#*=}"
            if [ -z $BUILD_TOOLS_VERSION ]; then
                echo -e "\n --build-tools-version is required.\n See './build.sh --help'.\n"
                echo -e "$USAGE"
                exit 1
            fi
        ;;
        --platform-version=*)
            PLATFORM_VERSION="${1#*=}"
            if [ -z $PLATFORM_VERSION ]; then
                echo -e "\n --platform-version is required.\n See './build.sh --help'.\n"
                echo -e "$USAGE"
                exit 1
            fi
        ;;
        -l|--latest)
            LATEST=true
        ;;
        -d|--dry-run)
            LATEST=true
            PUSH_TO_LOCAL=true
            IMAGE=localhost:5000/"$IMAGE_NAME"
        ;;
        -p|--push)
            PUSH=true
        ;;
        -h|--help|*)
            echo -e "\n Unknown argument: '$1'.\n See './build.sh --help'.\n"
            echo -e "$USAGE"
            exit 1
        ;;
    esac
    shift
done

IMAGE_VERSION="$BUILD_TOOLS_VERSION"-bionic-openjdk17

# Build
docker build \
    --build-arg ANDROID_BUILD_TOOLS_VERSION=$BUILD_TOOLS_VERSION \
    --build-arg ANDROID_PLATFORM_VERSION=$PLATFORM_VERSION \
    -t "$IMAGE":"$IMAGE_VERSION" .

# Start a local registry if necessary
if [ "$PUSH_TO_LOCAL" == "true" && "$PUSH" == "true" ]; then
    docker run -d -p 5000:5000 --restart=always --name registry registry 2>&1
fi 

# Tag as latest if necessary
if [ "$LATEST" == "true" ]; then
    docker tag "$IMAGE":"$IMAGE_VERSION" "$IMAGE":latest
fi

# Push the image
echo push "$IMAGE":"$IMAGE_VERSION"
if [ "$PUSH" == "true" ]; then
    docker push "$IMAGE"
fi
