#!/bin/bash
set -e

export PATH=$PATH:$(go env GOPATH)/bin

cd "$(dirname "$0")/waku_bridge"

echo "Building Go-Waku for iOS..."
gomobile bind -target=ios -o ../ios/Frameworks/WakuBridge.xcframework \
    -objc-prefix="CW" \
    .

echo "iOS build complete: ios/Frameworks/WakuBridge.xcframework"
