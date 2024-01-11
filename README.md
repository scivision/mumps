# MUMPS sparse solver

[![ci](https://github.com/scivision/mumps/actions/workflows/ci.yml/badge.svg)](https://github.com/scivision/mumps/actions/workflows/ci.yml)
[![ci_build](https://github.com/scivision/mumps/actions/workflows/ci_build.yml/badge.svg)](https://github.com/scivision/mumps/actions/workflows/ci_build.yml)
[![ci_windows](https://github.com/scivision/mumps/actions/workflows/ci_windows.yml/badge.svg)](https://github.com/scivision/mumps/actions/workflows/ci_windows.yml)
[![oneapi-linux](https://github.com/scivision/mumps/actions/workflows/oneapi-linux.yml/badge.svg)](https://github.com/scivision/mumps/actions/workflows/oneapi-linux.yml)

CMake downloads the unmodified source tarfile from MUMPS developers and builds.
CMake builds MUMPS in parallel faster and more conveniently than the original Makefiles.
CMake allows easy reuse of MUMPS in external projects via CMake
[FetchContent](https://github.com/scivision/mumps-fetchcontent)
or ExternalProject or `cmake --install`.

[MUMPS CeCILL-C license](https://mumps-solver.org/index.php?page=dwnld#license)
is distinct from this CMake script license.
MUMPS teams typically make new
[releases](https://mumps-solver.org/index.php?page=dwnld#cl)
each year.

Many compilers and systems are supported by CMake build system on Windows, MacOS and Linux.
Static (default) or Shared `cmake -DBUILD_SHARED_LIBS=on` MUMPS builds are supported.

Platforms known to work with MUMPS and CMake include:

* [Windows](./Readme_Windows.md)
* MacOS
  * GCC (Homebrew)
  * Intel oneAPI
* Linux
  * GCC
  * Intel oneAPI
  * NVIDIA HPC SDK
  * Cray

By default PORD ordering is used.
[Scotch, METIS, and parMETIS ordering](./Readme_ordering.md)
can be used.

Several [LAPACK vendors](./Readme_LAPACK.md) are supported.

The MUMPS project is distinct from this CMake script wrapper.
See the
[MUMPS Users email list](https://listes.ens-lyon.fr/sympa/subscribe/mumps-users)
and
[MUMPS User Guide](https://mumps-solver.org/index.php?page=doc)
for any questions about MUMPS itself.

## Build

From this repo's top directory:

```sh
cmake -B build
cmake --build build
```

With the default options, under the build/ directory this results in library binaries:

```
# Linux / MacOS / MSYS2
libdmumps.a
libmumps_common.a
libpord.a
libsmumps.a
```

Numerous MUMPS [build options are available](./Readme_options.md).

## Self test

Optionally, run self-tests:

```sh
ctest --test-dir build
```
