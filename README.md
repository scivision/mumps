# MUMPS sparse solver

![ci_build](https://github.com/scivision/mumps-cmake/workflows/ci_build/badge.svg)
![ci](https://github.com/scivision/mumps-cmake/workflows/ci/badge.svg)
![ci_mac](https://github.com/scivision/mumps-cmake/workflows/ci_mac/badge.svg)
![ci_windows](https://github.com/scivision/mumps-cmake/workflows/ci_windows/badge.svg)

We avoid distributing extracted MUMPS sources ourselves--instead CMake will download the tarfile and extract, then we inject the CMakeLists.txt and build.

CMake:

* builds MUMPS in parallel 10x faster than the Makefiles
* allows easy reuse of MUMPS in external projects via CMake FetchContent

Many compilers and systems are supported by CMake build system on Windows, MacOS and Linux. Please open a GitHub Issue if you have a problem building Mumps with CMake. Some compiler setups are not ABI compatible, that isn't a build system issue.

The compiler platforms known to work with MUMPS and CMake include:

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

## Usage

To use MUMPS as via CMake ExternalProject do like in [mumps.cmake](https://github.com/gemini3d/gemini3d/blob/main/cmake/ext_libs/mumps.cmake).

then link to your project target `foo` via `target_link_libraries(foo MUMPS::MUMPS)`

Numerous build options are available as in the following sections. Most users can just use the defaults.

**autobuild prereqs**
The -Dautobuild=true CMake default will download and build a local copy of Lapack and/or Scalapack if missing or broken.

**MPI / non-MPI**
For systems where MPI, BLACS and SCALAPACK are not available, or where non-parallel execution is suitable, the default parallel can be disabled at CMake configure time by option -Dparallel=false.

Precision: The default precision is "s;d" meaning real float64 and float32. The build-time parameter

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

To use Metis and/or Scotch, add configure options like:

```sh
cmake -B build -Dmetis=true -Dscotch=true
```

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

MUMPS is available for Linux, OSX and Windows.
