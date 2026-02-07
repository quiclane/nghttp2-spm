#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CFG="$ROOT/ci/nghttp2-upstream.txt"
REPO="$(awk -F= '/^repo=/{print $2}' "$CFG" | tail -n1)"
BRANCH="$(awk -F= '/^branch=/{print $2}' "$CFG" | tail -n1)"
UPROOT="$ROOT/_upstream"
UPDIR="$UPROOT/nghttp2"
OUT="$ROOT/build-out"
SDK_IOS="$(xcrun --sdk iphoneos --show-sdk-path)"
SDK_SIM="$(xcrun --sdk iphonesimulator --show-sdk-path)"
rm -rf "$UPROOT" "$OUT"
mkdir -p "$UPROOT" "$OUT"
git clone --depth 1 --branch "$BRANCH" "$REPO" "$UPDIR"
build_one(){ name="$1"; sysroot="$2"; archs="$3"; bdir="$OUT/$name"; cmake -S "$UPDIR" -B "$bdir" -G Ninja -DCMAKE_BUILD_TYPE=Release -DCMAKE_SYSTEM_NAME=iOS -DCMAKE_OSX_SYSROOT="$sysroot" -DCMAKE_OSX_ARCHITECTURES="$archs" -DCMAKE_POSITION_INDEPENDENT_CODE=ON -DBUILD_SHARED_LIBS=OFF -DBUILD_TESTING=OFF -DENABLE_STATIC_LIB=ON -DENABLE_SHARED_LIB=OFF -DENABLE_APP=OFF -DENABLE_HPACK_TOOLS=OFF -DENABLE_EXAMPLES=OFF -DENABLE_PYTHON_BINDINGS=OFF -DENABLE_HTTP3=OFF -DENABLE_BROTLI=OFF -DENABLE_ZLIB=OFF -DENABLE_JEMALLOC=OFF -DENABLE_LIBEV=OFF -DENABLE_SYSTEMD=OFF -DENABLE_MRUBY=OFF -DENABLE_NEVERBLEED=OFF; ninja -C "$bdir"; }
build_one ios_arm64 "$SDK_IOS" arm64
build_one ios_sim "$SDK_SIM" "arm64;x86_64"
LIB_IOS="$(find "$OUT/ios_arm64" -name 'libnghttp2.a' -print -quit)"
LIB_SIM="$(find "$OUT/ios_sim" -name 'libnghttp2.a' -print -quit)"
HDR_DIR="$UPDIR/lib/includes"
xcodebuild -create-xcframework -library "$LIB_IOS" -headers "$HDR_DIR" -library "$LIB_SIM" -headers "$HDR_DIR" -output "$OUT/NGHTTP2.xcframework"
ditto -c -k --sequesterRsrc --keepParent "$OUT/NGHTTP2.xcframework" "$OUT/NGHTTP2.xcframework.zip"
