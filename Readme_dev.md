# CMake developer notes

These are notes that are shared as a technique that can be applied to other third-party projects to add CMake to them without disturbing project source code.

## Major point release

A major point release is like 5.5.0 to 5.6.0.
For MUMPS, there are typically changes in the source files used, so the Makefiles must be inspected for changes.

When a new
[MUMPS major release](https://mumps-solver.org/index.php?page=dwnld#cl)
occurs, download both the prior release and the current release.
Extract both release archives into distinct directories.

Do a "diff" of the Makefiles--perhaps via Meld.
This will show if there are any new and/or removed source files.
Update the CMake scripts according to any relevant Makefile changes.

## Minor point release

A minor point release is like 5.6.0 to 5.6.1.
For MUMPS, there are typically not changes in the source files used, though it's always a good practice to check the Makefiles.

Example: minor release
[patch](https://github.com/scivision/mumps/commit/c12584665024737f177d831256c6fb891104b133).

## All releases

The URL of the new release can be extrapolated from
[libraries.json](./cmake/libraries.json).

Change the default MUMPS_UPSTREAM_VERSION to the latest release.

Upload the latest MUMPS source archive to Zenodo using "new version".
Zenodo is faster and more reliable than MUMPS server hosting.
Update cmake/libraries.json to point to the new source archive URLs.

## Packaging

If it's desired to create an offline-installable package for MUMPS source:

```sh
cmake -Bbuild

cpack --config build/CPackSourceConfig.cmake
```
