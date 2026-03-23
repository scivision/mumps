include(FetchContent)


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

find_program(BISON_EXECUTABLE NAMES bison HINTS ${out} PATH_SUFFIXES opt/bison/bin)
if(NOT BISON_EXECUTABLE)
  return()
endif()

cmake_path(GET BISON_EXECUTABLE PARENT_PATH BISON_ROOT)
message(STATUS "BISON_EXECUTABLE ${BISON_EXECUTABLE}  BISON_ROOT ${BISON_ROOT}")

if(NOT DEFINED FLEX_ROOT)
  find_program(FLEX_EXECUTABLE NAMES flex HINTS ${out} PATH_SUFFIXES opt/flex/bin)
  if(FLEX_EXECUTABLE)
    cmake_path(GET FLEX_EXECUTABLE PARENT_PATH FLEX_ROOT)
    message(STATUS "FLEX_EXECUTABLE ${FLEX_EXECUTABLE}  FLEX_ROOT ${FLEX_ROOT}")
  endif()

  set(FLEX_ROOT ${FLEX_ROOT} PARENT_SCOPE)
endif()

set(BISON_ROOT ${BISON_ROOT} PARENT_SCOPE)

endfunction()


if(APPLE)
  find_package(BISON 2.7)
  if(NOT BISON_FOUND)
    unset(BISON_EXECUTABLE CACHE)
    bison_homebrew()
  endif()
endif()


# https://gitlab.inria.fr/scotch/scotch/-/blob/master/CMakeLists.txt
# options were checked with Scotch 7.0.7
set(ENABLE_TESTS false)
set(INSTALL_METIS_HEADERS false)
set(BUILD_LIBSCOTCHMETIS: false)
set(BUILD_LIBESMUMPS true)
set(BUILD_PTSCOTCH ${MUMPS_parallel})
if(MUMPS_intsize64)
  set(INTSIZE 64)
else()
  set(INTSIZE 32)
endif()
set(CMAKE_POSITION_INDEPENDENT_CODE true)

#https://gitlab.inria.fr/scotch/scotch/-/blob/master/src/CMakeLists.txt#L84
# CMAKE_POSITION_INDEPENDENT_CODE=ON necessary on HPC with shared libs like MPI

if(WIN32 AND (NOT BISON_ROOT OR NOT FLEX_ROOT))

  string(JSON win_flex_bison_url GET "${json}" win_flex_bison url)
  string(JSON win_flex_bison_sha256 GET "${json}" win_flex_bison sha256)

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


if(NOT DEFINED CMAKE_POLICY_VERSION_MINIMUM)
  set(CMAKE_POLICY_VERSION_MINIMUM ${CMAKE_MINIMUM_REQUIRED_VERSION})
endif()

string(JSON scotch_url GET "${json}" "scotch")

message(STATUS "BISON_ROOT ${BISON_ROOT}  FLEX_ROOT ${FLEX_ROOT}")

FetchContent_Declare(SCOTCH
  URL ${scotch_url}
  FIND_PACKAGE_ARGS
)

if(DEFINED win_flex_bison)
  set(_winfc_dep win_flex_bison)
endif()

FetchContent_MakeAvailable(${_winfc_dep} SCOTCH)

set(SCOTCH_names scotch scotcherr esmumps)
if(MUMPS_parallel)
  list(PREPEND SCOTCH_names ptscotch ptscotcherr ptesmumps)
endif()

foreach(l IN LISTS SCOTCH_names)
  add_library(SCOTCH::${l} ALIAS ${l})
endforeach()
