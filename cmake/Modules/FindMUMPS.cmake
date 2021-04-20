# Distributed under the OSI-approved BSD 3-Clause License.  See accompanying
# file Copyright.txt or https://cmake.org/licensing for details.

#[=======================================================================[.rst:
FindMUMPS
---------

Finds the MUMPS library.
Note that MUMPS generally requires SCALAPACK and LAPACK as well.
PORD is always used, in addition to the optional METIS or SCOTCH, which would be found externally.

COMPONENTS
  s d c z   list one or more. Defaults to ``d``.
  mpiseq    for -Dparallel=false, a stub MPI & Scalapack library

Result Variables
^^^^^^^^^^^^^^^^

MUMPS_LIBRARIES
  libraries to be linked

MUMPS_INCLUDE_DIRS
  dirs to be included

#]=======================================================================]

set(MUMPS_LIBRARY)  # don't endlessly append

# --- functions

function(mumps_check)

if(NOT mpiseq IN_LIST MUMPS_FIND_COMPONENTS)
  if(NOT TARGET MPI::MPI_Fortran)
    find_package(MPI COMPONENTS Fortran)
  endif()
  if(NOT TARGET SCALAPACK::SCALAPACK)
    find_package(SCALAPACK)
  endif()
endif()

find_package(LAPACK)

set(CMAKE_REQUIRED_INCLUDES ${MUMPS_INCLUDE_DIR} ${SCALAPACK_INCLUDE_DIRS} ${LAPACK_INCLUDE_DIRS} ${MPI_Fortran_INCLUDE_DIRS})
set(CMAKE_REQUIRED_LIBRARIES ${MUMPS_LIBRARY} ${SCALAPACK_LIBRARIES} ${LAPACK_LIBRARIES} ${MPI_Fortran_LIBRARIES} ${_test_lib})

set(MUMPS_links true)

foreach(i s d c z)

if("${i}" IN_LIST MUMPS_FIND_COMPONENTS)

  check_fortran_source_compiles("
  program test_mumps
  implicit none (type, external)
  include '${i}mumps_struc.h'
  external :: ${i}mumps
  type(${i}mumps_struc) :: mumps_par
  end program"
    MUMPS_${i}_links SRC_EXT f90)

  if(MUMPS_${i}_links)
    set(MUMPS_${i}_FOUND true PARENT_SCOPE)
  else()
    set(MUMPS_links false)
  endif()
endif()

endforeach()

set(MUMPS_links ${MUMPS_links} PARENT_SCOPE)

endfunction(mumps_check)


function(mumps_libs)

# NOTE: NO_DEFAULT_PATH disables CMP0074 MUMPS_ROOT and PATH_SUFFIXES, so we manually specify:
# HINTS ${MUMPS_ROOT}
# PATH_SUFFIXES ...
# to allow MKL using user-built MUMPS with `cmake -DMUMPS_ROOT=~/lib_intel/mumps`

if(DEFINED ENV{MKLROOT})
  find_path(MUMPS_INCLUDE_DIR NAMES mumps_compat.h NO_DEFAULT_PATH HINTS ${MUMPS_ROOT} PATH_SUFFIXES include DOC "MUMPS common header")
else()
  find_path(MUMPS_INCLUDE_DIR NAMES mumps_compat.h DOC "MUMPS common header")
endif()
if(NOT MUMPS_INCLUDE_DIR)
  return()
endif()

if(DEFINED ENV{MKLROOT})
  find_library(MUMPS_COMMON NAMES mumps_common NO_DEFAULT_PATH HINTS ${MUMPS_ROOT} PATH_SUFFIXES lib DOC "MUMPS common libraries")
else()
  find_library(MUMPS_COMMON NAMES mumps_common DOC "MUMPS common libraries")
endif()
if(NOT MUMPS_COMMON)
  return()
endif()

if(DEFINED ENV{MKLROOT})
  find_library(PORD NAMES pord NO_DEFAULT_PATH HINTS ${MUMPS_ROOT} PATH_SUFFIXES lib DOC "simplest MUMPS ordering library")
else()
  find_library(PORD NAMES pord DOC "simplest MUMPS ordering library")
endif()
if(NOT PORD)
  return()
endif()

if(mpiseq IN_LIST MUMPS_FIND_COMPONENTS)
  if(DEFINED ENV{MKLROOT})
    find_library(MUMPS_mpiseq_LIB NAMES mpiseq NO_DEFAULT_PATH HINTS ${MUMPS_ROOT} PATH_SUFFIXES lib DOC "No-MPI stub library")
  else()
    find_library(MUMPS_mpiseq_LIB NAMES mpiseq DOC "No-MPI stub library")
  endif()
  if(NOT MUMPS_mpiseq_LIB)
    return()
  endif()

  if(DEFINED ENV{MKLROOT})
    find_path(MUMPS_mpiseq_INC NAMES mpif.h NO_DEFAULT_PATH HINTS ${MUMPS_ROOT} PATH_SUFFIXES include DOC "MUMPS mpiseq header")
  else()
    find_path(MUMPS_mpiseq_INC NAMES mpif.h DOC "MUMPS mpiseq header")
  endif()
  if(NOT MUMPS_mpiseq_INC)
    return()
  endif()

  set(MUMPS_mpiseq_FOUND true PARENT_SCOPE)
  set(MUMPS_mpiseq_LIB ${MUMPS_mpiseq_LIB} PARENT_SCOPE)
  set(MUMPS_mpiseq_INC ${MUMPS_mpiseq_INC} PARENT_SCOPE)
