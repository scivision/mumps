include(ExternalProject)

# --- prereqs
include(${CMAKE_CURRENT_LIST_DIR}/lapack.cmake)

if(parallel)
  include(${CMAKE_CURRENT_LIST_DIR}/scalapack.cmake)
endif()

# --- MUMPS

if(NOT mumps_external AND CMAKE_Fortran_COMPILER_ID STREQUAL GNU)
  set(mumps_comp ${arith})
  if(NOT parallel)
    list(APPEND mumps_comp mpiseq)
  endif()

  if(autobuild)
    find_package(MUMPS COMPONENTS ${mumps_comp})
  else()
    find_package(MUMPS COMPONENTS ${mumps_comp} REQUIRED)
  endif()

  if(MUMPS_HAVE_Scotch)
    find_package(Scotch COMPONENTS ESMUMPS REQUIRED)
    find_package(METIS REQUIRED)
  endif()

  if(MUMPS_HAVE_OPENMP)
    find_package(OpenMP COMPONENTS C Fortran REQUIRED)
    target_link_libraries(MUMPS::MUMPS INTERFACE OpenMP::OpenMP_Fortran OpenMP::OpenMP_C)
  endif()
endif()

if(MUMPS_FOUND)
  return()
endif()

set(mumps_external true CACHE BOOL "build Mumps")


set(MUMPS_INCLUDE_DIRS ${CMAKE_INSTALL_PREFIX}/include)
set(MUMPS_LIBRARIES)

if(BUILD_SHARED_LIBS)
  if(WIN32)
    foreach(a ${arith})
      list(APPEND MUMPS_LIBRARIES ${CMAKE_INSTALL_PREFIX}/bin/${CMAKE_SHARED_LIBRARY_PREFIX}${a}mumps${CMAKE_SHARED_LIBRARY_SUFFIX})
    endforeach()

    list(APPEND MUMPS_LIBRARIES
    ${CMAKE_INSTALL_PREFIX}/bin/${CMAKE_SHARED_LIBRARY_PREFIX}mumps_common${CMAKE_SHARED_LIBRARY_SUFFIX}
    ${CMAKE_INSTALL_PREFIX}/bin/${CMAKE_SHARED_LIBRARY_PREFIX}pord${CMAKE_SHARED_LIBRARY_SUFFIX}
    )

    if(NOT MPI_FOUND)
      set(MUMPS_MPISEQ_LIBRARIES ${CMAKE_INSTALL_PREFIX}/bin/${CMAKE_SHARED_LIBRARY_PREFIX}mpiseq${CMAKE_SHARED_LIBRARY_SUFFIX})
    endif()
  else()
    foreach(a ${arith})
      list(APPEND MUMPS_LIBRARIES ${CMAKE_INSTALL_PREFIX}/lib/${CMAKE_SHARED_LIBRARY_PREFIX}${a}mumps${CMAKE_SHARED_LIBRARY_SUFFIX})
    endforeach()

    list(APPEND MUMPS_LIBRARIES
    ${CMAKE_INSTALL_PREFIX}/lib/${CMAKE_SHARED_LIBRARY_PREFIX}mumps_common${CMAKE_SHARED_LIBRARY_SUFFIX}
    ${CMAKE_INSTALL_PREFIX}/lib/${CMAKE_SHARED_LIBRARY_PREFIX}pord${CMAKE_SHARED_LIBRARY_SUFFIX}
    )

    if(NOT MPI_FOUND)
      set(MUMPS_MPISEQ_LIBRARIES ${CMAKE_INSTALL_PREFIX}/lib/${CMAKE_SHARED_LIBRARY_PREFIX}mpiseq${CMAKE_SHARED_LIBRARY_SUFFIX})
    endif()
  endif()
else()
  foreach(a ${arith})
    list(APPEND MUMPS_LIBRARIES ${CMAKE_INSTALL_PREFIX}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}${a}mumps${CMAKE_STATIC_LIBRARY_SUFFIX})
  endforeach()

  list(APPEND MUMPS_LIBRARIES
  ${CMAKE_INSTALL_PREFIX}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}mumps_common${CMAKE_STATIC_LIBRARY_SUFFIX}
  ${CMAKE_INSTALL_PREFIX}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}pord${CMAKE_STATIC_LIBRARY_SUFFIX}
  )

  if(NOT MPI_FOUND)
    set(MUMPS_MPISEQ_LIBRARIES ${CMAKE_INSTALL_PREFIX}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}mpiseq${CMAKE_STATIC_LIBRARY_SUFFIX})
  endif()
endif()

set(mumps_deps LAPACK::LAPACK)
if(parallel)
  list(APPEND mumps_deps SCALAPACK::SCALAPACK)
endif()

set(mumps_cmake_args
-DCMAKE_INSTALL_PREFIX=${CMAKE_INSTALL_PREFIX}
-DCMAKE_PREFIX_PATH:PATH=${CMAKE_INSTALL_PREFIX}
-DBUILD_SHARED_LIBS:BOOL=${BUILD_SHARED_LIBS}
-DCMAKE_BUILD_TYPE=Release
-DCMAKE_C_COMPILER=${CMAKE_C_COMPILER}
-DCMAKE_Fortran_COMPILER=${CMAKE_Fortran_COMPILER}
-DBUILD_TESTING:BOOL=false
-DMUMPS_UPSTREAM_VERSION=${MUMPS_UPSTREAM_VERSION}
-Dscotch:BOOL=${scotch}
-Dopenmp:BOOL=false
-Dparallel:BOOL=${parallel}
-Dautobuild:BOOL=false
)

ExternalProject_Add(MUMPS
SOURCE_DIR ${CMAKE_CURRENT_LIST_DIR}/..
CMAKE_ARGS ${mumps_cmake_args}
CMAKE_CACHE_ARGS -Darith:STRING=${arith}
CMAKE_GENERATOR ${EXTPROJ_GENERATOR}
BUILD_BYPRODUCTS ${MUMPS_LIBRARIES} ${MUMPS_MPISEQ_LIBRARIES}
INACTIVITY_TIMEOUT 15
CONFIGURE_HANDLED_BY_BUILD ON
DEPENDS ${mumps_deps}
)

file(MAKE_DIRECTORY ${MUMPS_INCLUDE_DIRS})

add_library(MUMPS::MUMPS INTERFACE IMPORTED)
target_link_libraries(MUMPS::MUMPS INTERFACE "${MUMPS_LIBRARIES}")
target_include_directories(MUMPS::MUMPS INTERFACE ${MUMPS_INCLUDE_DIRS})

# race condition for linking without this
add_dependencies(MUMPS::MUMPS MUMPS)

if(NOT MPI_FOUND)
  add_library(MUMPS::MPISEQ INTERFACE IMPORTED)
  target_link_libraries(MUMPS::MPISEQ INTERFACE "${MUMPS_MPISEQ_LIBRARIES}" ${CMAKE_THREAD_LIBS_INIT})
  target_include_directories(MUMPS::MPISEQ INTERFACE ${MUMPS_INCLUDE_DIRS})

  # race condition for linking without this
  add_dependencies(MUMPS::MPISEQ MUMPS)
endif()
