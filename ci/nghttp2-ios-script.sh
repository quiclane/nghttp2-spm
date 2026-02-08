#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.."&&pwd)"
CFG="$ROOT/ci/nghttp2-upstream.txt"
REPO="$(awk -F= '/^repo=/{print $2}' "$CFG"|tail -n1)"
BRANCH="$(awk -F= '/^branch=/{print $2}' "$CFG"|tail -n1)"
UPROOT="$ROOT/_upstream"
UPDIR="$UPROOT/nghttp2"
OUT="$ROOT/build-out"
SDK_IOS="$(xcrun --sdk iphoneos --show-sdk-path)"
SDK_SIM="$(xcrun --sdk iphonesimulator --show-sdk-path)"
rm -rf "$UPROOT" "$OUT"
mkdir -p "$UPROOT" "$OUT"
git clone --depth 1 --branch "$BRANCH" "$REPO" "$UPDIR"
echo "== top CMakeLists key lines =="
sed -n '1,260p' "$UPDIR/CMakeLists.txt" | nl -ba | egrep -n 'ENABLE_|STATIC|SHARED|BUILD_SHARED|nghttp2_static|add_library\(' || true
echo "== lib/CMakeLists around alias =="
sed -n '90,170p' "$UPDIR/lib/CMakeLists.txt" | nl -ba || true
build_one(){ name="$1"; sysroot="$2"; archs="$3"; bdir="$OUT/$name"; cmake -S "$UPDIR" -B "$bdir" -G Ninja -DCMAKE_BUILD_TYPE=Release -DCMAKE_SYSTEM_NAME=iOS -DCMAKE_OSX_SYSROOT="$sysroot" -DCMAKE_OSX_ARCHITECTURES="$archs" -DCMAKE_POSITION_INDEPENDENT_CODE=ON -DBUILD_TESTING=OFF -DBUILD_STATIC_LIBS=ON -DBUILD_SHARED_LIBS=OFF -DENABLE_APP=OFF -DENABLE_HPACK_TOOLS=OFF -DENABLE_EXAMPLES=OFF -DENABLE_PYTHON_BINDINGS=OFF -DENABLE_HTTP3=OFF -DENABLE_BROTLI=OFF -DENABLE_ZLIB=OFF -DENABLE_JEMALLOC=OFF -DENABLE_LIBEV=OFF -DENABLE_SYSTEMD=OFF -DENABLE_MRUBY=OFF -DENABLE_NEVERBLEED=OFF; ninja -C "$bdir"; }
build_one ios_arm64 "$SDK_IOS" arm64
build_one ios_sim "$SDK_SIM" "arm64;x86_64"
LIB_IOS="$(find "$OUT/ios_arm64" -name 'libnghttp2.a' -print -quit)"
LIB_SIM="$(find "$OUT/ios_sim" -name 'libnghttp2.a' -print -quit)"
HDR_ROOT="$OUT/headers"
rm -rf "$HDR_ROOT"
mkdir -p "$HDR_ROOT"
cp -R "$UPDIR/lib/includes/" "$HDR_ROOT/"
mkdir -p "$HDR_ROOT/nghttp2"
cp -f "$ROOT/overlay-headers/nghttp2/nghttp2ver.h" "$HDR_ROOT/nghttp2/nghttp2ver.h"
find "$HDR_ROOT" -name "nghttp2ver.h.in" -delete
rm -rf "$HDR_ROOT"
mkdir -p "$HDR_ROOT/nghttp2"
cp -f "$UPDIR/lib/includes/nghttp2/"*.h "$HDR_ROOT/nghttp2/"
if [ -f "$ROOT/overlay-headers/nghttp2/nghttp2ver.h" ]; then cp -f "$ROOT/overlay-headers/nghttp2/nghttp2ver.h" "$HDR_ROOT/nghttp2/nghttp2ver.h"; fi
xcodebuild -create-xcframework -library "$LIB_IOS" -headers "$HDR_ROOT" -library "$LIB_SIM" -headers "$HDR_ROOT" -output "$OUT/NGHTTP2.xcframework"
ditto -c -k --sequesterRsrc --keepParent "$OUT/NGHTTP2.xcframework" "$OUT/NGHTTP2.xcframework.zip"
cd "$ROOT"||exit 1
mkdir -p nghttp2-spm
rm -rf nghttp2-spm/NGHTTP2.xcframework
ditto "$OUT/NGHTTP2.xcframework" nghttp2-spm/NGHTTP2.xcframework
cp -f "$OUT/NGHTTP2.xcframework.zip" nghttp2-spm/NGHTTP2.xcframework.zip
git add nghttp2-spm/NGHTTP2.xcframework nghttp2-spm/NGHTTP2.xcframework.zip
git commit -m "ci: publish NGHTTP2 build artifacts"||true
git pull origin main --rebase
git push origin main
echo "== Build completed successfully =="
