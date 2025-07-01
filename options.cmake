option(MUMPS_BUILD_TESTING "Build tests" ${MUMPS_IS_TOP_LEVEL})

option(MUMPS_find_static "Find static libraries for Lapack and Scalapack (default shared then static search)")


if(MUMPS_url)
  if(EXISTS ${MUMPS_url})
    get_filename_component(MUMPS_url ${MUMPS_url} ABSOLUTE)
  endif()
else()
  if(NOT DEFINED MUMPS_UPSTREAM_VERSION)
    set(MUMPS_UPSTREAM_VERSION 5.8.0)
  endif()

  set(MUMPS_url "https://mumps-solver.org/MUMPS_${MUMPS_UPSTREAM_VERSION}.tar.gz")
endif()

if(MUMPS_UPSTREAM_VERSION VERSION_GREATER_EQUAL 5.2)
  option(gemmt "GEMMT is recommended in User Manual if available" ON)
endif()

option(MUMPS_parallel "parallel (use MPI)" ON)

option(MUMPS_intsize64 "use 64-bit integers in C and Fortran")

option(MUMPS_scalapack "Use ScalaPACK to speed up the solution of linear systems" ON)
if(MUMPS_UPSTREAM_VERSION AND MUMPS_UPSTREAM_VERSION VERSION_LESS 5.7 AND NOT MUMPS_scalapack)
  message(FATAL_ERROR "MUMPS version < 5.7 requires MUMPS_scalapack=on")
endif()

option(MUMPS_scotch "use Scotch orderings")

option(MUMPS_parmetis "use parallel METIS ordering")
option(MUMPS_metis "use sequential METIS ordering")
if(MUMPS_parmetis AND NOT MUMPS_parallel)
  message(FATAL_ERROR "parmetis requires MUMPS_parallel=on")
endif()

option(MUMPS_openmp "use OpenMP")

option(MUMPS_matlab "Matlab interface" OFF)
if(MUMPS_matlab AND MUMPS_parallel)
  message(FATAL_ERROR "Matlab requires -DMUMPS_parallel=off")
endif()

option(MUMPS_find_SCALAPACK "find ScaLAPACK" on)

option(BUILD_SHARED_LIBS "Build shared libraries")

# fPIC flags are specified by MUMPS INSTALL file, so we do the same in CMake
include(CheckPIESupported)
check_pie_supported()
set(CMAKE_POSITION_INDEPENDENT_CODE ON)

option(BUILD_SINGLE "Build single precision float32 real" ON)
option(BUILD_DOUBLE "Build double precision float64 real" ON)
option(BUILD_COMPLEX "Build single precision complex")
option(BUILD_COMPLEX16 "Build double precision complex")

# --- other options

set_property(DIRECTORY PROPERTY EP_UPDATE_DISCONNECTED true)

set(FETCHCONTENT_UPDATES_DISCONNECTED true)

# this is for convenience of those needing scalapaack, lapack built
if(MUMPS_IS_TOP_LEVEL AND CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
  set_property(CACHE CMAKE_INSTALL_PREFIX PROPERTY VALUE "${PROJECT_BINARY_DIR}/local")
endif()
