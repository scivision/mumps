# MUMPS on Windows

MUMPS builds on native Windows as well as other operating systems, including Windows Subsystem for Linux.
For native Windows builds, we strongly suggest
[Intel oneAPI](https://www.intel.com/content/www/us/en/developer/tools/oneapi/hpc-toolkit-download.html?operatingsystem=linux)
using the
[Ninja](https://github.com/ninja-build/ninja/releases)
build system with CMake.

Windows CMake for MUMPS must use Ninja or Make as the build system backend.
That is, specify at CMake configure:

```sh
cmake -G Ninja

# or

cmake -G "MinGW Makefiles"
```

The CMake Windows default generator "Visual Studio 17 2022" **does not work**, even when using MSVC compiler.

NOTE: on Windows, Intel oneAPI MKL only supports oneAPI compiler.
This is distinct from Linux, where oneMKL supports oneAPI and GCC compilers.

Windows compilers known to work:

* Intel oneAPI (recommended) -- requires oneAPI Base Toolkit and oneAPI HPC Toolkit for LAPACK and ScaLAPACK
* MSYS2 (GCC)
* Windows Subsystem for Linux (GCC)
* Visual Studio (C code) + oneAPI (Fortran code)  (more difficult, use only if needed)

If using **oneAPI**, be sure to use the oneAPI command prompt.
Under Windows Start menu look for "Intel oneAPI command prompt for Intel 64 for Visual Studio".
Alternatively, use the oneAPI [setvars.bat](https://www.intel.com/content/www/us/en/develop/documentation/oneapi-programming-guide/top/oneapi-development-environment-setup/use-the-setvars-script-with-windows.html).
On any code project on Windows, having the correct command prompt and environment variables is essential.

```sh
cmake -G Ninja -B build -DBUILD_SINGLE=yes -DBUILD_DOUBLE=yes -DBUILD_COMPLEX=yes -DBUILD_COMPLEX16=yes
```

To speed up MUMPS build and reduce binary size, feel free to omit (set to `no`) unneeded precisions in the command above.

Configure output includes:

```
-- Building for: Ninja
-- The C compiler identification is IntelLLVM 2023.0.0 with MSVC-like command-line
-- The Fortran compiler identification is IntelLLVM 2023.0.0 with MSVC-like command-line
<snip>
-- Performing Test LAPACK_s_FOUND
-- Performing Test LAPACK_s_FOUND - Success
-- Performing Test LAPACK_d_FOUND
-- Performing Test LAPACK_d_FOUND - Success
-- Found LAPACK: C:/Program Files (x86)/Intel/oneAPI/mkl/latest/lib/intel64/mkl_intel_lp64.lib;C:/Program Files (x86)/Intel/oneAPI/mkl/latest/lib/intel64/mkl_sequential.lib;C:/Program Files (x86)/Intel/oneAPI/mkl/latest/lib/intel64/mkl_core.lib  found components: MKL
-- Performing Test BLAS_HAVE_dGEMMT
-- Performing Test BLAS_HAVE_dGEMMT - Success
-- Performing Test BLAS_HAVE_sGEMMT
-- Performing Test BLAS_HAVE_sGEMMT - Success
-- Performing Test BLAS_HAVE_cGEMMT
-- Performing Test BLAS_HAVE_cGEMMT - Success
-- Performing Test BLAS_HAVE_zGEMMT
-- Performing Test BLAS_HAVE_zGEMMT - Success
-- Found MPI_C: C:/Program Files (x86)/Intel/oneAPI/mpi/latest/lib/release/impi.lib (found version "3.1")
-- Found MPI_Fortran: C:/Program Files (x86)/Intel/oneAPI/mpi/latest/lib/release/impi.lib (found version "3.1")
-- Found MPI: TRUE (found version "3.1") found components: C Fortran
-- Performing Test SCALAPACK_d_FOUND
-- Performing Test SCALAPACK_d_FOUND - Success
-- Performing Test SCALAPACK_s_FOUND
-- Performing Test SCALAPACK_s_FOUND - Success
-- Found SCALAPACK: C:/Program Files (x86)/Intel/oneAPI/mkl/latest/lib/intel64/mkl_scalapack_lp64.lib  found components: MKL
<snip>
-- The following features have been enabled:

 * Parallel, parallel MUMPS (using MPI and Scalapack)
 * GEMMT, use GEMMT for symmetric matrix-matrix multiplication
 * real32, Build with single precision
 * real64, Build with double precision
 * complex32, Build with complex precision
 * complex64, Build with complex16 precision

-- The following features have been disabled:

 * 64-bit-integer, use 64-bit integers in C and Fortran
 * Scotch, Scotch graph partitioning https://www.labri.fr/perso/pelegrin/scotch/
 * Openmp, OpenMP API https://www.openmp.org/
 * shared, Build shared libraries
```

Observe that Intel oneAPI Base Toolkit MKL LAPACK and Intel oneAPI HPC toolkit SCALAPACK are used.
Do not try to build LAPACK and ScaLAPACK with oneAPI, the build will fail.

Build by:

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
