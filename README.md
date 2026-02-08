nghttp2-spm
===========

Deterministic, auto-updating **nghttp2** binary distribution for Apple platforms,
packaged for **Swift Package Manager** as a prebuilt XCFramework.

This repo exists to solve one problem cleanly:

• build nghttp2 once, correctly, for iOS  
• ship it as a binary XCFramework  
• let Xcode users paste a URL and be done  

No local builds. No Homebrew. No CMake on user machines.

What this is
------------

- Upstream: https://github.com/nghttp2/nghttp2
- Artifact: static `libnghttp2.a` wrapped in `NGHTTP2.xcframework`
- Platforms: iOS (device + simulator)
- Distribution: SwiftPM binaryTarget
- Updates: fully automated via GitHub Actions

This repo **does not fork nghttp2 logic**.
It only builds, packages, versions, and distributes it deterministically.

Dependencies
------------

nghttp2 depends on **BoringSSL** for TLS when used in HTTP/2 stacks.

You must also include:

https://github.com/quiclane/boringssl-spm

These two packages are designed to work together.

Typical stack:
- boringssl-spm
- nghttp2-spm
- lsquic-spm (optional, for QUIC)

How to use in Xcode
-------------------

1. Open your Xcode project
2. Go to:
   File → Add Package Dependencies…
3. Paste this URL:

   https://github.com/quiclane/nghttp2-spm.git

4. When asked for version:
   - Choose **Up to Next Major**
   - Enter **1.0.0**

That’s it.

Xcode will download the XCFramework automatically.
No build steps run locally.

Versioning model (important)
----------------------------

You will see release tags like:

- ios-20260208-dcb6842fb673

These are **immutable, checksummed build artifacts**.
Each one corresponds to a specific upstream nghttp2 state.

However, Xcode / SwiftPM requires semantic versions.

To reconcile this, we use a **stable-pointer tagging model**:

- `1.0.0` → stable pointer
- `1.0.1` → fresh pointer

Both tags are **force-updated** to point at the latest verified XCFramework.

Think of them as symbolic links:

- `1.0.0` = “latest stable nghttp2 build”
- `1.0.1` = “latest fresh nghttp2 build”

The actual binary is still checksum-verified.
SwiftPM enforces integrity.

This gives you:
- deterministic builds
- zero user choice friction
- compatibility with Xcode’s resolver

Why not normal semantic versioning?
-----------------------------------

Because this repo is not a source library.

It is a **binary distribution mirror** of upstream C code.
Versioning the wrapper independently would be misleading.

The real version is:
- the upstream nghttp2 commit
- baked into the release tag hash

The `1.x.y` tags exist purely to satisfy SwiftPM ergonomics.

Toolchain
---------

- Swift tools version: 6.2
- Minimum iOS: 13.0
- Built with AppleClang via Xcode SDKs
- Static library only (no shared dylibs)

Guarantees
----------

- No dynamic linking
- No runtime downloads
- No post-install scripts
- No Homebrew assumptions
- No local compilation

Paste URL → works.

Related repos
-------------

- https://github.com/quiclane/boringssl-spm
- https://github.com/quiclane/lsquic-spm

All three follow the same model and are designed to interoperate.

License
-------

nghttp2 is licensed under its upstream license.
This repo only redistributes unmodified binaries built from upstream source.
Refer to nghttp2’s LICENSE for details.
