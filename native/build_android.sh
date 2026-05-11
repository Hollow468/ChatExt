#!/bin/bash
set -e

export ANDROID_HOME=${ANDROID_HOME:-$HOME/.android/Sdk}
export ANDROID_NDK_HOME=${ANDROID_NDK_HOME:-$ANDROID_HOME/ndk/28.2.13676358}
export PATH=$PATH:$(go env GOPATH)/bin
export GOFLAGS="-ldflags=-checklinkname=0"

cd "$(dirname "$0")/waku_bridge"

echo "Building Go-Waku for Android..."
gomobile bind -target=android -androidapi 21 -tags gowaku_no_rln -o ../android/app/libs/waku.aar \
    -javapkg=org.chatext.waku \
    .

echo "Android build complete: android/app/libs/waku.aar"
