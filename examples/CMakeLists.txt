cmake_minimum_required(VERSION 3.19...3.22)

project(MUMPSExamples
LANGUAGES C Fortran
)

enable_testing()

list(APPEND CMAKE_MODULE_PATH ${PROJECT_SOURCE_DIR}/../cmake/Modules)

set(MUMPS_UPSTREAM_VERSION 5.3.5)
set(arith s d)
option(parallel "use MPI" true)
set(autobuild true)
set(FETCHCONTENT_UPDATES_DISCONNECTED_MUMPS true)
set_directory_properties(PROPERTIES EP_UPDATE_DISCONNECTED true)

if(CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
  set(CMAKE_INSTALL_PREFIX ${CMAKE_BINARY_DIR} CACHE PATH "Install top-level directory" FORCE)
endif()

if(parallel)
  find_package(MPI COMPONENTS C Fortran REQUIRED)
  find_package(SCALAPACK REQUIRED)
endif()

find_package(LAPACK REQUIRED)

if(NOT MUMPS_FOUND)
  include(${PROJECT_SOURCE_DIR}/../cmake/mumps.cmake)
endif()

set(mumps_SOURCE_DIR ${PROJECT_SOURCE_DIR}/../cache/MUMPS-${MUMPS_UPSTREAM_VERSION}-src)
set(mumps_BINARY_DIR ${PROJECT_BINARY_DIR}/_deps/mumps-build/)

configure_file(CMakeLists.cmake ${mumps_SOURCE_DIR}/examples/CMakeLists.txt COPYONLY)

add_subdirectory(${mumps_SOURCE_DIR}/examples ${mumps_BINARY_DIR}/examples)
