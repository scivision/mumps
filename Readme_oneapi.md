# Intel oneAPI

We require
[oneMKL >= 2021.3](https://www.intel.com/content/www/us/en/docs/onemkl/developer-guide-linux/2023-2/cmake-config-for-onemkl.html).

Do not try to build LAPACK and ScaLAPACK with oneAPI, the build will fail--use the oneMKL libraries that provide LAPACK and SCALAPACK.

## Linux

Use the oneAPI
[setvars.sh](https://www.intel.com/content/www/us/en/docs/oneapi/programming-guide/2024-1/use-the-setvars-and-oneapi-vars-scripts-with-linux.html)
or "oneapi-vars.sh" to enable oneAPI.

If the oneAPI compiler is not found by CMake, try hinting its location like:

```sh
export CC=$CMPLR_ROOT/bin/icx
export FC=$CMPLR_ROOT/bin/ifx

cmake -B build
```

## Windows

Be sure to use the oneAPI command prompt.
Under Windows Start menu look for "Intel oneAPI command prompt for Intel 64 for Visual Studio".
Alternatively, use the oneAPI
[setvars.bat](https://www.intel.com/content/www/us/en/docs/oneapi/programming-guide/2024-1/use-the-setvars-script-with-windows.html)
or "oneapi-vars.bat".

If the oneAPI compiler is not found by CMake, try hinting its location like (do not enclose with quotes):

```sh
set CC=%CMPLR_ROOT%/bin/icx.exe
set FC=%CMPLR_ROOT%/bin/ifx.exe

cmake -G Ninja -B build
```

If Visual Studio generator is desired do like:

```sh
cmake -Bbuild -G "Visual Studio 17 2022" -T fortran=ifx
```

In any case, build like:

```sh
cmake --build build --config Release
```

Optionally, test:

```sh
ctest --test-dir build -C Release -V
```
