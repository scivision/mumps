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
  Intel MKL for MSVC, ICL, ICC, GCC and PGCC. Working with IntelMPI (default Window, Linux), MPICH (default Mac) or OpenMPI (Linux only).

``MKL64``
  MKL only: 64-bit integers  (default is 32-bit integers)

``OpenMPI``
  OpenMPI interface

``MPICH``
  MPICH interface


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

set(SCALAPACK_LIBRARY)  # avoids appending to prior FindScalapack
set(SCALAPACK_INCLUDE_DIR)

#===== functions

function(scalapack_check)

find_package(MPI COMPONENTS C Fortran)

if(NOT TARGET LAPACK::LAPACK)
  find_package(LAPACK)
  if(NOT (MPI_Fortran_FOUND AND LAPACK_FOUND))
    return()
  endif()
endif()

set(CMAKE_REQUIRED_FLAGS)
set(CMAKE_REQUIRED_LINK_OPTIONS)
set(CMAKE_REQUIRED_INCLUDES ${SCALAPACK_INCLUDE_DIR})
set(CMAKE_REQUIRED_LIBRARIES ${SCALAPACK_LIBRARY} ${BLACS_LIBRARY} LAPACK::LAPACK MPI::MPI_Fortran MPI::MPI_C)
# MPI needed for ifort
include(CheckFortranSourceCompiles)

set(SCALAPACK_links true)

foreach(i s d c z)

if("${i}" IN_LIST SCALAPACK_FIND_COMPONENTS)

  check_fortran_source_compiles("
  program test
  implicit none (type, external)
  external :: p${i}lamch
  external :: blacs_pinfo, blacs_get, blacs_gridinit, blacs_gridexit, blacs_exit
  end program"
    SCALAPACK_${i}_links SRC_EXT f90)

  if(SCALAPACK_${i}_links)
    set(SCALAPACK_${i}_FOUND true PARENT_SCOPE)
  else()
    set(SCALAPACK_links false)
  endif()
endif()

endforeach()

set(SCALAPACK_links ${SCALAPACK_links} PARENT_SCOPE)

endfunction(scalapack_check)


function(scalapack_mkl)

if(BUILD_SHARED_LIBS)
  set(_mkltype dynamic)
else()
  set(_mkltype static)
endif()

if(NOT WIN32)
  # Windows oneAPI crashes here due to bad *.pc
  pkg_check_modules(pc_mkl mkl-${_mkltype}-${_mkl_bitflag}lp64-iomp)
endif()

set(_mkl_libs ${ARGV})

foreach(s ${_mkl_libs})
  find_library(SCALAPACK_${s}_LIBRARY
           NAMES ${s}
           NAMES_PER_DIR
           PATHS
            ${MKLROOT}
            ENV I_MPI_ROOT
            ENV TBBROOT
            ../tbb/lib/intel64/gcc4.7
            ../tbb/lib/intel64/vc_mt
            ../compiler/lib/intel64
           PATH_SUFFIXES
             lib lib/intel64 lib/intel64_win
             intel64/lib/release
             lib/intel64/gcc4.7
             lib/intel64/vc_mt
           HINTS ${pc_mkl_LIBRARY_DIRS} ${pc_mkl_LIBDIR}
           NO_DEFAULT_PATH)
  if(NOT SCALAPACK_${s}_LIBRARY)
    message(STATUS "MKL component not found: " ${s})
    return()
  endif()

  list(APPEND SCALAPACK_LIBRARY ${SCALAPACK_${s}_LIBRARY})
endforeach()


find_path(SCALAPACK_INCLUDE_DIR
  NAMES mkl_scalapack.h
  PATHS ${MKLROOT} ENV I_MPI_ROOT ENV TBBROOT
  PATH_SUFFIXES
    include
    include/intel64/${_mkl_bitflag}lp64
  HINTS ${pc_mkl_INCLUDE_DIRS})

if(NOT SCALAPACK_INCLUDE_DIR)
  message(STATUS "MKL Include Dir not found")
  return()
endif()

# pc_mkl_INCLUDE_DIRS on Windows injects breaking garbage

set(SCALAPACK_MKL_FOUND true PARENT_SCOPE)
set(SCALAPACK_LIBRARY ${SCALAPACK_LIBRARY} PARENT_SCOPE)
set(SCALAPACK_INCLUDE_DIR ${SCALAPACK_INCLUDE_DIR} PARENT_SCOPE)

endfunction(scalapack_mkl)

# === main

if(NOT (OpenMPI IN_LIST SCALAPACK_FIND_COMPONENTS
        OR MPICH IN_LIST SCALAPACK_FIND_COMPONENTS
        OR MKL IN_LIST SCALAPACK_FIND_COMPONENTS))
if(DEFINED ENV{MKLROOT})
  list(APPEND SCALAPACK_FIND_COMPONENTS MKL)
  if(APPLE)
    list(APPEND SCALAPACK_FIND_COMPONENTS MPICH)
  endif()
else()
  list(APPEND SCALAPACK_FIND_COMPONENTS OpenMPI)
endif()
endif()

find_package(PkgConfig)

# some systems (Ubuntu 16.04) need BLACS explicitly, when it isn't statically compiled into libscalapack

