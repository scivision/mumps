REM batch file since Github Actions doesn't support shell cmd well,
REM and cmd is needed for oneAPI Windows

call "C:\Program Files (x86)\Intel\oneAPI\setvars.bat"
if %errorlevel% neq 0 exit /b %errorlevel%

echo "MKLROOT: %MKLROOT%"
echo "I_MPI_ROOT: %I_MPI_ROOT%"

echo "configure %GITHUB_REPOSITORY%"
cmake -B build -DCMAKE_INSTALL_PREFIX=%RUNNER_TEMP%
if %errorlevel% neq 0 (
  type build\CMakeFiles\CMakeError.log & exit /b %errorlevel%
)

echo "build %GITHUB_REPOSITORY%"
cmake --build build --parallel
if %errorlevel% neq 0 exit /b %errorlevel%

echo "test %GITHUB_REPOSITORY%"
ctest --test-dir build --preset default -V
if %errorlevel% neq 0 exit /b %errorlevel%

echo "install project"
cmake --install build
if %errorlevel% neq 0 exit /b %errorlevel%

echo "Example config"
cmake -B example/build -S example -DCMAKE_PREFIX_PATH=%RUNNER_TEMP%
if %errorlevel% neq 0 exit /b %errorlevel%

echo "Example build"
cmake --build example/build
if %errorlevel% neq 0 exit /b %errorlevel%

echo "Example test"
ctest --test-dir example/build -V
if %errorlevel% neq 0 exit /b %errorlevel%
