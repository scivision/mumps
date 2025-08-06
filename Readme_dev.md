# CMake developer notes

These are notes that are shared as a technique that can be applied to other third-party projects to add CMake to them without disturbing project source code.

## Major point release

A major point release is like 5.5.0 to 5.6.0.
For MUMPS, there are typically changes in the source files used, so the Makefiles must be inspected for changes.

When a new
[MUMPS major release](https://mumps-solver.org/index.php?page=dwnld#cl)
occurs, download both the prior release and the current release.
Extract both release archives into distinct directories.

We have made a CMake + Python script to help compare MUMPS source files and Makefiles.

```sh
cmake -Dold="5.8.0" -Dnew="5.8.1" -P scripts/compare_mumps_version_source.cmake
```

This will show if there are any new and/or removed source files.
Update the CMake scripts to add / remove source files according to any relevant Makefile changes.

## Minor point release

A minor point release is like 5.6.0 to 5.6.1.
For MUMPS, there are typically not changes in the source files used, though it's always a good practice to check the Makefiles.
Use Meld for convenient visual comparison of the Makefiles.

Example: minor release
[patch](https://github.com/scivision/mumps/commit/c12584665024737f177d831256c6fb891104b133).

## All releases

[ ] Update the project(VERSION ...) in CMakeLists.txt to the latest release.
[ ] use `cmake -E sha256sum build/_deps/mumps-tmp/MUMPS_${MUMPS_UPSTREAM_VERSION}.tar.gz` to get the SHA256 checksum of the downloaded archive for cmake/libraries.json under mumps_sha256 key.

## Packaging

If it's desired to create an offline-installable package for MUMPS source:

```sh
cmake -Bbuild

cpack --config build/CPackSourceConfig.cmake
```
