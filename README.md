# MUMPS sparse solver

[![ci](https://github.com/scivision/mumps/actions/workflows/ci.yml/badge.svg)](https://github.com/scivision/mumps/actions/workflows/ci.yml)
[![ci_windows](https://github.com/scivision/mumps/actions/workflows/ci_windows.yml/badge.svg)](https://github.com/scivision/mumps/actions/workflows/ci_windows.yml)
[![oneapi-linux](https://github.com/scivision/mumps/actions/workflows/oneapi-linux.yml/badge.svg)](https://github.com/scivision/mumps/actions/workflows/oneapi-linux.yml)

CMake downloads the source tarfile from MUMPS developer websites and builds.
CMake builds MUMPS in parallel faster and more conveniently than the original Makefiles.
CMake allows easy reuse of MUMPS in external projects via CMake
[FetchContent](https://github.com/scivision/mumps-fetchcontent)
or ExternalProject or `cmake --install`.

Many compilers and systems are supported by CMake build system on Windows, MacOS and Linux.
Static (default) or Shared `cmake -DBUILD_SHARED_LIBS=on` MUMPS builds are supported.

Platforms known to work with MUMPS and CMake include:

* Windows (use -G Ninja or -G "MinGW Makefiles")
  * MSYS2 (GCC)
  * Windows Subsystem for Linux (GCC)
  * Intel oneAPI
  * Visual Studio (C code) + oneAPI (Fortran code)
* MacOS
  * GCC (Homebrew)
  * Intel oneAPI
* Linux
  * GCC
  * Intel oneAPI
  * NVIDIA HPC SDK
* Cray

The MUMPS project is distinct from this CMake script wrapper.
See the
[MUMPS Users email list](https://listes.ens-lyon.fr/sympa/subscribe/mumps-users)
and
[MUMPS User Guide](https://graal.ens-lyon.fr/MUMPS/index.php?page=doc)
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

# Windows oneAPI / Visual Studio
dmumps.lib
mumps_common.lib
pord.lib
smumps.lib
```

If the system doesn't have LAPACK and SCALAPACK, first build and install them:

```sh
cmake -S scripts -B scripts/build -DCMAKE_INSTALL_PREFIX=~/mylibs
cmake --build scripts/build -t scalapack

# mumps
cmake -B build -DCMAKE_PREFIX_PATH=~/mylibs
cmake --build build
```

### MUMPS version selection

The MUMPS version defaults to a recent release.
For reproducibility, benchmarking and other purposes, one may select the version of MUMPS to build like:

```sh
cmake -B build -DMUMPS_UPSTREAM_VERSION=5.5.1
```

The MUMPS_UPSTREAM_VERSION works for MUMPS versions in
[cmake/libraries.json](./cmake/libraries.json).

## Usage

Numerous build options are available as in the following sections.
Most users can just use the defaults.

### MPI

For systems where MPI, BLACS and SCALAPACK are not available, or where non-parallel execution is suitable, the default parallel can be disabled at CMake configure time by option `cmake -Dparallel=false`.

### Precision

The default precision is float64 and float32.

```cmake
option(BUILD_SINGLE "Build single precision real" ON)
option(BUILD_DOUBLE "Build double precision real" ON)
option(BUILD_COMPLEX "Build single precision complex")
option(BUILD_COMPLEX16 "Build double precision complex")
```

### GEMMT symmetric matrix-matrix multiplication

For MUMPS &ge; 5.2.0, GEMMT symmetric matrix-matrix multiplication is recommended by the MUMPS User Guide if available.
By default GEMMT is ON, but may be disabed like:

```sh
cmake -Dgemmt=off
```

### Matlab / GNU Octave

Matlab / GNU Octave MEX interface may be built (one or the other) by EITHER:

```sh
-Dmatlab=on
-Doctave=on
```

These require `-Dparallel=off`.
These Matlab scripts seems to have been developed ~ 2006 and may not fully work anymore.
Ask the MUMPS Users List if you need such scripts.
We present them mainly as an example of compiling MEX libraries for Octave and Matlab with CMake.

### ordering

To use Scotch and METIS (requires MUMPS >= 5.0 and Scotch built with libesmumps):

```sh
cmake -Dscotch=true
```

Scotch can be built from source via CMake before MUMPS.
NOTE: the "-Dintsize64" must be the same for Scotch and MUMPS -- default is "off" for Scotch and MUMPS.

```sh
cmake -Dprefix=~/mumps -P scripts/build_scotch.cmake

# build MUMPS itself
cmake -Bbuild -DCMAKE_PREFIX_PATH=~/mumps -Dscotch=on
cmake --build build

# build MUMPS example
cmake -S example -B example/build -Dscotch=on
cmake --build example/build
---

If 64-bit integers are needed, use:

```sh
cmake -Dintsize64=true
```

### OpenMP

OpenMP can make MUMPS slower in certain situations.
Try with and without OpenMP to see which is faster for your situation.
Default is OpenMP OFF.

```sh
cmake -Dopenmp=true
```

## Reference

There are "if defined" checks for symbols we've observed that aren't documented. We don't enable these definitions.

```
MUMPS_F2003
NOAGG2
NOAGG3
NOAGG4
NOAGG5
OLDDFS
NOAMALGTOFATHER
ZERO_TRIANGLE
__ve__
LARGEMATRICES
SAK_BYROW
BLR_MT
VHOFFLOAD
```

These definitions are described in MUMPS docs:

* `MUMPS_WIN32` is auto-set in mumps_compat.h
* MUMPS &ge; 5.0 uses BLAS3 for efficiency, but `MUMPS_USE_BLAS2` allows BLAS2
* MUMPS &ge; 4.9 can fall back to out-of-core strategy via `OLD_OOC_NOPANEL`
* `DETERMINISTIC_PARALLEL_GRAPH` in MUMPS &ge; 5.0 makes graph deterministic for MPI workers (default off)

* `WORKAROUNDINTELILP64OPENMPLIMITATION` for OpenMP (not currently needed)
* `WORKAROUNDILP64MPICUSTOMREDUCE` was for IBM Platform MPI, which has been discontinued in favor of OpenMPI (obsolete)
* `WORKAROUNDINTELILP64MPI2INTEGER` we use this if intsize64=true
