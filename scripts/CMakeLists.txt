cmake_minimum_required(VERSION 3.20...3.24)
# at least 3.24 to suppress CMP0135 warning

if(CMAKE_SOURCE_DIR STREQUAL CMAKE_BINARY_DIR)
  message(FATAL_ERROR "please use out of source build
    cmake -Bbuild")
endif()

project(MumpsPrereqs LANGUAGES C Fortran)

include(ExternalProject)

get_filename_component(CMAKE_INSTALL_PREFIX ${CMAKE_INSTALL_PREFIX} ABSOLUTE)

file(MAKE_DIRECTORY ${CMAKE_INSTALL_PREFIX})
message(STATUS "Installing MUMPS prerequisites to ${CMAKE_INSTALL_PREFIX}")

option(BUILD_SINGLE "Build single precision real" ON)
option(BUILD_DOUBLE "Build double precision real" ON)
option(BUILD_COMPLEX "Build single precision complex")
option(BUILD_COMPLEX16 "Build double precision complex")
option(MUMPS_intsize64 "use 64-bit integers in C and Fortran--Scotch must be consistent with MUMPS")

set_property(DIRECTORY PROPERTY EP_UPDATE_DISCONNECTED true)

file(READ ${CMAKE_CURRENT_SOURCE_DIR}/../cmake/libraries.json json)

# default args
set(cmake_args
-DCMAKE_INSTALL_PREFIX:PATH=${CMAKE_INSTALL_PREFIX}
-DCMAKE_PREFIX_PATH:PATH=${CMAKE_INSTALL_PREFIX}
-DBUILD_SHARED_LIBS:BOOL=${BUILD_SHARED_LIBS}
-DCMAKE_BUILD_TYPE=Release
)

# Scalapack
set(scalapack_cmake_args ${cmake_args}
-DBUILD_SINGLE:BOOL=${BUILD_SINGLE}
-DBUILD_DOUBLE:BOOL=${BUILD_DOUBLE}
-DBUILD_COMPLEX:BOOL=${BUILD_COMPLEX}
-DBUILD_COMPLEX16:BOOL=${BUILD_COMPLEX16}
-DSCALAPACK_BUILD_TESTING:BOOL=false
)

string(JSON scalapack_url GET ${json} scalapack url)
string(JSON scalapack_sha256 GET ${json} scalapack sha256)

ExternalProject_Add(scalapack
URL ${scalapack_url}
URL_HASH SHA256=${scalapack_sha256}
CMAKE_ARGS ${scalapack_cmake_args}
CONFIGURE_HANDLED_BY_BUILD true
)

# Scotch

include(${CMAKE_CURRENT_SOURCE_DIR}/../cmake/scotch.cmake)

# ignore build dir

file(GENERATE OUTPUT .gitignore CONTENT "*")
