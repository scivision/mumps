if(CMAKE_VERSION VERSION_LESS 3.21)
  get_property(not_top DIRECTORY PROPERTY PARENT_DIRECTORY)
  if(not_top)
    set(${PROJECT_NAME}_IS_TOP_LEVEL false)
  else()
    set(${PROJECT_NAME}_IS_TOP_LEVEL true)
  endif()
endif()

option(${PROJECT_NAME}_BUILD_TESTING "Build tests" ${${PROJECT_NAME}_IS_TOP_LEVEL})

option(find_static "Find static libraries for Lapack and Scalapack (default shared then static search)")

if(MUMPS_UPSTREAM_VERSION VERSION_GREATER_EQUAL 5.2)
  option(gemmt "GEMMT is recommended in User Manual if available" ON)
endif()

option(parallel "parallel (use MPI)" ON)

option(intsize64 "use 64-bit integers in C and Fortran")

option(scalapack "Use ScalaPACK to speed up the solution of linear systems" ON)
if(MUMPS_UPSTREAM_VERSION VERSION_LESS 5.7 AND NOT scalapack)
  message(FATAL_ERROR "MUMPS version < 5.7 requires scalapack=on")
endif()

option(scotch "use Scotch orderings")

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

# this is for convenience of those needing scalapaack, lapack built
if(${${PROJECT_NAME}_IS_TOP_LEVEL} AND CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
  set_property(CACHE CMAKE_INSTALL_PREFIX PROPERTY VALUE "${PROJECT_BINARY_DIR}/local")
endif()
