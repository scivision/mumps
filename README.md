# MUMPS sparse solver

[![ci](https://github.com/scivision/mumps/actions/workflows/ci.yml/badge.svg)](https://github.com/scivision/mumps/actions/workflows/ci.yml)
[![ci_build](https://github.com/scivision/mumps/actions/workflows/ci_build.yml/badge.svg)](https://github.com/scivision/mumps/actions/workflows/ci_build.yml)
[![oneapi-linux](https://github.com/scivision/mumps/actions/workflows/oneapi-linux.yml/badge.svg)](https://github.com/scivision/mumps/actions/workflows/oneapi-linux.yml)

CMake downloads the unmodified source tarfile from MUMPS developers and builds.
For offline usage, the user can specify a local MUMPS source archive like `cmake -Bbuild -DMUMPS_url=/path/to/mumps.zip`

CMake builds MUMPS in parallel faster and more conveniently than the original Makefiles.
CMake allows easy reuse of MUMPS in external projects via any of:

* CMake [FetchContent](https://gist.github.com/scivision/2ad002ed26589783f1522160da4d27d1)
* build MUMPS, `cmake --install`, then [find_package(MUMPS CONFIG REQUIRED)](https://gist.github.com/scivision/1ea2d19011c165b39b15ccb95d54f451)
* CMake ExternalProject_Add (similar to FetchContent example)

[MUMPS CeCILL-C license](https://mumps-solver.org/index.php?page=dwnld#license)
is distinct from this CMake script license.
MUMPS teams typically make new
[releases](https://mumps-solver.org/index.php?page=dwnld#cl)
each year.

Many compilers and systems are supported by CMake build system on Windows, MacOS and Linux.
Static (default) or Shared `cmake -DBUILD_SHARED_LIBS=on` MUMPS builds are supported.

Virtually all contemporary compilers work, including GCC, Clang/Flang, oneAPI, NVHPC, AOCC, Cray, etc.

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

Numerous MUMPS [build options are available](./Readme_options.md).

The default precision is float64 and float32.
To build all precisions including complex64, complex128 do:

```sh
cmake -Bbuild -DBUILD_SINGLE=on -DBUILD_DOUBLE=on -DBUILD_COMPLEX=on -DBUILD_COMPLEX16=on

cmake --build build
```

The headers and library are optionally installed to an install prefix:

```sh
cmake -Bbuild --install-prefix /path/to/install/mumps

cmake --install build
```

With the default options the build/ directory contains library binaries ([Windows](./Readme_Windows.md) binaries have different names):

* libdmumps.a (real64)
* libsmumps.a (real32)
* libmumps_common.a (common MUMPS routines)
* libpord.a  (PORD library)

If `-DMUMPS_parallel=no` was set, an additional helper library is built in place of linking MPI libraries:

* libmpiseq.a

These libraries can be linked into C, C++, Fortran, etc. programs, or even be used with appropriate interfaces from [Matlab](./Readme_matlab.md) and Python
[PyMUMPS](https://pypi.org/project/PyMUMPS/)
and
[python-mumps](https://pypi.org/project/python-mumps/).

## Self test and examples

Optionally, run self-tests:

```sh
ctest --test-dir build
```

To build the example, first "install" the MUMPS package-the default install location is under the MUMPS build/local directory:

```sh
cmake --install build

cmake -S example -B example/build -DMUMPS_ROOT=build/local

cmake --build example/build
```

## Using binary libraries

Linking the MUMPS binaries into a user-program is project-dependent.
An example using the examples in this project with GNU GCC, using the "mpicxx" MPI compiler wrapper:

```sh
mpicxx ./example/d_example.cpp -I./build/local/include -L./build/local/lib -ldmumps -lmumps_common -lpord -lscalapack -lblacs -llapack -lblas -lgfortran
```

If `-DMUMPS_parallel=no` was used to build MUMPS, instead do:

```sh
g++ ./example/d_example.cpp -I./build/local/include -L./build/local/lib -ldmumps -lmumps_common -lpord -llapack -lblas -lmpiseq -lgfortran
```
