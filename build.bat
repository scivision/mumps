@REM helper script to build Windows Intel oneAPI

@REM don't have to use oneAPI, but it's recommended for performance and ease of build
set use_oneapi=1

@REM Don't have to use Ninja, but it's a lot faster and more reliable
if not defined CMAKE_GENERATOR (
  set CMAKE_GENERATOR=Ninja
)

if %use_oneapi%==1 (

REM Check if Intel oneAPI compilers are already set, if not source setvars.bat
if not defined CMPLR_ROOT (
  if exist "%ProgramFiles(x86)%\Intel\oneAPI\setvars.bat" (
    call "%ProgramFiles(x86)%\Intel\oneAPI\setvars.bat"
  ) else (
    echo Intel oneAPI not found, halting. Try using the Intel oneAPI command prompt.
    exit /b 1
  )
)

)

where cmake
if %errorlevel% neq 0 (
  winget install Kitware.CMake
)

if %CMAKE_GENERATOR%==Ninja (
  where ninja
  if %errorlevel% neq 0 (
    winget install Ninja-build.ninja
  )
)

@REM where MUMPS is built
set bindir=%~dp0\build-oneapi

REM where to install MUMPS
set install_prefix=%bindir%\mumps-oneapi-install

REM use OpenMP?
set openmp=1

REM use MPI?
set parallel=1

REM use Scotch?
set scotch=0

cmake -S%~dp0 -B%bindir% %opts% ^
  --install-prefix=%install_prefix% ^
  -DMUMPS_openmp=%openmp% ^
  -DMUMPS_parallel=%parallel% ^
  -DMUMPS_scotch=%scotch%

cmake --build %bindir%

REM optional install
cmake --install %bindir%

REM optional self-test
ctest --test-dir %bindir%
