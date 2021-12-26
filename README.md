# MUMPS sparse solver

![ci_build](https://github.com/scivision/mumps-cmake/workflows/ci_build/badge.svg)
![ci](https://github.com/scivision/mumps-cmake/workflows/ci/badge.svg)
![ci_mac](https://github.com/scivision/mumps-cmake/workflows/ci_mac/badge.svg)
![ci_windows](https://github.com/scivision/mumps-cmake/workflows/ci_windows/badge.svg)
[![intel-oneapi](https://github.com/gemini3d/gemini3d/actions/workflows/intel-oneapi.yml/badge.svg)](https://github.com/gemini3d/gemini3d/actions/workflows/intel-oneapi.yml)

CMake downloads the source tarfile from MUMPS developer websites and builds in parallel.
CMake builds MUMPS in parallel **10x faster** than the Makefiles.
CMake allows easy reuse of MUMPS in external projects via CMake
[FetchContent](https://github.com/scivision/mumps-fetchcontent) or ExternalProject or `cmake --install`.

Many compilers and systems are supported by CMake build system on Windows, MacOS and Linux.
Static (default) or Shared `cmake -DBUILD_SHARED_LIBS=on` MUMPS builds are supported.
Please open a GitHub Issue if you have a problem building Mumps with CMake.

Platforms known to work with MUMPS and CMake include:

* Windows (use -G Ninja or -G "MinGW Makefiles")
  * MSYS2 (GCC)
  * Windows Subsystem for Linux (GCC)
  * Intel oneAPI
* MacOS
  * GCC (Homebrew)
  * Intel oneAPI
* Linux
  * GCC
  * Intel oneAPI
  * NVIDIA HPC SDK

## Build

After "git clone" this repo:

```sh
cmake -B build
cmake --build build
```

For Windows in general (including with Intel compiler) we suggest using Ninja:

```sh
cmake -G Ninja -B build
```

or GNU Make:

```sh
cmake -G "MinGW Makefiles" -B build
```

### MUMPS version selection

The MUMPS version defaults to a recent release.
For reproducibility, benchmarking and other purposes, one may select the version of MUMPS to build like:

```sh
cmake -B build -DMUMPS_UPSTREAM_VERSION=5.3.5
```

The MUMPS_UPSTREAM_VERSION works for MUMPS >= 4.8.0 at this time; only for MUMPS versions in
[cmake/libraries.json](./cmake/libraries.json).

## Usage

To use MUMPS as via CMake ExternalProject do like in [mumps.cmake](https://github.com/gemini3d/gemini3d/blob/main/cmake/ext_libs/mumps.cmake).

then link to your project target `foo` via `target_link_libraries(foo MUMPS::MUMPS)`

Numerous build options are available as in the following sections. Most users can just use the defaults.

**autobuild prereqs**
The `-Dautobuild=true` CMake default will download and build a local copy of Lapack and/or Scalapack if missing or broken.

**MPI / non-MPI**
For systems where MPI, BLACS and SCALAPACK are not available, or where non-parallel execution is suitable, the default parallel can be disabled at CMake configure time by option -Dparallel=false.

Precision: The default precision is "s;d" covering float64 and float32.
The build-time parameter:

```sh
cmake -Darith="s;d"
```

may be optionally specified:

```
-Darith=s  # real32
-Darith=d  # real64
-Darith=c  # complex64
-Darith=z  # complex128
```

More than one precision may be specified simultaneously like:

```sh
cmake "-Darith=s;d"
```

### ordering

To use Scotch and METIS (requires MUMPS >= 5.0):

```sh
cmake -B build -Dscotch=true
```

If 64-bit integers are needed, use:

```sh
cmake -B build -Dintsize64=true
```

Note that intsize64 is only known to work with GCC at this time.
Intel oneMKL with GCC does not work, nor does Intel oneAPI compilers.

### OpenMP

OpenMP can make MUMPS slower in certain situations. Try with and without OpenMP to see which is faster for your situation. Default is OpenMP OFF.

-Dopenmp=true / false

Install
Installing avoids having to build MUMPS repeatedly in external projects. Set environment variable MUMPS_ROOT= path to your MUMPS install to find this MUMPS.

CMake:

```sh
cmake -B build -DCMAKE_INSTALL_PREFIX=~/mylibs/mumps/
```

other
To fully specify prerequisite library locations add options like:

---

Instead of compiling, one may install precompiled libraries by:

Ubuntu: `apt install libmumps-dev`
CentOS: `yum install MUMPS-openmpi`
