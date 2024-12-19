# MUMPS options

By default PORD ordering is used.
For large matrix systems,
[Scotch, METIS, parMETIS ordering](./Readme_ordering.md)
can be used for possible performance enhancements.

## Precision

The default precision is float64 and float32.

```cmake
option(BUILD_SINGLE "Build single precision real" ON)
option(BUILD_DOUBLE "Build double precision real" ON)
option(BUILD_COMPLEX "Build single precision complex")
option(BUILD_COMPLEX16 "Build double precision complex")
```

## Integer size

The default integer size is 32-bit.
64-bit integers can be enabled with:

```cmake
cmake -Dintsize64=on
```

HOWEVER, this requires all libraries INCLUDING MPI to be compiled with 64-bit integers.
Otherwise, the program will crash at runtime with MPI errors.
For example, oneAPI / oneMPI work, but default system installs of OpenMPI / MPICH will generally fail--the user will need to specially compile an MPI library with 64-bit integers.

## ScalaPACK

ScalaPACK is only used for `MUMPS_parallel=on`.
ScalaPACK can be omitted with MUMPS &ge; 5.7.0 by option:

```sh
cmake -DMUMPS_scalapack=off
```

## MPI

For systems where MPI, BLACS and SCALAPACK are not available, or where non-parallel execution is suitable, the default `MUMPS_parallel=true` can be disabled at CMake configure time by option:

```sh
cmake -DMUMPS_parallel=false
```

## MUMPS version selection

The MUMPS version defaults to a recent release.
For reproducibility, benchmarking and other purposes, one may select the version of MUMPS to build like:

```sh
cmake -B build -DMUMPS_UPSTREAM_VERSION=5.6.2
```

The MUMPS_UPSTREAM_VERSION works for MUMPS versions in
[cmake/libraries.json](./cmake/libraries.json).

## OpenMP

OpenMP can make MUMPS slower in certain situations.
Try with and without OpenMP to see which is faster for your situation.
Default is OpenMP OFF.

```sh
cmake -DMUMPS_openmp=on
```

---

[Matlab](./Readme_matlab.md) can use MUMPS library as well.
