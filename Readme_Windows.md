# MUMPS on Windows

MUMPS builds on Windows as well as other operating systems.
Windows Subsystem for Linux (WSL) is suggested and tested in our CI.
One may also use
[Intel oneAPI](https://www.intel.com/content/www/us/en/developer/tools/oneapi/hpc-toolkit-download.html)
using the Ninja build system with CMake.

These can be installed via WinGet:

```pwsh
winget install Ninja-build.Ninja
winget install Kitware.CMake

winget install Intel.OneAPI.BaseToolkit
winget install Intel.OneAPI.HPCToolkit
```

We have provided a helper script "build.bat" at the top of the MUMPS project directory.
One can edit / run this script to help get started.

## CMake Generator

In general on Windows, CMake is easier to use with Ninja as the build system backend.
That is, specify at CMake configure:

```sh
cmake -G Ninja -B build
```

To persist this setting across CMake projects, set Windows environment variable `CMAKE_GENERATOR` to `Ninja`.

### Troubleshooting generator

> CMake Error: CMake was unable to find a build program corresponding to "Ninja". CMAKE_MAKE_PROGRAM is not set.

then add the Ninja filepath to Windows environment variable `CMAKE_PROGRAM_PATH`.
Alternatively, tell CMake the full path to Ninja like:

```sh
cmake -G Ninja -B build -DCMAKE_MAKE_PROGRAM=C:/path/to/ninja.exe
```

## Compiler

Windows compilers known to work:

* Windows Subsystem for Linux (recommended in general for scientific computing on Windows)
* Intel [oneAPI](./Readme_oneapi.md)  -- requires oneAPI Base Toolkit and oneAPI HPC Toolkit for LAPACK, ScaLAPACK, and Intel MPI
* MSYS2

## CMake configure output

```sh
cmake -G Ninja -B build -DBUILD_SINGLE=yes -DBUILD_DOUBLE=yes -DBUILD_COMPLEX=yes -DBUILD_COMPLEX16=yes
```

To speed up MUMPS build and reduce binary size, feel free to omit (set to `no`) unneeded precisions in the command above.

Intel oneAPI Base Toolkit MKL LAPACK and Intel oneAPI HPC toolkit SCALAPACK are used.

## Build

```sh
cmake --build build
```

With the default options, under the build/ directory this results in library binaries for Windows oneAPI / Visual Studio:

```
dmumps.lib
mumps_common.lib
pord.lib
smumps.lib
```

or with WSL / MSYS2

```
libdmumps.a
libmumps_common.a
libpord.a
libsmumps.a
```

## Self test

Optionally, run self-tests:

```sh
ctest --test-dir build
```
