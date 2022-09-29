cmake_minimum_required(VERSION 3.19)

project(MumpsPrereqs LANGUAGES C Fortran)

include(ExternalProject)

file(MAKE_DIRECTORY ${CMAKE_INSTALL_PREFIX})
message(STATUS "Installingn MUMPS prerequisites to ${CMAKE_INSTALL_PREFIX}")

if(NOT DEFINED arith)
  set(arith "s;d")
endif()

set(CMAKE_TLS_VERIFY true)

set_property(DIRECTORY PROPERTY EP_UPDATE_DISCONNECTED true)

file(READ ${CMAKE_CURRENT_SOURCE_DIR}/../cmake/libraries.json json)

# default args
set(cmake_args
-DCMAKE_INSTALL_PREFIX:PATH=${CMAKE_INSTALL_PREFIX}
-DCMAKE_PREFIX_PATH:PATH=${CMAKE_INSTALL_PREFIX}
-DBUILD_SHARED_LIBS:BOOL=${BUILD_SHARED_LIBS}
-DCMAKE_BUILD_TYPE=Release
-DBUILD_TESTING:BOOL=false
)

# Lapack
set(lapack_cmake_args ${cmake_args})

string(JSON lapack_url GET ${json} lapack git)
string(JSON lapack_tag GET ${json} lapack tag)

ExternalProject_Add(lapack
GIT_REPOSITORY ${lapack_url}
GIT_TAG ${lapack_tag}
GIT_SHALLOW true
CMAKE_ARGS ${cmake_args}
CMAKE_CACHE_ARGS -Darith:STRING=${arith}
INACTIVITY_TIMEOUT 60
)

# Scalapack

set(scalapack_cmake_args ${cmake_args})

string(JSON scalapack_url GET ${json} scalapack git)
string(JSON scalapack_tag GET ${json} scalapack tag)

ExternalProject_Add(scalapack
GIT_REPOSITORY ${scalapack_url}
GIT_TAG ${scalapack_tag}
GIT_SHALLOW true
CMAKE_ARGS ${cmake_args}
CMAKE_CACHE_ARGS -Darith:STRING=${arith}
INACTIVITY_TIMEOUT 60
DEPENDS lapack
)

# METIS

string(JSON metis_url GET ${json} metis git)
string(JSON metis_tag GET ${json} metis tag)

ExternalProject_Add(metis
GIT_REPOSITORY ${metis_url}
GIT_TAG ${metis_tag}
GIT_SHALLOW true
CMAKE_ARGS ${cmake_args}
INACTIVITY_TIMEOUT 60
)

# Scotch

string(JSON scotch_url GET ${json} scotch git)
string(JSON scotch_tag GET ${json} scotch tag)

ExternalProject_Add(scotch
GIT_REPOSITORY ${scotch_url}
GIT_TAG ${scotch_tag}
GIT_SHALLOW true
CMAKE_ARGS ${cmake_args}
INACTIVITY_TIMEOUT 60
DEPENDS metis
)
