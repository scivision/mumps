cmake_minimum_required(VERSION 3.19...3.23)

project(MumpsPrereqs LANGUAGES C Fortran)

include(ExternalProject)

if(CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
  message(FATAL_ERROR "Please specify the install prefix:
    cmake -B build -DCMAKE_INSTALL_PREFIX=<path>")
endif()

if(NOT DEFINED arith)
  set(arith "s;d")
endif()

set(CMAKE_TLS_VERIFY true)

set_directory_properties(PROPERTIES EP_UPDATE_DISCONNECTED true)

file(READ ${CMAKE_CURRENT_SOURCE_DIR}/../cmake/libraries.json json)

# Lapack

set(lapack_cmake_args
-DCMAKE_INSTALL_PREFIX:PATH=${CMAKE_INSTALL_PREFIX}
-DBUILD_SHARED_LIBS:BOOL=${BUILD_SHARED_LIBS}
-DCMAKE_BUILD_TYPE=Release
-DBUILD_TESTING:BOOL=false
)

string(JSON lapack_url GET ${json} lapack git)
string(JSON lapack_tag GET ${json} lapack tag)

ExternalProject_Add(LAPACK
GIT_REPOSITORY ${lapack_url}
GIT_TAG ${lapack_tag}
CMAKE_ARGS ${lapack_cmake_args}
CMAKE_GENERATOR ${EXTPROJ_GENERATOR}
CMAKE_CACHE_ARGS -Darith:STRING=${arith}
BUILD_BYPRODUCTS ${LAPACK_LIBRARIES}
INACTIVITY_TIMEOUT 15
CONFIGURE_HANDLED_BY_BUILD ON
)

# Scalapack

set(scalapack_cmake_args
-DCMAKE_INSTALL_PREFIX:PATH=${CMAKE_INSTALL_PREFIX}
-DCMAKE_PREFIX_PATH:PATH=${CMAKE_INSTALL_PREFIX}
-DBUILD_SHARED_LIBS:BOOL=${BUILD_SHARED_LIBS}
-DCMAKE_BUILD_TYPE=Release
-DBUILD_TESTING:BOOL=false
-Dautobuild:BOOL=false
)

string(JSON scalapack_url GET ${json} scalapack git)
string(JSON scalapack_tag GET ${json} scalapack tag)

ExternalProject_Add(SCALAPACK
GIT_REPOSITORY ${scalapack_url}
GIT_TAG ${scalapack_tag}
CMAKE_ARGS ${scalapack_cmake_args}
CMAKE_CACHE_ARGS -Darith:STRING=${arith}
CMAKE_GENERATOR ${EXTPROJ_GENERATOR}
BUILD_BYPRODUCTS ${SCALAPACK_LIBRARIES}
INACTIVITY_TIMEOUT 15
CONFIGURE_HANDLED_BY_BUILD ON
DEPENDS LAPACK
)