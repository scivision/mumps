# Finds Lapack, tests, and if not found or broken, autobuild Lapack
include(ExternalProject)

if(intsize64)
  if(MKL IN_LIST LAPACK_COMPONENTS)
    list(APPEND LAPACK_COMPONENTS MKL64)
  else()
    if(NOT
       (OpenBLAS IN_LIST LAPACK_COMPONENTS
        OR Netlib IN_LIST LAPACK_COMPONENTS
        OR Atlas IN_LIST LAPACK_COMPONENTS
        OR MKL IN_LIST LAPACK_COMPONENTS))
      if(DEFINED ENV{MKLROOT})
        list(APPEND LAPACK_COMPONENTS MKL MKL64)
      endif()
    endif()
  endif()
endif()

if(NOT lapack_external)
  if(autobuild)
    find_package(LAPACK COMPONENTS ${LAPACK_COMPONENTS})
  else()
    find_package(LAPACK REQUIRED COMPONENTS ${LAPACK_COMPONENTS})
  endif()
endif()

if(LAPACK_FOUND OR TARGET LAPACK::LAPACK)
  return()
endif()

set(lapack_external true CACHE BOOL "build Lapack")

if(NOT LAPACK_ROOT)
  set(LAPACK_ROOT ${CMAKE_INSTALL_PREFIX})
endif()

set(LAPACK_LIBRARIES
    ${LAPACK_ROOT}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}lapack${CMAKE_STATIC_LIBRARY_SUFFIX}
    ${LAPACK_ROOT}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}blas${CMAKE_STATIC_LIBRARY_SUFFIX}
)

ExternalProject_Add(
  LAPACK
  GIT_REPOSITORY ${lapack_git}
  GIT_TAG ${lapack_tag}
  CMAKE_ARGS -DCMAKE_INSTALL_PREFIX:PATH=${LAPACK_ROOT}
             -DBUILD_SHARED_LIBS:BOOL=false -DCMAKE_BUILD_TYPE=Release
             -DBUILD_TESTING:BOOL=false
  CMAKE_CACHE_ARGS -Darith:STRING=${arith}
  BUILD_BYPRODUCTS ${LAPACK_LIBRARIES} INACTIVITY_TIMEOUT 30
                   CONFIGURE_HANDLED_BY_BUILD ON)

add_library(LAPACK::LAPACK INTERFACE IMPORTED)
target_link_libraries(LAPACK::LAPACK INTERFACE "${LAPACK_LIBRARIES}")

# race condition for linking without this
add_dependencies(LAPACK::LAPACK LAPACK)
