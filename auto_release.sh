#!/usr/bin/env bash

function trim() {
    while read -r line; do
        echo "$line"
    done
}

function readBuildToolsVersions() {
    "$ANDROID_HOME"/cmdline-tools/latest/bin/sdkmanager --list | grep build-tools | cut -d'|' -f1 | cut -d';' -f2 | trim
}

function autoRelease() {
    if [ ! -f METADATA ]; then
        wget https://android.googlesource.com/platform/prebuilts/cmdline-tools/+/refs/heads/main/METADATA
    fi
    local -r downloadUrl=$(grep -Eo 'https?://dl\.google\.com/android/repository/commandlinetools-linux-([[:digit:]]+)_latest\.zip' METADATA)
    local -r commandLineToolsRevisionNumber=$(echo "$downloadUrl" | cut -d'_' -f1 | cut -d'-' -f3)
    local -r buildToolsVersions=$(readBuildToolsVersions | sort | uniq )
    local -r latest=$(echo "$buildToolsVersions" | grep -v '-' | tail -n 1)
    local -r ubuntuDistribution=$(grep -Eo 'FROM ubuntu:(.*)' Dockerfile | cut -d':' -f2)
    local -r openJdkVersion=$(grep -Eo 'openjdk-([[:digit:]]+)' Dockerfile | cut -d'-' -f2)

    while read -r line; do
        local dockerImageVersion="$line"-"$ubuntuDistribution"-openjdk"$openJdkVersion"
        if [ "$(grep "\b${dockerImageVersion/-/\-}\b" .publishedVersions)" != "" ]; then
            echo "skip ${dockerImageVersion}"
        else
            echo "build ${dockerImageVersion}"
            if [ "$line" == "$latest" ]; then
                local latestArg='--latest'
            else
                local latestArg=''
            fi
            ./build.sh --push --build-tools-version=${line} ${latestArg}
            if [ $? == 0 ]; then
                echo "$dockerImageVersion" >> .publishedVersions
            fi
            docker rmi -f --no-prune $(docker images 'warnyul/android-build-tools' -a -q)
        fi
    done <<< "$buildToolsVersions"
    rm -rf METADATA
}

autoRelease