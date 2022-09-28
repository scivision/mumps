cmake_minimum_required(VERSION 3.13...3.25)

get_property(is_multi_config GLOBAL PROPERTY GENERATOR_IS_MULTI_CONFIG)
if(NOT is_multi_config AND NOT (CMAKE_BUILD_TYPE OR DEFINED ENV{CMAKE_BUILD_TYPE}))
  set(CMAKE_BUILD_TYPE Release CACHE STRING "Release default")
endif()

project(MUMPS
LANGUAGES C Fortran
VERSION 5.5.1.7
DESCRIPTION "Sparse direct parallel solver"
HOMEPAGE_URL "http://mumps-solver.org/"
)

enable_testing()
if(DEFINED BUILD_TESTING)
  set(${PROJECT_NAME}_BUILD_TESTING ${BUILD_TESTING})
else()
  set(${PROJECT_NAME}_BUILD_TESTING true)
endif()

if(NOT MUMPS_UPSTREAM_VERSION)
  set(MUMPS_UPSTREAM_VERSION 5.5.1)
endif()

if(MSVC AND BUILD_SHARED_LIBS)
  message(WARNING "MUMPS: Windows Intel/IntelLLVM compilers with **shared** libraries is not supported and will probably fail.
  Recommend using static libraries, which does work:
  cmake -DBUILD_SHARED_LIBS=off")
endif()

# --- user options
include(cmake/options.cmake)
include(cmake/compilers.cmake)

# --- dependencies
find_package(Threads)

include(cmake/lapack.cmake)

# -- Scalapack / MPI

if(parallel)
  find_package(MPI COMPONENTS C Fortran REQUIRED)
  include(cmake/scalapack.cmake)

  set(NUMERIC_LIBS ${SCALAPACK_LIBRARIES} ${LAPACK_LIBRARIES})

  if(find_static AND NOT WIN32 AND
    MKL IN_LIST LAPACK_COMPONENTS AND
    CMAKE_VERSION VERSION_GREATER_EQUAL 3.24
    )
    set(NUMERIC_LIBS $<LINK_GROUP:RESCAN,${NUMERIC_LIBS}>)
  endif()

  # avoid MPICH -fallow flag leakage
  set(NUMERIC_INC ${SCALAPACK_INCLUDE_DIRS} ${LAPACK_INCLUDE_DIRS} ${MPI_Fortran_INCLUDE_DIRS})
  list(APPEND NUMERIC_LIBS ${MPI_Fortran_LIBRARIES} MPI::MPI_C)

  if(openmp)
    find_package(OpenMP COMPONENTS C Fortran REQUIRED)
    list(APPEND NUMERIC_LIBS OpenMP::OpenMP_Fortran OpenMP::OpenMP_C)
  endif()
endif()

# --- ordering libs

set(ORDERING_LIBS)
set(ORDERING_DEFS pord)
if(scotch)
  find_package(Scotch COMPONENTS ESMUMPS REQUIRED)
  list(APPEND ORDERING_DEFS scotch)
  list(APPEND ORDERING_LIBS Scotch::Scotch)
  # Scotch and METIS go together
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

# --- download MUMPS source
include(cmake/mumps_src.cmake)

# --- MUMPS build

if(NOT parallel)
  configure_file(libseq/CMakeLists.txt ${mumps_SOURCE_DIR}/libseq/ COPYONLY)
  add_subdirectory(${mumps_SOURCE_DIR}/libseq ${mumps_BINARY_DIR}/libseq)
  set(NUMERIC_LIBS mpiseq LAPACK::LAPACK)
endif()

list(APPEND NUMERIC_LIBS ${CMAKE_THREAD_LIBS_INIT})


configure_file(pord/lib/CMakeLists.txt ${mumps_SOURCE_DIR}/PORD/lib/ COPYONLY)
add_subdirectory(${mumps_SOURCE_DIR}/PORD/lib ${mumps_BINARY_DIR}/pord/lib)

configure_file(src/CMakeLists.txt ${mumps_SOURCE_DIR}/src/ COPYONLY)
add_subdirectory(${mumps_SOURCE_DIR}/src ${mumps_BINARY_DIR}/src)

if(matlab OR octave)
  configure_file(matlab/CMakeLists.txt ${mumps_SOURCE_DIR}/MATLAB/ COPYONLY)
  add_subdirectory(${mumps_SOURCE_DIR}/MATLAB ${mumps_BINARY_DIR}/matlab)
endif()


if(${PROJECT_NAME}_BUILD_TESTING)
  add_subdirectory(test)
endif()


# --- feature summary

message(STATUS "Configured MUMPS ${MUMPS_UPSTREAM_VERSION} source in ${mumps_SOURCE_DIR}")

include(cmake/summary.cmake)

include(cmake/install.cmake)
