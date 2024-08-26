# MUMPS ordering

To use Scotch (requires MUMPS >= 5.0 and Scotch built with libesmumps):

```sh
cmake -Dscotch=yes
```

To use METIS:

```sh
cmake -Dmetis=yes
```

To use parMETIS (metis option is ignored (overridden) by parmetis=yes):

```sh
cmake -Dparmetis=yes
```

The path to METIS and Scotch can be specified via variables METIS_ROOT and Scotch_ROOT, respectively.

## Build METIS

Optionally, METIS can be built from source via CMake before MUMPS.
NOTE: the "-Dintsize64" must be the same for METIS and MUMPS -- default is "off" for METIS and MUMPS.

```sh
cmake -Dprefix=~/mumps -P scripts/build_metis.cmake
```

Build MUMPS

```sh
cmake -Bbuild -DMETIS_ROOT=~/mumps -Dmetis=on

cmake --build build
```

## Build Scotch

Optionally, Scotch can be built from source via CMake before MUMPS.
NOTE: the "-Dintsize64" must be the same for Scotch and MUMPS -- default is "off" for Scotch and MUMPS.

```sh
cmake -Dprefix=~/mumps -P scripts/build_scotch.cmake
```

Build MUMPS

```sh
cmake -Bbuild -DMETIS_ROOT=~/mumps -DScotch_ROOT=~/mumps -Dscotch=on

cmake --build build
```

Build MUMPS example:

```sh
cmake -S example -B example/build -Dscotch=on
cmake --build example/build
```

---

If 64-bit integers are needed, use:

```sh
cmake -Dintsize64=true
```
