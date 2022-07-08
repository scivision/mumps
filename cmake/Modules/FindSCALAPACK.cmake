# Distributed under the OSI-approved BSD 3-Clause License.  See accompanying
# file Copyright.txt or https://cmake.org/licensing for details.

#[=======================================================================[.rst:

FindSCALAPACK
-------------

by Michael Hirsch, Ph.D. www.scivision.dev

Finds SCALAPACK libraries for MKL, OpenMPI and MPICH.
Intel MKL relies on having environment variable MKLROOT set, typically by sourcing
mklvars.sh beforehand.

This module does NOT find LAPACK.

Parameters
^^^^^^^^^^

``MKL``
  Intel MKL for MSVC, oneAPI, GCC.
  Working with IntelMPI (default Window, Linux), MPICH (default Mac) or OpenMPI (Linux only).

``MKL64``
  MKL only: 64-bit integers  (default is 32-bit integers)

Result Variables
^^^^^^^^^^^^^^^^

``SCALAPACK_FOUND``
  SCALapack libraries were found
``SCALAPACK_<component>_FOUND``
  SCALAPACK <component> specified was found
``SCALAPACK_LIBRARIES``
  SCALapack library files
``SCALAPACK_INCLUDE_DIRS``
  SCALapack include directories


References
^^^^^^^^^^

* Pkg-Config and MKL:  https://software.intel.com/en-us/articles/intel-math-kernel-library-intel-mkl-and-pkg-config-tool
* MKL for Windows: https://software.intel.com/en-us/mkl-windows-developer-guide-static-libraries-in-the-lib-intel64-win-directory
* MKL Windows directories: https://software.intel.com/en-us/mkl-windows-developer-guide-high-level-directory-structure
* MKL link-line advisor: https://software.intel.com/en-us/articles/intel-mkl-link-line-advisor
#]=======================================================================]

include(CheckSourceCompiles)

set(SCALAPACK_LIBRARY)  # avoids appending to prior FindScalapack

#===== functions

function(scalapack_check)

find_package(MPI COMPONENTS C Fortran)
if(NOT LAPACK_FOUND)
  # otherwise can cause 32-bit lapack when 64-bit wanted
  find_package(LAPACK)
endif()
if(NOT (MPI_Fortran_FOUND AND LAPACK_FOUND))
  return()
endif()


set(CMAKE_REQUIRED_FLAGS)
set(CMAKE_REQUIRED_LINK_OPTIONS)
set(CMAKE_REQUIRED_INCLUDES ${SCALAPACK_INCLUDE_DIR})
set(CMAKE_REQUIRED_LIBRARIES ${SCALAPACK_LIBRARY})
if(BLACS_LIBRARY)
  list(APPEND CMAKE_REQUIRED_LIBRARIES ${BLACS_LIBRARY})
endif()
list(APPEND CMAKE_REQUIRED_LIBRARIES LAPACK::LAPACK MPI::MPI_Fortran)

# MPI needed for ifort

check_source_compiles(Fortran
"program test
use, intrinsic :: iso_fortran_env, only : real64
implicit none (type, external)
real(real64), external :: pdlamch
integer :: ictxt
print *, pdlamch(ictxt, 'E')
end program"
SCALAPACK_d_FOUND
)

check_source_compiles(Fortran
"program test
use, intrinsic :: iso_fortran_env, only : real32
implicit none (type, external)
real(real32), external :: pslamch
integer :: ictxt
print *, pslamch(ictxt, 'E')
end program"
SCALAPACK_s_FOUND
)

if(SCALAPACK_s_FOUND OR SCALAPACK_d_FOUND)
  set(SCALAPACK_links true PARENT_SCOPE)
endif()

endfunction(scalapack_check)


function(scalapack_mkl scalapack_name blacs_name)

find_library(SCALAPACK_LIBRARY
NAMES ${scalapack_name}
HINTS ${MKLROOT}
PATH_SUFFIXES lib lib/intel64
NO_DEFAULT_PATH
)

find_library(BLACS_LIBRARY
NAMES ${blacs_name}
HINTS ${MKLROOT}
PATH_SUFFIXES lib lib/intel64
NO_DEFAULT_PATH
)

find_path(SCALAPACK_INCLUDE_DIR
NAMES mkl_scalapack.h
HINTS ${MKLROOT}
PATH_SUFFIXES include
NO_DEFAULT_PATH
)

# pc_mkl_INCLUDE_DIRS on Windows injects breaking garbage

