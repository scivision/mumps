# MUMPS Reference

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
* `WORKAROUNDINTELILP64MPI2INTEGER` we use this if MUMPS_intsize64=true
