message(STATUS "${PROJECT_NAME} ${PROJECT_VERSION}  CMake ${CMAKE_VERSION}  Toolchain ${CMAKE_TOOLCHAIN_FILE}")

if(local)
  get_filename_component(local ${local} ABSOLUTE)

  if(NOT IS_DIRECTORY ${local})
    message(FATAL_ERROR "Local directory ${local} does not exist")
  endif()
endif()

option(intsize64 "use 64-bit integers in C and Fortran")

option(scotch "use Scotch" OFF)
option(openmp "use OpenMP" OFF)

option(matlab "Matlab interface" OFF)
option(octave "GNU Octave interface" OFF)

if(matlab OR octave)
  option(parallel "parallel (use MPI)" OFF)
  set(CMAKE_POSITION_INDEPENDENT_CODE ON)
else()
  option(parallel "parallel (use MPI)" ON)
endif()

# --- other options

if(NOT arith)
  set(arith "s;d")
endif()

if(intsize64)
  add_compile_definitions(INTSIZE64
  $<$<COMPILE_LANG_AND_ID:Fortran,Intel,IntelLLVM>:WORKAROUNDINTELILP64MPI2INTEGER>
  )
endif()

include(GNUInstallDirs)

set(CMAKE_TLS_VERIFY true)

list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_LIST_DIR})

# Rpath options necessary for shared library install to work correctly in user projects
set(CMAKE_INSTALL_NAME_DIR ${CMAKE_INSTALL_PREFIX}/lib)
set(CMAKE_INSTALL_RPATH ${CMAKE_INSTALL_PREFIX}/lib)
set(CMAKE_INSTALL_RPATH_USE_LINK_PATH true)

# Necessary for shared library with Visual Studio / Windows oneAPI
set(CMAKE_WINDOWS_EXPORT_ALL_SYMBOLS true)

if(CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
  # will not take effect without FORCE
  # CMAKE_BINARY_DIR for use from FetchContent
  set(CMAKE_INSTALL_PREFIX ${CMAKE_BINARY_DIR} CACHE PATH "Install top-level directory" FORCE)
endif()

# allow CMAKE_PREFIX_PATH with ~ expand
if(CMAKE_PREFIX_PATH)
  get_filename_component(CMAKE_PREFIX_PATH ${CMAKE_PREFIX_PATH} ABSOLUTE)
endif()

# --- auto-ignore build directory
if(NOT EXISTS ${PROJECT_BINARY_DIR}/.gitignore)
  file(WRITE ${PROJECT_BINARY_DIR}/.gitignore "*")
endif()
