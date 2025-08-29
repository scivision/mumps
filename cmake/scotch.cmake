include(ExternalProject)


function(bison_homebrew)

find_program(brew NAMES brew)
if(NOT brew)
  return()
endif()

execute_process(COMMAND ${brew} --prefix
RESULT_VARIABLE ret
OUTPUT_VARIABLE out OUTPUT_STRIP_TRAILING_WHITESPACE
)

if(NOT ret EQUAL 0)
  return()
endif()

find_program(_bison_exe NAMES bison HINTS ${out} PATH_SUFFIXES opt/bison/bin)
if(NOT _bison_exe)
  return()
endif()

cmake_path(GET _bison_exe PARENT_PATH BISON_ROOT)
message(STATUS "Bison executable found: ${_bison_exe}  BISON_ROOT ${BISON_ROOT}")

if(NOT DEFINED FLEX_ROOT)
  find_program(_flex_exe NAMES flex HINTS ${out} PATH_SUFFIXES opt/flex/bin)
  if(_flex_exe)
    cmake_path(GET _flex_exe PARENT_PATH FLEX_ROOT)
    message(STATUS "Flex executable: ${_flex_exe}  FLEX_ROOT=${FLEX_ROOT}")
  endif()

  set(FLEX_ROOT ${FLEX_ROOT} PARENT_SCOPE)
endif()

set(BISON_ROOT ${BISON_ROOT} PARENT_SCOPE)

endfunction()


if(APPLE)
  find_package(BISON 2.7)
  if(NOT BISON_FOUND)
    bison_homebrew()
  endif()
endif()

git_submodule(${CMAKE_CURRENT_SOURCE_DIR}/scotch)


# https://gitlab.inria.fr/scotch/scotch/-/blob/master/CMakeLists.txt
# options were checked with Scotch 7.0.7
set(SCOTCH_cmake_args
-DCMAKE_INSTALL_PREFIX:PATH=${CMAKE_INSTALL_PREFIX}
-DBUILD_SHARED_LIBS:BOOL=${BUILD_SHARED_LIBS}
-DENABLE_TESTS:BOOL=false
-DINSTALL_METIS_HEADERS:BOOL=false
-DBUILD_LIBSCOTCHMETIS:BOOL=false
-DBUILD_LIBESMUMPS:BOOL=true
-DBUILD_PTSCOTCH:BOOL=${MUMPS_parallel}
-DINTSIZE=$<IF:$<BOOL:${MUMPS_intsize64}>,64,32>
-DCMAKE_POSITION_INDEPENDENT_CODE:BOOL=true
-DCMAKE_BUILD_TYPE=Release
-DCMAKE_C_COMPILER:FILEPATH=${CMAKE_C_COMPILER}
-DCMAKE_Fortran_COMPILER:FILEPATH=${CMAKE_Fortran_COMPILER}
-DCMAKE_POLICY_DEFAULT_CMP0074=NEW
)
#https://gitlab.inria.fr/scotch/scotch/-/blob/master/src/CMakeLists.txt#L84
# CMAKE_POSITION_INDEPENDENT_CODE=ON necessary on HPC with shared libs like MPI

set(SCOTCH_INCLUDE_DIRS ${CMAKE_INSTALL_FULL_INCLUDEDIR})

set(SCOTCH_names scotch scotcherr esmumps)
if(MUMPS_parallel)
  list(PREPEND SCOTCH_names ptscotch ptscotcherr ptesmumps)
endif()

set(SCOTCH_LIBRARIES)
if(BUILD_SHARED_LIBS)
  foreach(n IN LISTS SCOTCH_names)
    list(APPEND SCOTCH_LIBRARIES
      ${CMAKE_INSTALL_FULL_LIBDIR}/${CMAKE_SHARED_LIBRARY_PREFIX}${n}${CMAKE_SHARED_LIBRARY_SUFFIX}
    )
  endforeach()
else()
  foreach(n IN LISTS SCOTCH_names)
    list(APPEND SCOTCH_LIBRARIES
      ${CMAKE_INSTALL_FULL_LIBDIR}/${CMAKE_STATIC_LIBRARY_PREFIX}${n}${CMAKE_STATIC_LIBRARY_SUFFIX}
    )
  endforeach()
endif()

if(WIN32 AND (NOT BISON_ROOT OR NOT FLEX_ROOT))

  file(READ ${CMAKE_CURRENT_LIST_DIR}/libraries.json json)
  string(JSON win_flex_bison_url GET ${json} win_flex_bison url)
  string(JSON win_flex_bison_sha256 GET ${json} win_flex_bison sha256)

  FetchContent_Populate(win_flex_bison
  URL ${win_flex_bison_url}
  URL_HASH SHA256=${win_flex_bison_sha256}
  )

  message(DEBUG "Hint Bison,Flex path ${win_flex_bison_SOURCE_DIR}")
  find_program(_bison_exe
  NAMES bison win_bison
  HINTS ${win_flex_bison_SOURCE_DIR}
  )
  if(_bison_exe)
    cmake_path(GET _bison_exe PARENT_PATH BISON_ROOT)
  endif()

  find_program(_flex_exe
  NAMES flex win_flex
  HINTS ${win_flex_bison_SOURCE_DIR}
  )
  if(_flex_exe)
    cmake_path(GET _flex_exe PARENT_PATH FLEX_ROOT)
  endif()
endif()

if(BISON_ROOT)
  list(APPEND SCOTCH_cmake_args -DBISON_ROOT:PATH=${BISON_ROOT})
endif()

if(FLEX_ROOT)
  list(APPEND SCOTCH_cmake_args -DFLEX_ROOT:PATH=${FLEX_ROOT})
endif()

message(DEBUG "Scotch CMake args: ${SCOTCH_cmake_args}")

ExternalProject_Add(scotch_ep
URL ${CMAKE_CURRENT_SOURCE_DIR}/scotch
CMAKE_ARGS ${SCOTCH_cmake_args}
CONFIGURE_HANDLED_BY_BUILD true
TEST_COMMAND ""
BUILD_BYPRODUCTS ${SCOTCH_LIBRARIES}
USES_TERMINAL_DOWNLOAD true
USES_TERMINAL_UPDATE true
USES_TERMINAL_PATCH true
USES_TERMINAL_CONFIGURE true
USES_TERMINAL_BUILD true
USES_TERMINAL_INSTALL true
)

if(DEFINED win_flex_bison)
  add_dependencies(scotch_ep win_flex_bison)
endif()

file(MAKE_DIRECTORY ${SCOTCH_INCLUDE_DIRS})
if(NOT IS_DIRECTORY ${SCOTCH_INCLUDE_DIRS})
  message(FATAL_ERROR "Could not create directory: ${SCOTCH_INCLUDE_DIRS}")
endif()

foreach(l IN LISTS SCOTCH_names)
  add_library(SCOTCH::${l} INTERFACE IMPORTED GLOBAL)
  add_dependencies(SCOTCH::${l} scotch_ep)
  set_property(TARGET SCOTCH::${l} PROPERTY INTERFACE_LINK_LIBRARIES "${SCOTCH_${l}_LIBRARY}")
  set_property(TARGET SCOTCH::${l} PROPERTY INTERFACE_INCLUDE_DIRECTORIES "${SCOTCH_INCLUDE_DIRS}")
endforeach()

message(STATUS "SCOTCH_LIBRARIES: ${SCOTCH_LIBRARIES}")
