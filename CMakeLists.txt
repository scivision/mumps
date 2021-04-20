# Use FetchContent to avoid directly distributing huge MUMPS source,
# which would slow down clone of this repo

cmake_minimum_required(VERSION 3.13...3.20)

project(MUMPS5
LANGUAGES C Fortran
DESCRIPTION "Sparse direct parallel solver"
HOMEPAGE_URL "http://mumps-solver.org/")

include(CTest)
include(FetchContent)

if(NOT DEFINED ${PROJECT_NAME}_BUILD_TESTING)
  set(${PROJECT_NAME}_BUILD_TESTING ${BUILD_TESTING})
endif()

# --- user options
include(cmake/options.cmake)
include(cmake/libraries.cmake)

include(cmake/get_mumps.cmake)

configure_file(PORD/CMakeLists.txt ${mumps_SOURCE_DIR}/PORD/ COPYONLY)
configure_file(PORD/lib/CMakeLists.txt ${mumps_SOURCE_DIR}/PORD/lib/ COPYONLY)
add_subdirectory(${mumps_SOURCE_DIR}/PORD ${mumps_BINARY_DIR}/PORD)