endif()

set(_ariths s d c z)
foreach(comp ${MUMPS_FIND_COMPONENTS})
  if(NOT "${comp}" IN_LIST _ariths)
    continue()
  endif()

  if(DEFINED ENV{MKLROOT})
    find_library(MUMPS_${comp}_lib NAMES ${comp}mumps NO_DEFAULT_PATH HINTS ${MUMPS_ROOT} PATH_SUFFIXES lib DOC "MUMPS precision-specific")
  else()
    find_library(MUMPS_${comp}_lib NAMES ${comp}mumps DOC "MUMPS precision-specific")
  endif()

  if(NOT MUMPS_${comp}_lib)
    message(WARNING "MUMPS ${comp} not found")
    return()
  endif()

  set(MUMPS_${comp}_FOUND true PARENT_SCOPE)
  list(APPEND MUMPS_LIBRARY ${MUMPS_${comp}_lib})
endforeach()

set(MUMPS_LIBRARY ${MUMPS_LIBRARY} ${MUMPS_COMMON} ${PORD} PARENT_SCOPE)
set(MUMPS_INCLUDE_DIR ${MUMPS_INCLUDE_DIR} PARENT_SCOPE)

endfunction(mumps_libs)

# --- main

if(NOT MUMPS_FIND_COMPONENTS)
  set(MUMPS_FIND_COMPONENTS d)
endif()

mumps_libs()

if(MUMPS_LIBRARY AND MUMPS_INCLUDE_DIR)
# --- external MUMPS components
set(_test_lib)

if(METIS IN_LIST MUMPS_FIND_COMPONENTS)
  find_package(METIS)
  list(APPEND _test_lib METIS::METIS)
endif()

if(Scotch IN_LIST MUMPS_FIND_COMPONENTS)
  find_package(Scotch COMPONENTS ESMUMPS)
  list(APPEND _test_lib Scotch::Scotch)
endif()

if(OpenMP IN_LIST MUMPS_FIND_COMPONENTS)
  find_package(OpenMP COMPONENTS C Fortran)
  list(APPEND _test_lib OpenMP::OpenMP_Fortran OpenMP::OpenMP_C)
endif()

# -- minimal check that MUMPS is linkable

mumps_check()

endif(MUMPS_LIBRARY AND MUMPS_INCLUDE_DIR)
# --- finalize

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(MUMPS
  REQUIRED_VARS MUMPS_LIBRARY MUMPS_INCLUDE_DIR MUMPS_links
  HANDLE_COMPONENTS)

if(MUMPS_FOUND)
# need if _FOUND guard to allow project to autobuild; can't overwrite imported target even if bad
set(MUMPS_LIBRARIES ${MUMPS_LIBRARY})
set(MUMPS_INCLUDE_DIRS ${MUMPS_INCLUDE_DIR})
if(mpiseq IN_LIST MUMPS_FIND_COMPONENTS)
  list(APPEND MUMPS_LIBRARIES ${MUMPS_mpiseq_LIB})
  list(APPEND MUMPS_INCLUDE_DIRS ${MUMPS_mpiseq_INC})
endif()

if(NOT TARGET MUMPS::MUMPS)
  add_library(MUMPS::MUMPS INTERFACE IMPORTED)
  set_target_properties(MUMPS::MUMPS PROPERTIES
    INTERFACE_LINK_LIBRARIES "${MUMPS_LIBRARY}"
    INTERFACE_INCLUDE_DIRECTORIES "${MUMPS_INCLUDE_DIR}")
  if(METIS_FOUND)
    target_link_libraries(MUMPS::MUMPS INTERFACE METIS::METIS)
  endif()
  if(Scotch_FOUND)
    target_link_libraries(MUMPS::MUMPS INTERFACE Scotch::Scotch)
  endif()
  if(OpenMP_FOUND)
    target_link_libraries(MUMPS::MUMPS INTERFACE OpenMP::OpenMP_Fortran OpenMP::OpenMP_C)
  endif()
endif()

if(mpiseq IN_LIST MUMPS_FIND_COMPONENTS)
  if(NOT TARGET MUMPS::MPISEQ)
    add_library(MUMPS::MPISEQ INTERFACE IMPORTED)
    set_target_properties(MUMPS::MPISEQ PROPERTIES
      INTERFACE_LINK_LIBRARIES "${MUMPS_mpiseq_LIB}"
      INTERFACE_INCLUDE_DIRECTORIES "${MUMPS_mpiseq_INC}")
  endif()
endif()

endif(MUMPS_FOUND)

mark_as_advanced(MUMPS_INCLUDE_DIR MUMPS_LIBRARY)