if(SCALAPACK_LIBRARY AND BLACS_LIBRARY AND SCALAPACK_INCLUDE_DIR)
  set(SCALAPACK_MKL_FOUND true PARENT_SCOPE)
endif()

endfunction(scalapack_mkl)

# === main

set(scalapack_cray false)
if(DEFINED ENV{CRAYPE_VERSION})
  set(scalapack_cray true)
endif()

if(NOT scalapack_cray)
  if(NOT MKL IN_LIST SCALAPACK_FIND_COMPONENTS AND DEFINED ENV{MKLROOT})
    list(APPEND SCALAPACK_FIND_COMPONENTS MKL)
  endif()
endif()

if(MKL IN_LIST SCALAPACK_FIND_COMPONENTS)
  # we have to sanitize MKLROOT if it has Windows backslashes (\) otherwise it will break at build time
  # double-quotes are necessary per CMake to_cmake_path docs.
  file(TO_CMAKE_PATH "$ENV{MKLROOT}" MKLROOT)

  if(MKL64 IN_LIST SCALAPACK_FIND_COMPONENTS)
    set(_mkl_bitflag i)
  else()
    set(_mkl_bitflag)
  endif()

  # find MKL MPI binding
  if(WIN32)
    if(BUILD_SHARED_LIBS)
      scalapack_mkl(mkl_scalapack_${_mkl_bitflag}lp64_dll mkl_blacs_${_mkl_bitflag}lp64_dll)
    else()
      scalapack_mkl(mkl_scalapack_${_mkl_bitflag}lp64 mkl_blacs_intelmpi_${_mkl_bitflag}lp64)
    endif()
  elseif(APPLE)
    scalapack_mkl(mkl_scalapack_${_mkl_bitflag}lp64 mkl_blacs_mpich_${_mkl_bitflag}lp64)
  else()
    scalapack_mkl(mkl_scalapack_${_mkl_bitflag}lp64 mkl_blacs_intelmpi_${_mkl_bitflag}lp64)
  endif()

  if(MKL64 IN_LIST SCALAPACK_FIND_COMPONENTS)
    set(SCALAPACK_MKL64_FOUND ${SCALAPACK_MKL_FOUND})
  endif()

elseif(scalapack_cray)
  # Cray PE has Scalapack build into LibSci. Use Cray compiler wrapper.
else()

  find_library(SCALAPACK_LIBRARY
  NAMES scalapack scalapack-openmpi scalapack-mpich
  NAMES_PER_DIR
  PATH_SUFFIXES openmpi/lib mpich/lib
  )

  # some systems have libblacs as a separate file, instead of being subsumed in libscalapack.
  get_filename_component(BLACS_ROOT ${SCALAPACK_LIBRARY} DIRECTORY)

  find_library(BLACS_LIBRARY
  NAMES blacs
  NO_DEFAULT_PATH
  HINTS ${BLACS_ROOT}
  )

endif()

# --- Check that Scalapack links

if(scalapack_cray OR SCALAPACK_LIBRARY)
  scalapack_check()
endif()

# --- Finalize

include(FindPackageHandleStandardArgs)

if(scalapack_cray)
  find_package_handle_standard_args(SCALAPACK HANDLE_COMPONENTS
  REQUIRED_VARS SCALAPACK_links
  )
else()
  find_package_handle_standard_args(SCALAPACK HANDLE_COMPONENTS
  REQUIRED_VARS SCALAPACK_LIBRARY SCALAPACK_links
  )
endif()

if(SCALAPACK_FOUND)
  # need if _FOUND guard as can't overwrite imported target even if bad
  set(SCALAPACK_LIBRARIES ${SCALAPACK_LIBRARY})
  if(BLACS_LIBRARY)
    list(APPEND SCALAPACK_LIBRARIES ${BLACS_LIBRARY})
  endif()
  set(SCALAPACK_INCLUDE_DIRS ${SCALAPACK_INCLUDE_DIR})

  if(NOT TARGET SCALAPACK::SCALAPACK)
    add_library(SCALAPACK::SCALAPACK INTERFACE IMPORTED)
    set_target_properties(SCALAPACK::SCALAPACK PROPERTIES
    INTERFACE_LINK_LIBRARIES "${SCALAPACK_LIBRARIES}"
    INTERFACE_INCLUDE_DIRECTORIES "${SCALAPACK_INCLUDE_DIR}"
    )
  endif()
endif()

mark_as_advanced(SCALAPACK_LIBRARY SCALAPACK_INCLUDE_DIR)
