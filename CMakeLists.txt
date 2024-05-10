cmake_minimum_required(VERSION 3.19...3.30)

if(CMAKE_SOURCE_DIR STREQUAL CMAKE_BINARY_DIR)
  message(FATAL_ERROR "Please use out of source build:
  cmake -B build")
endif()

get_property(is_multi_config GLOBAL PROPERTY GENERATOR_IS_MULTI_CONFIG)
if(NOT is_multi_config AND NOT (CMAKE_BUILD_TYPE OR DEFINED ENV{CMAKE_BUILD_TYPE}))
  set(CMAKE_BUILD_TYPE Release CACHE STRING "Release default")
endif()

project(MUMPS
LANGUAGES C Fortran
VERSION 5.7.1.0
DESCRIPTION "Sparse direct parallel solver"
HOMEPAGE_URL "http://mumps-solver.org/"
)

enable_testing()

if(NOT MUMPS_UPSTREAM_VERSION)
  set(MUMPS_UPSTREAM_VERSION 5.7.1)
endif()

if(MSVC AND BUILD_SHARED_LIBS)
  message(WARNING "MUMPS: Windows Intel/IntelLLVM compilers with **shared** libraries is not supported and will probably fail.
  Recommend using static libraries, which does work:
  cmake -DBUILD_SHARED_LIBS=off")
endif()

# --- user options
include(options.cmake)
include(cmake/compilers.cmake)

message(STATUS "${PROJECT_NAME} ${PROJECT_VERSION} upstream ${MUMPS_UPSTREAM_VERSION} install prefix: ${CMAKE_INSTALL_PREFIX}")
message(STATUS "CMake ${CMAKE_VERSION}  Toolchain ${CMAKE_TOOLCHAIN_FILE}")

# --- dependencies
find_package(Threads)

# -- Scalapack / MPI

if(parallel)
  find_package(MPI COMPONENTS C Fortran REQUIRED)
  if(NOT DEFINED ENV{MKLROOT} OR NOT scalapack)
    # oneMKL MKLConfig.cmake must be invoked only once
    include(cmake/lapack.cmake)
  endif()
  set(NUMERIC_LIBS LAPACK::LAPACK)

  if(scalapack)
    include(cmake/scalapack.cmake) # this will also create the LAPACK::LAPACK target
    list(PREPEND NUMERIC_LIBS SCALAPACK::SCALAPACK)
  endif()

  # avoid MPICH -fallow flag leakage
  set(NUMERIC_INC ${MPI_Fortran_INCLUDE_DIRS})
  list(APPEND NUMERIC_LIBS ${MPI_Fortran_LIBRARIES} MPI::MPI_C)

  if(openmp)
    find_package(OpenMP COMPONENTS C Fortran REQUIRED)
    list(APPEND NUMERIC_LIBS OpenMP::OpenMP_Fortran OpenMP::OpenMP_C)
  endif()
else()
  include(cmake/lapack.cmake)
endif()

# GEMMT is recommeded in MUMPS User Manual if available
if(gemmt)
  include(cmake/gemmt.cmake)
endif()

# --- ordering libs

set(ORDERING_LIBS)
set(ORDERING_DEFS pord)

if(scotch)
  find_package(Scotch COMPONENTS ESMUMPS REQUIRED)
  list(APPEND ORDERING_DEFS scotch)
  list(APPEND ORDERING_LIBS Scotch::Scotch)
endif()

if(parmetis)
  find_package(METIS REQUIRED COMPONENTS ParMETIS)
  list(APPEND ORDERING_DEFS parmetis metis)
  list(APPEND ORDERING_LIBS METIS::METIS)
elseif(metis)
  find_package(METIS REQUIRED)
  list(APPEND ORDERING_DEFS metis)
  list(APPEND ORDERING_LIBS METIS::METIS)
endif()

list(APPEND ORDERING_LIBS pord)

install(FILES
${CMAKE_CURRENT_SOURCE_DIR}/cmake/FindLAPACK.cmake
${CMAKE_CURRENT_SOURCE_DIR}/cmake/FindSCALAPACK.cmake
${CMAKE_CURRENT_SOURCE_DIR}/cmake/FindMETIS.cmake
${CMAKE_CURRENT_SOURCE_DIR}/cmake/FindScotch.cmake
${CMAKE_CURRENT_SOURCE_DIR}/cmake/FindMUMPS.cmake
DESTINATION cmake
)

message(STATUS "MUMPS ORDERING_DEFS: ${ORDERING_DEFS}")
message(STATUS "MUMPS ORDERING_LIBS: ${ORDERING_LIBS}")

# --- download MUMPS source
include(FetchContent)

set(url "https://mumps-solver.org/MUMPS_${MUMPS_UPSTREAM_VERSION}.tar.gz")

set(FETCHCONTENT_QUIET no)

FetchContent_Declare(${PROJECT_NAME}
SOURCE_DIR ${PROJECT_SOURCE_DIR}/mumps/${MUMPS_UPSTREAM_VERSION}
URL ${url}
TLS_VERIFY ${CMAKE_TLS_VERIFY}
)

FetchContent_GetProperties(${PROJECT_NAME})
if(NOT ${PROJECT_NAME}_POPULATED)
  FetchContent_Populate(${PROJECT_NAME})
endif()

message(VERBOSE "MUMPS ${MUMPS_UPSTREAM_VERSION} source directory: ${mumps_SOURCE_DIR}")

# --- MUMPS build

# --- mpiseq (No MPI)
if(NOT parallel)
  set(NUMERIC_LIBS LAPACK::LAPACK)
  include(cmake/libseq.cmake)
endif()

list(APPEND NUMERIC_LIBS ${CMAKE_THREAD_LIBS_INIT})

# --- PORD (always used)
include(cmake/pord.cmake)

# --- MUMPS itself
include(cmake/mumps.cmake)

if(matlab)
  include(cmake/matlab.cmake)
endif()


if(${PROJECT_NAME}_BUILD_TESTING)
  add_subdirectory(test)
endif()


# --- feature summary

message(STATUS "Configured MUMPS ${MUMPS_UPSTREAM_VERSION} source in ${mumps_SOURCE_DIR}")

include(cmake/summary.cmake)

include(cmake/install.cmake)

file(GENERATE OUTPUT .gitignore CONTENT "*")
