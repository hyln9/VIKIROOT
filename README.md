# VIKIROOT

This is a CVE-2016-5195 PoC for 64-bit Android 6.0.1 Marshmallow (perhaps 7.0 ?), as well as an universal & stable temporal root tool.

## Features

- Memory-only
- SELinux bypass
- Stable
- Scalable
- Reversible

## Prerequisite
- *I, Robot* by Isaac Asimov.
- "dirtycow-capable" device.

## Building

Binaries are available on the release page. Otherwise, just run `make` in a native aarch64 debian.

## Usage

You may run it through an adb shell and get a root shell either in the built-in terminal or a remote terminal server such as nc. For details, run it without any parameters.

## Credits

@scumjr for the vdso patching method.

## TODO

- Turn it into a SuperSU installer.
- Enrich the kernel database for 32-bit support and so on.
- Test it on Android 7 Nougat (help wanted!).
