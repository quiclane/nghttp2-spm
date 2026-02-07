// swift-tools-version: 6.2
import PackageDescription
let package=Package(name:"nghttp2-spm",platforms:[.iOS(.v13)],products:[.library(name:"nghttp2",targets:["nghttp2"])],targets:[.binaryTarget(name:"nghttp2",url:"https://github.com/quiclane/nghttp2-spm/releases/download/ios-20260208-dcb6842fb673/NGHTTP2.xcframework.zip",checksum:"774c7667b74583ff4eb30acbaa1228bcc4edb6f1cca1010d5a1384c42a8521e4")])
