include(GNUInstallDirs)

message(STATUS "${PROJECT_NAME} ${PROJECT_VERSION}  CMake ${CMAKE_VERSION}  Toolchain ${CMAKE_TOOLCHAIN_FILE}")

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
option(octave "GNU Octave interface" OFF)
if((matlab OR octave) AND parallel)
  message(FATAL_ERROR "Matlab / Octave requires parallel=off")
endif()

option(BUILD_SHARED_LIBS "Build shared libraries")

set(CMAKE_POSITION_INDEPENDENT_CODE ON)


option(BUILD_SINGLE "Build single precision float32 real" ON)
option(BUILD_DOUBLE "Build double precision float64 real" ON)
option(BUILD_COMPLEX "Build single precision complex")
option(BUILD_COMPLEX16 "Build double precision complex")

# --- other options


set(CMAKE_TLS_VERIFY true)

set(FETCHCONTENT_UPDATES_DISCONNECTED true)
