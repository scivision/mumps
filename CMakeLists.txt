cmake_minimum_required(VERSION 3.20...4.1)

if(CMAKE_SOURCE_DIR STREQUAL CMAKE_BINARY_DIR)
  message(FATAL_ERROR "Please use out of source build:
  cmake -B build")
endif()

get_property(is_multi_config GLOBAL PROPERTY GENERATOR_IS_MULTI_CONFIG)
if(NOT is_multi_config AND NOT (CMAKE_BUILD_TYPE OR DEFINED ENV{CMAKE_BUILD_TYPE}))
  set(CMAKE_BUILD_TYPE Release CACHE STRING "Release default")
endif()

project(MUMPS
LANGUAGES C Fortran
VERSION 5.8.1.0
DESCRIPTION "Sparse direct parallel solver"
HOMEPAGE_URL "https://mumps-solver.org/"
)

if(CMAKE_VERSION VERSION_GREATER 3.30.0 AND CMAKE_VERSION VERSION_LESS 3.30.4)
cmake_policy(SET CMP0168 OLD)
# workaround to stop repeat FetchContent download on each configure for CMake 3.30.0..3.30.3
endif()

enable_testing()

include(GNUInstallDirs)
include(cmake/GitSubmodule.cmake)


if(MSVC AND BUILD_SHARED_LIBS)
  message(WARNING "MUMPS: Windows IntelLLVM compilers with **shared** libraries is not supported and will probably fail.
  Recommend using static libraries, which does work:
  cmake -DBUILD_SHARED_LIBS=off")
endif()

# --- user options
include(options.cmake)
include(cmake/compilers.cmake)

message(STATUS "MUMPS ${PROJECT_VERSION} upstream ${MUMPS_UPSTREAM_VERSION} install prefix: ${CMAKE_INSTALL_PREFIX}")
message(STATUS "CMake ${CMAKE_VERSION}  Toolchain ${CMAKE_TOOLCHAIN_FILE}")
message(STATUS "MUMPS source URL: ${MUMPS_url}")

# --- download MUMPS source
include(FetchContent)

set(_hash)
if(MUMPS_UPSTREAM_VERSION)
  set(_json_fn ${CMAKE_CURRENT_SOURCE_DIR}/cmake/libraries.json)
  file(READ ${_json_fn} json)
  string(JSON mumps_sha256 ERROR_VARIABLE _jerr GET ${json} "mumps_sha256" "${MUMPS_UPSTREAM_VERSION}")
  if(NOT _jerr AND mumps_sha256)
    set(_hash URL_HASH SHA256=${mumps_sha256})
    message(STATUS "MUMPS ${MUMPS_UPSTREAM_VERSION} ${_hash}")
  else()
    message(STATUS "No sha256 for MUMPS ${MUMPS_UPSTREAM_VERSION} found in ${_json_fn}")
  endif()
endif()

set(FETCHCONTENT_QUIET no)


FetchContent_Populate(MUMPS
URL ${MUMPS_url}
${_hash}
)

# Read MUMPS/VERSION file to get the actual version
# the first line is like "MUMPS 5.7.3"
file(STRINGS "${mumps_SOURCE_DIR}/VERSION" _version_line LIMIT_COUNT 1 REGEX "^MUMPS [0-9]+\\.[0-9]+\\.[0-9]+")
message(DEBUG "MUMPS version line: ${_version_line}")
string(REGEX REPLACE "MUMPS ([0-9]+\\.[0-9]+\\.[0-9]+)" "\\1" MUMPS_ACTUAL_VERSION "${_version_line}")
if(MUMPS_UPSTREAM_VERSION AND NOT MUMPS_ACTUAL_VERSION VERSION_EQUAL MUMPS_UPSTREAM_VERSION)
  message(FATAL_ERROR "Failed to read MUMPS version ${MUMPS_UPSTREAM_VERSION} from ${mumps_SOURCE_DIR}/VERSION, got ${MUMPS_ACTUAL_VERSION} instead.")
endif()

# minimum MUMPS version
if(MUMPS_ACTUAL_VERSION VERSION_LESS 5.2)
  message(FATAL_ERROR "MUMPS version ${MUMPS_ACTUAL_VERSION} is too old, please use MUMPS >= 5.2")
endif()

# --- dependencies
find_package(Threads)

# -- Scalapack / MPI
set(NUMERIC_LIBS LAPACK::LAPACK)

if(MUMPS_parallel)
  find_package(MPI COMPONENTS C Fortran REQUIRED)
  if(NOT DEFINED ENV{MKLROOT} AND NOT LAPACK_VENDOR MATCHES "^MKL" OR NOT MUMPS_scalapack)
    # oneMKL MKLConfig.cmake must be invoked only once
    include(cmake/lapack.cmake)
  endif()

  if(MUMPS_scalapack)
    include(cmake/scalapack.cmake) # this will also create the LAPACK::LAPACK target
    list(PREPEND NUMERIC_LIBS SCALAPACK::SCALAPACK)
  endif()

  # this is needed for Intel MPI ILP64 support
  # It's a long-known FindMPI CMake issue
  # https://discourse.cmake.org/t/problem-enabling-64-bit-fortran-compilation-on-windows-using-intel-oneapi-with-cmake-on-windows/4541
  # https://github.com/scivision/mumps/issues/114
  if(MUMPS_intsize64 AND DEFINED ENV{I_MPI_ROOT})
    find_path(IMPI_INC64
      NAMES mpi.mod
      HINTS $ENV{I_MPI_ROOT}
      NO_DEFAULT_PATH
      PATH_SUFFIXES include/mpi/ilp64
      REQUIRED
    )
    message(STATUS "Found IMPI ILP64 include: ${IMPI_INC64}")
    list(PREPEND MPI_Fortran_INCLUDE_DIRS ${IMPI_INC64})

    find_library(IMPI_LIB64
      NAMES mpi_ilp64 libmpi_ilp64
      HINTS $ENV{I_MPI_ROOT}
      NO_DEFAULT_PATH
      PATH_SUFFIXES lib
      REQUIRED
    )
    message(STATUS "Found IMPI ILP64 library: ${IMPI_LIB64}")
    list(APPEND NUMERIC_LIBS ${IMPI_LIB64})
  endif()

else()

  include(cmake/lapack.cmake)
  include(cmake/libseq.cmake)

endif()

# LINK_ONLY avoids MPICH Fortran -fallow flag leakage
list(APPEND NUMERIC_LIBS $<LINK_ONLY:MPI::MPI_Fortran> MPI::MPI_C)

if(MUMPS_openmp)
  find_package(OpenMP COMPONENTS C Fortran REQUIRED)
  list(APPEND NUMERIC_LIBS OpenMP::OpenMP_Fortran OpenMP::OpenMP_C)
endif()

# GEMMT is recommended in MUMPS User Manual if available
if(gemmt)
  include(cmake/gemmt.cmake)
endif()

# --- ordering libs

set(ORDERING_LIBS)
set(ORDERING_DEFS pord)

if(MUMPS_scotch)

  if(NOT Scotch_FOUND)
    include(cmake/scotch.cmake)
  endif()

  list(APPEND ORDERING_DEFS scotch)
  list(APPEND ORDERING_LIBS SCOTCH::scotch)

endif()


set(IDXTYPEWIDTH $<IF:$<BOOL:${MUMPS_intsize64}>,64,32>)
if(MUMPS_metis)
  git_submodule(${PROJECT_SOURCE_DIR}/metis)
  add_subdirectory(metis)

  list(APPEND ORDERING_DEFS REALTYPEWIDTH=32 IDXTYPEWIDTH=${IDXTYPEWIDTH} metis)
  list(APPEND ORDERING_LIBS metis::metis)
elseif(MUMPS_parmetis)
  git_submodule(${PROJECT_SOURCE_DIR}/parmetis)
  add_subdirectory(parmetis)

  list(APPEND ORDERING_DEFS REALTYPEWIDTH=32 IDXTYPEWIDTH=${IDXTYPEWIDTH} parmetis metis)
  list(APPEND ORDERING_LIBS METIS::PARMETIS)
endif()

list(APPEND ORDERING_LIBS pord)

install(FILES
${CMAKE_CURRENT_SOURCE_DIR}/cmake/FindLAPACK.cmake
${CMAKE_CURRENT_SOURCE_DIR}/cmake/FindSCALAPACK.cmake
DESTINATION cmake
)

message(STATUS "MUMPS ORDERING_DEFS: ${ORDERING_DEFS}")
message(STATUS "MUMPS ORDERING_LIBS: ${ORDERING_LIBS}")
message(STATUS "MUMPS LAPACK_VENDOR: ${LAPACK_VENDOR}")
message(STATUS "MUMPS SCALAPACK_VENDOR: ${SCALAPACK_VENDOR}")

# --- MUMPS build

list(APPEND NUMERIC_LIBS ${CMAKE_THREAD_LIBS_INIT})

# --- PORD (always used)
include(cmake/pord.cmake)

# --- MUMPS itself
include(cmake/mumps.cmake)

if(MUMPS_matlab)
  include(cmake/matlab.cmake)
endif()


if(${PROJECT_NAME}_BUILD_TESTING)
  add_subdirectory(test)
endif()


# --- feature summary

message(STATUS "Configured MUMPS ${MUMPS_ACTUAL_VERSION} source in ${mumps_SOURCE_DIR}")

include(cmake/summary.cmake)

include(cmake/install.cmake)

file(GENERATE OUTPUT .gitignore CONTENT "*")
