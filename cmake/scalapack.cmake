# Finds Scalapack, tests, and if not found or broken, autobuild scalapack
include(ExternalProject)

if(intsize64)
  if(MKL IN_LIST SCALAPACK_COMPONENTS)
    list(APPEND SCALAPACK_COMPONENTS MKL64)
  else()
    if(NOT (OpenMPI IN_LIST SCALAPACK_COMPONENTS
        OR MPICH IN_LIST SCALAPACK_COMPONENTS
        OR MKL IN_LIST SCALAPACK_COMPONENTS))
      if(DEFINED ENV{MKLROOT})
        list(APPEND SCALAPACK_COMPONENTS MKL MKL64)
      endif()
    endif()
  endif()
endif()

if(NOT scalapack_external)
  if(autobuild)
    find_package(SCALAPACK COMPONENTS ${SCALAPACK_COMPONENTS})
  else()
    find_package(SCALAPACK REQUIRED COMPONENTS ${SCALAPACK_COMPONENTS})
  endif()
endif()

if(SCALAPACK_FOUND OR TARGET SCALAPACK::SCALAPACK)
  return()
endif()


set(scalapack_external true CACHE BOOL "build ScaLapack")

if(NOT SCALAPACK_ROOT)
  set(SCALAPACK_ROOT ${CMAKE_INSTALL_PREFIX})
endif()

set(SCALAPACK_LIBRARIES
${SCALAPACK_ROOT}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}scalapack${CMAKE_STATIC_LIBRARY_SUFFIX}
${SCALAPACK_ROOT}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}blacs${CMAKE_STATIC_LIBRARY_SUFFIX})

set(scalapack_c_flags)
include(CheckCompilerFlag)
if(CMAKE_C_COMPILER_ID STREQUAL GNU)
  # test the non-no form, otherwise always succeeds
  check_compiler_flag(C -Wimplicit-function-declaration HAS_IMPLICIT_FUNC_FLAG)
  if(HAS_IMPLICIT_FUNC_FLAG)
    set(scalapack_c_flags -Wno-implicit-function-declaration)
  endif()
endif()

ExternalProject_Add(SCALAPACK
GIT_REPOSITORY ${scalapack_git}
GIT_TAG ${scalapack_tag}
CMAKE_ARGS -DCMAKE_C_FLAGS=${scalapack_c_flags} -DCMAKE_INSTALL_PREFIX:PATH=${SCALAPACK_ROOT} -DLAPACK_ROOT:PATH=${LAPACK_ROOT} -DBUILD_SHARED_LIBS:BOOL=false -DCMAKE_BUILD_TYPE=Release -DBUILD_TESTING:BOOL=false
CMAKE_CACHE_ARGS -Darith:STRING=${arith}
BUILD_BYPRODUCTS ${SCALAPACK_LIBRARIES}
INACTIVITY_TIMEOUT 30
CONFIGURE_HANDLED_BY_BUILD ON
)

add_library(SCALAPACK::SCALAPACK INTERFACE IMPORTED)
target_link_libraries(SCALAPACK::SCALAPACK INTERFACE "${SCALAPACK_LIBRARIES}")

# race condition for linking without this
add_dependencies(SCALAPACK::SCALAPACK SCALAPACK)