if(NOT MKL IN_LIST SCALAPACK_FIND_COMPONENTS)
  find_package(BLACS QUIET)
  if(NOT BLACS_FOUND)
    set(BLACS_LIBRARY)
    set(BLACS_INCLUDE_DIR)
  endif()
endif()

if(MKL IN_LIST SCALAPACK_FIND_COMPONENTS)
  # we have to sanitize MKLROOT if it has Windows backslashes (\) otherwise it will break at build time
  # double-quotes are necessary per CMake to_cmake_path docs.
  file(TO_CMAKE_PATH "$ENV{MKLROOT}" MKLROOT)

  list(APPEND CMAKE_PREFIX_PATH ${MKLROOT}/tools/pkgconfig)

  if(MKL64 IN_LIST SCALAPACK_FIND_COMPONENTS)
    set(_mkl_bitflag i)
  else()
    set(_mkl_bitflag)
  endif()

  if(OpenMPI IN_LIST SCALAPACK_FIND_COMPONENTS)
    scalapack_mkl(mkl_scalapack_${_mkl_bitflag}lp64 mkl_blacs_openmpi_${_mkl_bitflag}lp64)
    set(SCALAPACK_OpenMPI_FOUND ${SCALAPACK_MKL_FOUND})
  elseif(MPICH IN_LIST SCALAPACK_FIND_COMPONENTS)
    if(APPLE)
      scalapack_mkl(mkl_scalapack_${_mkl_bitflag}lp64 mkl_blacs_mpich_${_mkl_bitflag}lp64)
    elseif(WIN32)
      scalapack_mkl(mkl_scalapack_${_mkl_bitflag}lp64 mkl_blacs_mpich2_${_mkl_bitflag}lp64.lib mpi.lib fmpich2.lib)
    else()  # MPICH linux is just like IntelMPI
      scalapack_mkl(mkl_scalapack_${_mkl_bitflag}lp64 mkl_blacs_intelmpi_${_mkl_bitflag}lp64)
    endif()
    set(SCALAPACK_MPICH_FOUND ${SCALAPACK_MKL_FOUND})
  else()
    scalapack_mkl(mkl_scalapack_${_mkl_bitflag}lp64 mkl_blacs_intelmpi_${_mkl_bitflag}lp64)
  endif()

  if(MKL64 IN_LIST SCALAPACK_FIND_COMPONENTS)
    set(SCALAPACK_MKL64_FOUND ${SCALAPACK_MKL_FOUND})
  endif()

elseif(OpenMPI IN_LIST SCALAPACK_FIND_COMPONENTS)

  pkg_search_module(pc_scalapack scalapack-openmpi scalapack)

  find_library(SCALAPACK_LIBRARY
                NAMES scalapack-openmpi scalapack
                NAMES_PER_DIR
                HINTS ${pc_scalapack_LIBRARY_DIRS} ${pc_scalapack_LIBDIR})

  if(SCALAPACK_LIBRARY)
    set(SCALAPACK_OpenMPI_FOUND true)
  endif()

elseif(MPICH IN_LIST SCALAPACK_FIND_COMPONENTS)

  pkg_search_module(pc_scalapack scalapack-mpich scalapack)

  find_library(SCALAPACK_LIBRARY
                NAMES scalapack-mpich scalapack-mpich2
                NAMES_PER_DIR
                HINTS ${pc_scalapack_LIBRARY_DIRS} ${pc_scalapack_LIBDIR})

  if(SCALAPACK_LIBRARY)
    set(SCALAPACK_MPICH_FOUND true)
  endif()

endif()

# --- Check that Scalapack links

if(SCALAPACK_LIBRARY)
  scalapack_check()
endif()

# --- Finalize

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(SCALAPACK
  REQUIRED_VARS SCALAPACK_LIBRARY SCALAPACK_links
  HANDLE_COMPONENTS)

if(SCALAPACK_FOUND)
# need if _FOUND guard to allow project to autobuild; can't overwrite imported target even if bad
set(SCALAPACK_LIBRARIES ${SCALAPACK_LIBRARY})
set(SCALAPACK_INCLUDE_DIRS ${SCALAPACK_INCLUDE_DIR})

if(BLACS_FOUND)
  list(APPEND SCALAPACK_LIBRARIES ${BLACS_LIBRARIES})
  if(NOT TARGET SCALAPACK::BLACS)
    add_library(SCALAPACK::BLACS INTERFACE IMPORTED)
    set_target_properties(SCALAPACK::BLACS PROPERTIES
                          INTERFACE_LINK_LIBRARIES "${BLACS_LIBRARY}"
                          INTERFACE_INCLUDE_DIRECTORIES "${BLACS_INCLUDE_DIR}"
                        )
  endif()
endif()

if(NOT TARGET SCALAPACK::SCALAPACK)
  add_library(SCALAPACK::SCALAPACK INTERFACE IMPORTED)
  set_target_properties(SCALAPACK::SCALAPACK PROPERTIES
                        INTERFACE_LINK_LIBRARIES "${SCALAPACK_LIBRARY};${BLACS_LIBRARY}"
                        INTERFACE_INCLUDE_DIRECTORIES "${SCALAPACK_INCLUDE_DIR}"
                      )
endif()
endif(SCALAPACK_FOUND)

mark_as_advanced(SCALAPACK_LIBRARY SCALAPACK_INCLUDE_DIR)
