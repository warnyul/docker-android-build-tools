#!/usr/bin/env bash

function trim() {
    while read -r line; do
        echo "$line"
    done
}

function readBuildToolsVersions() {
    sdkmanager --list | grep build-tools | cut -d'|' -f1 | cut -d';' -f2 | trim
}

function autoRelease() {
    if [ ! -f METADATA ]; then
        wget https://android.googlesource.com/platform/prebuilts/cmdline-tools/+/refs/heads/main/METADATA
    fi
    local -r downloadUrl=$(grep -Eo 'https?://dl\.google\.com/android/repository/commandlinetools-linux-([[:digit:]]+)_latest\.zip' METADATA)
    local -r commandLineToolsRevisionNumber=$(echo "$downloadUrl" | cut -d'_' -f1 | cut -d'-' -f3)
    local -r buildToolsVersions=$(readBuildToolsVersions | sort | uniq )
    local -r latest=$(echo "$buildToolsVersions" | grep -v '-' | tail -n 1)

    while read -r line; do      
        local dockerImageVersion="$line"-bionic-openjdk17
        if [ "$(grep "\b${dockerImageVersion/-/\-}\b" .publishedVersions)" != "" ]; then
            echo "skip ${dockerImageVersion}"
        else
            echo "build ${dockerImageVersion}"
            if [ "$line" == "$latest" ]; then
                local latestArg='-l'
            else
                local latestArg=''
            fi
            ./build.sh -d --build-tools-version=${line} ${latestArg}
            echo "ok"
            if [ $? == 0 ]; then
                echo "$dockerImageVersion" >> .publishedVersions
            fi
        fi
    done <<< "$buildToolsVersions"
    rm -rf METADATA
}

autoRelease