#!/usr/bin/env bash

set +e

read -r -d '' USAGE <<- EOM
    \n
    Usage: ./build.sh [OPTIONS]\n
    \n
    Options:\n
    --build-tools-version=VERSION \t Android build tools version\n
    -l, --latest \t\t\t Flag build to latest\n
    -lp, --local-push \t\t Push to a local repository. (always flag build to latest)\n
    -p, --push \t\t\t Push image to docker hub\n
    -h, --help \t\t\t Print usage description\n
EOM

IMAGE_NAME=android-build-tools
IMAGE=warnyul/$IMAGE_NAME
LOCAL_IMAGE=localhost:5000/$IMAGE_NAME

# Parameters
LOCAL_PUSH=false
PUSH=false
LATEST=false
BUILD_TOOLS_VERSION="29.0.3"

while [ $# -gt 0 ]; do
    case "$1" in
        --build-tools-version=*)
            BUILD_TOOLS_VERSION="${1#*=}"
            if [ -z $BUILD_TOOLS_VERSION ]; then
                echo -e "\n --build-tools-version is required.\n See './build.sh --help'.\n"
                echo -e $USAGE
                exit 1
            fi
        ;;
        -l|--latest)
            LATEST=true
        ;;
        -lp|--local-push)
            LATEST=true
            LOCAL_PUSH=true
        ;;
        -p|--push)
            PUSH=true
        ;;
        -h|--help|*)
            echo -e "\n Unknown argument: '$1'.\n See './build.sh --help'.\n"
            echo -e $USAGE
            exit 1
        ;;
    esac
    shift
done

echo $BUILD_TOOLS_VERSION

# Build
docker build --build-arg ANDROID_BUILD_TOOLS_VERSION=$ANDROID_BUILD_TOOLS_VERSION -t "$IMAGE:$BUILD_TOOLS_VERSION" .

if $LATEST; then
    docker tag "$IMAGE:$BUILD_TOOLS_VERSION" "$IMAGE:latest"
fi 

# Publish to a local repo
if $LOCAL_PUSH; then
    docker run -d -p 5000:5000 --restart=always --name registry registry 2> /dev/null
    docker tag "$IMAGE:$BUILD_TOOLS_VERSION" "$LOCAL_IMAGE:$BUILD_TOOLS_VERSION"
    docker tag "$IMAGE:$BUILD_TOOLS_VERSION" "$LOCAL_IMAGE:latest"
    docker push $LOCAL_IMAGE
fi

# Publish to Docker Hub
if $PUSH; then
    docker push $IMAGE
fi

