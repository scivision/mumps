option(autobuild "auto-build Lapack and/or Scalapack if missing or broken")
option(BUILD_TESTING "build with testing features" true)
option(parallel "parallel or sequential (non-MPI, non-Scalapack)" ON)
option(intsize64 "use 64-bit integers in C and Fortran" OFF)

option(scotch "use Scotch" OFF)
option(openmp "use OpenMP" OFF)

# --- other options

# default build all
if(NOT DEFINED arith)
  set(arith "s;d")
endif()

if(intsize64)
  add_compile_definitions(INTSIZE64
  $<$<COMPILE_LANG_AND_ID:Fortran,Intel,IntelLLVM>:WORKAROUNDINTELILP64MPI2INTEGER>
  )
endif()

set(CMAKE_EXPORT_COMPILE_COMMANDS on)

set(CMAKE_TLS_VERIFY true)


set(FETCHCONTENT_UPDATES_DISCONNECTED_MUMPS true)
set_directory_properties(PROPERTIES EP_UPDATE_DISCONNECTED true)

if(CMAKE_GENERATOR STREQUAL "Ninja Multi-Config")
  set(EXTPROJ_GENERATOR "Ninja")
else()
  set(EXTPROJ_GENERATOR ${CMAKE_GENERATOR})
endif()


if(CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
  # will not take effect without FORCE
  # CMAKE_BINARY_DIR for use from FetchContent
  set(CMAKE_INSTALL_PREFIX ${CMAKE_BINARY_DIR} CACHE PATH "Install top-level directory" FORCE)
endif()


# --- auto-ignore build directory
if(NOT EXISTS ${PROJECT_BINARY_DIR}/.gitignore)
  file(WRITE ${PROJECT_BINARY_DIR}/.gitignore "*")
endif()
