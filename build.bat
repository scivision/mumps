@echo off
setlocal enabledelayedexpansion

@REM helper script to build on Windows

@REM where MUMPS is built
set bindir=%~dp0\build-oneapi

REM where to install MUMPS
set install_prefix=%bindir%\local

REM use OpenMP?
set openmp=1

REM use MPI?
set parallel=1

REM use Scotch?
set scotch=1

@REM Don't have to use Ninja, but it's a lot faster and more reliable
if not defined CMAKE_GENERATOR (
  set CMAKE_GENERATOR=Ninja
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


cmake -S%~dp0 -B%bindir% %opts% ^
  --install-prefix=%install_prefix% ^
  -DMUMPS_openmp:BOOL=%openmp% ^
  -DMUMPS_parallel:BOOL=%parallel% ^
  -DMUMPS_scotch:BOOL=%scotch%

if !errorlevel! neq 0 (
  echo cmake configuration failed, halting.
  exit /b 1
)

cmake --build %bindir%

if !errorlevel! neq 0 (
  echo cmake build failed, halting.
  exit /b 1
)

REM optional install
cmake --install %bindir%

if !errorlevel! neq 0 (
  echo cmake install failed, halting.
  exit /b 1
)

REM optional self-test
ctest --test-dir %bindir%
