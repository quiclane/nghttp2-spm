// swift-tools-version: 6.2
import PackageDescription
let package=Package(name:"nghttp2-spm",platforms:[.iOS(.v13)],products:[.library(name:"nghttp2",targets:["nghttp2"])],targets:[.binaryTarget(name:"nghttp2",path:"NGHTTP2.xcframework")])
