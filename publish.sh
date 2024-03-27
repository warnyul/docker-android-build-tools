#!/usr/bin/env bash

function publish() {
    local -r matrixItem="$1"
    local -r agpVersion=$(echo "$matrixItem" | cut -d'@' -f1)
    local -r isLatest=$(echo "$matrixItem" | cut -d'@' -f1)

    if [ ! -f METADATA ]; then
        wget https://android.googlesource.com/platform/prebuilts/cmdline-tools/+/refs/heads/main/METADATA
    fi

    local -r downloadUrl=$(grep -Eo 'https?://dl\.google\.com/android/repository/commandlinetools-linux-([[:digit:]]+)_latest\.zip' METADATA)
    local -r commandLineToolsRevisionNumber=$(echo "$downloadUrl" | cut -d'_' -f1 | cut -d'-' -f3)

    if [ "$isLatest" == "true" ]; then
        local latestArg="--latest"
    else
        local latestArg=""
    fi
    
    ./build.sh --push --build-tools-version="${agpVersion}" --command-line-tools-version="${commandLineToolsRevisionNumber}" ${latestArg}

    rm -rf METADATA
}

publish "$@"