# MUMPS options

By default PORD ordering is used.
For large matrix systems,
[Scotch and METIS ordering](./Readme_ordering.md)
can be used for possible performance enhancements.

## Precision

The default precision is float64 and float32.

```cmake
option(BUILD_SINGLE "Build single precision real" ON)
option(BUILD_DOUBLE "Build double precision real" ON)
option(BUILD_COMPLEX "Build single precision complex")
option(BUILD_COMPLEX16 "Build double precision complex")
```

## MPI

For systems where MPI, BLACS and SCALAPACK are not available, or where non-parallel execution is suitable, the default parallel can be disabled at CMake configure time by option:

```sh
cmake -Dparallel=false
```

## MUMPS version selection

The MUMPS version defaults to a recent release.
For reproducibility, benchmarking and other purposes, one may select the version of MUMPS to build like:

```sh
cmake -B build -DMUMPS_UPSTREAM_VERSION=5.6.1
```

The MUMPS_UPSTREAM_VERSION works for MUMPS versions in
[cmake/libraries.json](./cmake/libraries.json).

## LAPACK options

The underlying "LAPACK" interface is available from several different libraries.
By default, CMake for MUMPS searchs for Intel MKL if environment variables MKLROOT is set.
Otherwise, the generic LAPACK library "lapack" is searched for.

To specify a different LAPACK library, use CMake configure variable "LAPACK_VENDOR" using one of the following vendors:

* AOCL  [AMD Optimizing CPU Libraries](https://www.amd.com/en/developer/aocl.html)
* Atlas [Automatically Tuned Linear Algebra Software](http://math-atlas.sourceforge.net/)
* MKL  [Intel oneMKL](https://www.intel.com/content/www/us/en/developer/tools/oneapi/onemkl.html)
* Netlib [Netlib LAPACK](http://www.netlib.org/lapack/)  (default)
* OpenBLAS [OpenBLAS](https://www.openblas.net/)

For example, to use OpenBLAS:

```sh
cmake -DLAPACK_VENDOR=OpenBLAS
```

Optionally, hint the location the LAPACK library like:

```sh
cmake -DLAPACK_ROOT=/path/to/lapack
```

### GEMMT symmetric matrix-matrix multiplication

For MUMPS &ge; 5.2.0, GEMMT symmetric matrix-matrix multiplication is recommended by the MUMPS User Guide if available.
By default GEMMT is ON, but may be disabled like:

```sh
cmake -Dgemmt=off
```

## Matlab / GNU Octave

Matlab / GNU Octave MEX interface may be built (one or the other) by EITHER:

```sh
-Dmatlab=on
-Doctave=on
```

These require `-Dparallel=off`.
These Matlab scripts seems to have been developed ~ 2006 and may not fully work anymore.
Ask the MUMPS Users List if you need such scripts.
We present them mainly as an example of compiling MEX libraries for Octave and Matlab with CMake.

## OpenMP

OpenMP can make MUMPS slower in certain situations.
Try with and without OpenMP to see which is faster for your situation.
Default is OpenMP OFF.

```sh
cmake -Dopenmp=true
```
