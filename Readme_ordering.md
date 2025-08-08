# MUMPS ordering

To use Scotch, METIS, and/or ParMETIS:

```sh
cmake -DMUMPS_scotch=yes
```

```sh
cmake -DMUMPS_metis=yes
```

```sh
cmake -DMUMPS_parmetis=yes
```

Build MUMPS

```sh
cmake --build build
cmake --install build
```

Build MUMPS example:

```sh
cmake -S example -B example/build -DMUMPS_ROOT=build/local

cmake --build example/build
```

---

If 64-bit integers are needed, use:

```sh
cmake -DMUMPS_intsize64=true
```
