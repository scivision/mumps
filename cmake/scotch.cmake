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

find_program(bison NAMES bison HINTS ${out} PATH_SUFFIXES opt/bison/bin)
if(NOT bison)
  return()
endif()

message(STATUS "Bison found: ${bison}")
cmake_path(GET bison PARENT_PATH bison_root)

set(BISON_ROOT ${bison_root} PARENT_SCOPE)

endfunction()

if(APPLE)
  bison_homebrew()
endif()

# https://gitlab.inria.fr/scotch/scotch/-/blob/master/CMakeLists.txt
# options were checked with Scotch 7.0.7
set(scotch_cmake_args
-DCMAKE_INSTALL_PREFIX:PATH=${CMAKE_INSTALL_PREFIX}
-DBUILD_SHARED_LIBS:BOOL=${BUILD_SHARED_LIBS}
-DENABLE_TESTS:BOOL=false
-DINSTALL_METIS_HEADERS:BOOL=false
-DBUILD_LIBSCOTCHMETIS:BOOL=false
-DBUILD_LIBESMUMPS:BOOL=true
-DBUILD_PTSCOTCH:BOOL=${MUMPS_parallel}
-DINTSIZE=$<IF:$<BOOL:${MUMPS_intsize64}>,64,32>
-DCMAKE_BUILD_TYPE=Release
-DCMAKE_C_COMPILER:FILEPATH=${CMAKE_C_COMPILER}
-DCMAKE_Fortran_COMPILER:FILEPATH=${CMAKE_Fortran_COMPILER}
-DCMAKE_POLICY_DEFAULT_CMP0074=NEW
)
#https://gitlab.inria.fr/scotch/scotch/-/blob/master/src/CMakeLists.txt#L84

string(JSON scotch_url GET ${json} scotch url)
string(JSON scotch_sha256 GET ${json} scotch sha256)

set(Scotch_INCLUDE_DIRS ${CMAKE_INSTALL_FULL_INCLUDEDIR})

set(scotch_names scotch scotcherr esmumps)
if(MUMPS_parallel)
  list(PREPEND scotch_names ptscotch ptscotcherr ptesmumps)
endif()

set(Scotch_LIBRARIES)
if(BUILD_SHARED_LIBS)
  foreach(n IN LISTS scotch_names)
    list(APPEND Scotch_LIBRARIES
      ${CMAKE_INSTALL_FULL_LIBDIR}/${CMAKE_SHARED_LIBRARY_PREFIX}${n}${CMAKE_SHARED_LIBRARY_SUFFIX}
    )
  endforeach()
else()
  foreach(n IN LISTS scotch_names)
    list(APPEND Scotch_LIBRARIES
      ${CMAKE_INSTALL_FULL_LIBDIR}/${CMAKE_STATIC_LIBRARY_PREFIX}${n}${CMAKE_STATIC_LIBRARY_SUFFIX}
    )
  endforeach()
endif()

if(MSVC AND NOT BISON_ROOT)

  string(JSON win_flex_bison_url GET ${json} win_flex_bison url)

  FetchContent_Populate(win_flex_bison
  URL ${win_flex_bison_url}
  )

  message(DEBUG "Hint Bison,Flex path ${win_flex_bison_SOURCE_DIR}")
  find_program(_bison
  NAMES bison win_bison
  HINTS ${win_flex_bison_SOURCE_DIR}
  )
  if(_bison)
    cmake_path(GET _bison PARENT_PATH BISON_ROOT)
  endif()

  find_program(_flex
  NAMES flex win_flex
  HINTS ${win_flex_bison_SOURCE_DIR}
  )
  if(_flex)
    cmake_path(GET _flex PARENT_PATH FLEX_ROOT)
  endif()
endif()

if(BISON_ROOT)
  list(APPEND scotch_cmake_args -DBISON_ROOT:PATH=${BISON_ROOT})
endif()

if(FLEX_ROOT)
  list(APPEND scotch_cmake_args -DFLEX_ROOT:PATH=${FLEX_ROOT})
endif()

message(DEBUG "Scotch CMake args: ${scotch_cmake_args}")

ExternalProject_Add(scotch_ep
URL ${scotch_url}
URL_HASH SHA256=${scotch_sha256}
CMAKE_ARGS ${scotch_cmake_args}
CONFIGURE_HANDLED_BY_BUILD true
TEST_COMMAND ""
BUILD_BYPRODUCTS ${Scotch_LIBRARIES}
USES_TERMINAL_DOWNLOAD true
USES_TERMINAL_UPDATE true
USES_TERMINAL_PATCH true
USES_TERMINAL_CONFIGURE true
USES_TERMINAL_BUILD true
USES_TERMINAL_INSTALL true
)


file(MAKE_DIRECTORY ${Scotch_INCLUDE_DIRS})


add_library(Scotch::Scotch INTERFACE IMPORTED GLOBAL)
add_dependencies(Scotch::Scotch scotch_ep)
target_link_libraries(Scotch::Scotch INTERFACE "${Scotch_LIBRARIES}")
target_include_directories(Scotch::Scotch INTERFACE "${Scotch_INCLUDE_DIRS}")
