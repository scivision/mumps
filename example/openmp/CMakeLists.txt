cmake_minimum_required(VERSION 3.21)

project(MUMPSopenmpExamples
LANGUAGES C Fortran
)

enable_testing()

if(DEFINED ENV{CONDA_PREFIX})
  list(APPEND CMAKE_IGNORE_PREFIX_PATH $ENV{CONDA_PREFIX})
  list(APPEND CMAKE_IGNORE_PATH $ENV{CONDA_PREFIX}/bin)
  # need CMAKE_IGNORE_PATH for CMake < 3.23 and to ensure system env var PATH doesn't interfere
  # despite CMAKE_IGNORE_PREFIX_PATH
endif()

if(PROJECT_IS_TOP_LEVEL)
  find_package(MUMPS CONFIG REQUIRED)
endif()

add_executable(test_mumps_openmp mumps_openmp_example.f90)
target_link_libraries(test_mumps_openmp PRIVATE MUMPS::MUMPS
MPI::MPI_Fortran MPI::MPI_C
OpenMP::OpenMP_Fortran
)
# always link MPI as we use the libmpiseq if not MUMPS_parallel

add_test(NAME MUMPSopenMP COMMAND test_mumps_openmp)
set_tests_properties(MUMPSopenMP PROPERTIES
LABELS "OpenMP"
ENVIRONMENT OMP_NUM_THREADS=4
)

file(GENERATE OUTPUT .gitignore CONTENT "*")
