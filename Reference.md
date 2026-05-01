# MUMPS Reference

There are "if defined" checks for symbols we've observed that aren't documented. We don't enable these definitions.

```
MTKO_ADVANCED
MTKO_ADVANCED_VERBOSE
MTKO_NO_MASK_FUSION
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
* `AVOID_MPI_IN_PLACE` to disable MPI_IN_PLACE (not set)
* `MUMPS_SCOTCHIMPORTOMPTHREADS` to import OpenMP threads into Scotch (enabled by CMake)

* `WORKAROUNDINTELILP64OPENMPLIMITATION` for OpenMP (not currently needed or set)
* `WORKAROUNDILP64MPICUSTOMREDUCE` was for IBM Platform MPI, which has been discontinued in favor of OpenMPI (obsolete)
* `WORKAROUNDINTELILP64MPI2INTEGER` we use this if MUMPS_intsize64=true

`MPI_TO_K_OMP` is for advanced use of OpenMP with MPI vis-a-vis `ICNTL(17)`. See User Manual section 5.23 for details.
We don't enable this.

* `metis`, `parmetis` for enablement of these graph partitioning libraries, handled by CMake options.
* `metis4`, `parmetis3` are obsolete, not used, and not supported by MUMPS 5.0+.
* `NOSCALAPACK` for the non-MPI case, handled by CMake.

These definitions are generic, well-known:

* `_OPENMP` is set by the compiler when OpenMP is enabled

## CUDA GPU MUMPS

MUMPS has experimental GPU support, with or without MPI and controlled by CMake option `MUMPS_gpu:BOOL`. This is not yet fully supported by CMake, but we set the `USE_GPU` definition when `MUMPS_gpu` is enabled. The MUMPS manual section 5.27 describes the GPU support in more detail.

* `USE_GPU` see MUMPS manual section 5.27 for details. We set this when MUMPS_gpu is enabled, which also adds CUDA::cublas and CUDA::cudart as dependencies.
* `GEMMT_AVAILABLE_FOR_GPU` is not yet handled by CMake.
* `USE_XKBLAS` is to use the external XKBLAS library for GPU-accelerated BLAS, which we don't yet handle in CMake.

## MUMPS Fortran modules

While
