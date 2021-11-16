cmake_minimum_required(VERSION 3.20...3.22)

get_property(is_multi_config GLOBAL PROPERTY GENERATOR_IS_MULTI_CONFIG)
if(NOT is_multi_config AND NOT (CMAKE_BUILD_TYPE OR DEFINED ENV{CMAKE_BUILD_TYPE}))
  set(CMAKE_BUILD_TYPE Release CACHE STRING "Release default")
endif()

file(READ ${CMAKE_CURRENT_LIST_DIR}/codemeta.json _j)
string(JSON PROJECT_VERSION GET ${_j} version)

project(MUMPS
LANGUAGES C Fortran
VERSION ${PROJECT_VERSION}
DESCRIPTION "Sparse direct parallel solver"
HOMEPAGE_URL "http://mumps-solver.org/"
)

include(CTest)

if(NOT MUMPS_UPSTREAM_VERSION)
  set(MUMPS_UPSTREAM_VERSION 5.4.1)
endif()

if(CMAKE_GENERATOR STREQUAL "Ninja Multi-Config")
  set(EXTPROJ_GENERATOR "Ninja")
else()
  set(EXTPROJ_GENERATOR ${CMAKE_GENERATOR})
endif()

if(MSVC AND BUILD_SHARED_LIBS)
  message(WARNING "MUMPS: Windows MSVC/Intel compilers with **shared** libraries is not supported and will probably fail.
  Recommend using static libraries, which does work:
  cmake -DBUILD_SHARED_LIBS=off")
endif()

set(CMAKE_WINDOWS_EXPORT_ALL_SYMBOLS true)

# --- user options
include(cmake/options.cmake)
include(cmake/libraries.cmake)

# --- compiler setup
list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/cmake/Modules)

include(cmake/compilers.cmake)

# --- download MUMPS
include(cmake/get_mumps.cmake)

# --- dependencies
find_package(Threads)

include(cmake/lapack.cmake)

# -- Scalapack / MPI

if(parallel)
  find_package(MPI COMPONENTS C Fortran REQUIRED)
  include(cmake/scalapack.cmake)

  set(NUMERIC_LIBS SCALAPACK::SCALAPACK LAPACK::LAPACK MPI::MPI_Fortran MPI::MPI_C)
  if(openmp)
    find_package(OpenMP COMPONENTS C Fortran REQUIRED)
    list(APPEND NUMERIC_LIBS OpenMP::OpenMP_Fortran OpenMP::OpenMP_C)
  endif()
else(parallel)
  configure_file(libseq/CMakeLists.txt ${mumps_SOURCE_DIR}/libseq/ COPYONLY)
  add_subdirectory(${mumps_SOURCE_DIR}/libseq ${mumps_BINARY_DIR}/libseq)
  set(NUMERIC_LIBS mpiseq)
endif(parallel)
list(APPEND NUMERIC_LIBS LAPACK::LAPACK ${CMAKE_THREAD_LIBS_INIT})

# --- ordering libs

set(ORDERING_LIBS)
set(ORDERING_FLAGS -Dpord)
if(scotch)
  find_package(Scotch COMPONENTS ESMUMPS REQUIRED)
  list(APPEND ORDERING_FLAGS -Dscotch)
  list(APPEND ORDERING_LIBS Scotch::Scotch)
  # Scotch and METIS go together
  find_package(METIS REQUIRED)
  list(APPEND ORDERING_FLAGS -Dmetis)
  list(APPEND ORDERING_LIBS METIS::METIS)
endif()
list(APPEND ORDERING_LIBS pord)

install(FILES
${CMAKE_CURRENT_SOURCE_DIR}/cmake/Modules/FindLAPACK.cmake
${CMAKE_CURRENT_SOURCE_DIR}/cmake/Modules/FindSCALAPACK.cmake
${CMAKE_CURRENT_SOURCE_DIR}/cmake/Modules/FindMETIS.cmake
${CMAKE_CURRENT_SOURCE_DIR}/cmake/Modules/FindScotch.cmake
${CMAKE_CURRENT_SOURCE_DIR}/cmake/Modules/FindMUMPS.cmake
DESTINATION cmake
)


# --- MUMPS build

configure_file(PORD/lib/CMakeLists.txt ${mumps_SOURCE_DIR}/PORD/lib/ COPYONLY)
add_subdirectory(${mumps_SOURCE_DIR}/PORD/lib ${mumps_BINARY_DIR}/PORD/lib)

configure_file(src/CMakeLists.txt ${mumps_SOURCE_DIR}/src/ COPYONLY)
add_subdirectory(${mumps_SOURCE_DIR}/src ${mumps_BINARY_DIR}/src)


if(BUILD_TESTING)
  add_subdirectory(tests)

  configure_file(examples/CMakeLists.txt ${mumps_SOURCE_DIR}/examples/ COPYONLY)
  add_subdirectory(${mumps_SOURCE_DIR}/examples ${mumps_BINARY_DIR}/examples)
endif()


# --- feature summary

include(cmake/summary.cmake)

include(cmake/install.cmake)
