option(find_static "Find static libraries for Lapack and Scalapack (default shared then static search)")

if(local)
  get_filename_component(local ${local} ABSOLUTE)

  if(NOT IS_DIRECTORY ${local})
    message(FATAL_ERROR "Local directory ${local} does not exist")
  endif()
endif()

if(MUMPS_UPSTREAM_VERSION VERSION_GREATER_EQUAL 5.2)
  option(gemmt "GEMMT is recommended in User Manual if available" ON)
endif()


option(parallel "parallel (use MPI)" ON)

option(intsize64 "use 64-bit integers in C and Fortran")

option(scotch "use Scotch orderings ")

option(parmetis "use parallel METIS ordering")
option(metis "use sequential METIS ordering")
if(parmetis AND NOT parallel)
  message(FATAL_ERROR "parmetis requires parallel=on")
endif()

option(openmp "use OpenMP")

option(matlab "Matlab interface" OFF)
if(matlab AND parallel)
  message(FATAL_ERROR "Matlab requires parallel=off")
endif()

option(find "find [SCA]LAPACK" on)

option(BUILD_SHARED_LIBS "Build shared libraries")

include(CheckPIESupported)
check_pie_supported()
set(CMAKE_POSITION_INDEPENDENT_CODE ON)

option(BUILD_SINGLE "Build single precision float32 real" ON)
option(BUILD_DOUBLE "Build double precision float64 real" ON)
option(BUILD_COMPLEX "Build single precision complex")
option(BUILD_COMPLEX16 "Build double precision complex")

# --- other options

option(CMAKE_TLS_VERIFY "Verify TLS certificates" ON)

set_property(DIRECTORY PROPERTY EP_UPDATE_DISCONNECTED true)

set(FETCHCONTENT_UPDATES_DISCONNECTED true)

if(CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
  set(CMAKE_INSTALL_PREFIX "${CMAKE_BINARY_DIR}/local" CACHE PATH "default install path" FORCE)
endif()
