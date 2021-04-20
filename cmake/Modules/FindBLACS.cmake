# Distributed under the OSI-approved BSD 3-Clause License.  See accompanying
# file Copyright.txt or https://cmake.org/licensing for details.

#[=======================================================================[.rst:

FindBLACS
---------

by Michael Hirsch, Ph.D. www.scivision.dev

Finds BLACS libraries for MKL, OpenMPI and MPICH.
Intel MKL relies on having environment variable MKLROOT set, typically by sourcing
mklvars.sh beforehand.
Intended to work with Intel MKL at least through version 2021.

This module does NOT find LAPACK.

Parameters
^^^^^^^^^^

``MKL``
  Intel MKL for MSVC, ICL, ICC, GCC and PGCC. Working with IntelMPI (default Window, Linux), MPICH (default Mac) or OpenMPI (Linux only).

``OpenMPI``
  OpenMPI interface

``MPICH``
  MPICH interface


Result Variables
^^^^^^^^^^^^^^^^

``BLACS_FOUND``
  BLACS libraries were found
``BLACS_<component>_FOUND``
  BLACS <component> specified was found
``BLACS_LIBRARIES``
  BLACS library files
``BLACS_INCLUDE_DIRS``
  BLACS include directories


References
^^^^^^^^^^

* Pkg-Config and MKL:  https://software.intel.com/en-us/articles/intel-math-kernel-library-intel-mkl-and-pkg-config-tool
* MKL for Windows: https://software.intel.com/en-us/mkl-windows-developer-guide-static-libraries-in-the-lib-intel64-win-directory
* MKL Windows directories: https://software.intel.com/en-us/mkl-windows-developer-guide-high-level-directory-structure
* MKL link-line advisor: https://software.intel.com/en-us/articles/intel-mkl-link-line-advisor
#]=======================================================================]

set(BLACS_LIBRARY)  # don't endlessly append

#===== functions

function(blacs_mkl)

set(_mkl_libs ${ARGV})

foreach(s ${_mkl_libs})
  find_library(BLACS_${s}_LIBRARY
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
           HINTS ${MKL_LIBRARY_DIRS} ${MKL_LIBDIR}
           NO_DEFAULT_PATH)
  if(NOT BLACS_${s}_LIBRARY)
    message(STATUS "MKL component not found: " ${s})
    return()
  endif()

  list(APPEND BLACS_LIBRARY ${BLACS_${s}_LIBRARY})
endforeach()


find_path(BLACS_INCLUDE_DIR
  NAMES mkl_blacs.h
  PATHS
    ${MKLROOT}
    ENV I_MPI_ROOT
    ENV TBBROOT
  PATH_SUFFIXES
    include
    include/intel64/lp64
  HINTS ${MKL_INCLUDE_DIRS})

if(NOT BLACS_INCLUDE_DIR)
  message(STATUS "MKL Include Dir not found")
  return()
endif()

list(APPEND BLACS_INCLUDE_DIR ${MKL_INCLUDE_DIRS})

set(BLACS_MKL_FOUND true PARENT_SCOPE)
set(BLACS_LIBRARY ${BLACS_LIBRARY} PARENT_SCOPE)
set(BLACS_INCLUDE_DIR ${BLACS_INCLUDE_DIR} PARENT_SCOPE)

endfunction(blacs_mkl)


function(nonmkl)

if(MPICH IN_LIST BLACS_FIND_COMPONENTS)

find_library(BLACS_LIBRARY
              NAMES blacs-mpich blacs-mpich2
              NAMES_PER_DIR)
if(BLACS_LIBRARY)
  set(BLACS_MPICH_FOUND true PARENT_SCOPE)
endif()

elseif(LAM IN_LIST BLACS_FIND_COMPONENTS)

find_library(BLACS_LIBRARY
              NAMES blacs-lam
              NAMES_PER_DIR)
if(BLACS_LIBRARY)
  set(BLACS_LAM_FOUND true PARENT_SCOPE)
endif()

elseif(PVM IN_LIST BLACS_FIND_COMPONENTS)

find_library(BLACS_LIBRARY
              NAMES blacs-pvm
              NAMES_PER_DIR)
if(BLACS_LIBRARY)
  set(BLACS_PVM_FOUND true PARENT_SCOPE)
endif()

elseif(OpenMPI IN_LIST BLACS_FIND_COMPONENTS)

find_library(BLACS_INIT
  NAMES blacsF77init blacsF77init-openmpi
  NAMES_PER_DIR)
if(BLACS_INIT)
  list(APPEND BLACS_LIBRARY ${BLACS_INIT})
endif()

find_library(BLACS_CINIT
  NAMES blacsCinit blacsCinit-openmpi
  NAMES_PER_DIR)
if(BLACS_CINIT)
  list(APPEND BLACS_LIBRARY ${BLACS_CINIT})
endif()

# this is the only lib that scalapack/blacs/src provides
find_library(BLACS_LIB
  NAMES blacs blacs-mpi blacs-openmpi
  NAMES_PER_DIR)
if(BLACS_LIB)
  list(APPEND BLACS_LIBRARY ${BLACS_LIB})
endif()

if(BLACS_LIBRARY)
  set(BLACS_OpenMPI_FOUND true PARENT_SCOPE)
endif()

endif()

set(BLACS_LIBRARY ${BLACS_LIBRARY} PARENT_SCOPE)

endfunction(nonmkl)

# === main

if(NOT (OpenMPI IN_LIST BLACS_FIND_COMPONENTS
        OR MPICH IN_LIST BLACS_FIND_COMPONENTS
        OR MKL IN_LIST BLACS_FIND_COMPONENTS))
if(DEFINED ENV{MKLROOT})
  list(APPEND BLACS_FIND_COMPONENTS MKL)
  if(APPLE)
    list(APPEND BLACS_FIND_COMPONENTS MPICH)
  endif()
else()
  list(APPEND BLACS_FIND_COMPONENTS OpenMPI)
endif()
endif()

find_package(PkgConfig)

set(BLACS_INCLUDE_DIR)

if(MKL IN_LIST BLACS_FIND_COMPONENTS)
  # we have to sanitize MKLROOT if it has Windows backslashes (\) otherwise it will break at build time
  # double-quotes are necessary per CMake to_cmake_path docs.
  file(TO_CMAKE_PATH "$ENV{MKLROOT}" MKLROOT)

  list(APPEND CMAKE_PREFIX_PATH ${MKLROOT}/tools/pkgconfig)

  if(BUILD_SHARED_LIBS)
    set(_mkltype dynamic)
  else()
    set(_mkltype static)
  endif()

  pkg_check_modules(MKL mkl-${_mkltype}-lp64-iomp)

  if(OpenMPI IN_LIST BLACS_FIND_COMPONENTS)
    blacs_mkl(mkl_blacs_openmpi_lp64)
    set(BLACS_OpenMPI_FOUND ${BLACS_MKL_FOUND})
  elseif(MPICH IN_LIST BLACS_FIND_COMPONENTS)
    if(APPLE)
      blacs_mkl(mkl_blacs_mpich_lp64)
    elseif(WIN32)
      blacs_mkl(mkl_blacs_mpich2_lp64.lib mpi.lib fmpich2.lib)
    else()  # MPICH linux is just like IntelMPI
      blacs_mkl(mkl_blacs_intelmpi_lp64)
    endif()
    set(BLACS_MPICH_FOUND ${BLACS_MKL_FOUND})
  else()
    blacs_mkl(mkl_blacs_intelmpi_lp64)
  endif()

else(MKL IN_LIST BLACS_FIND_COMPONENTS)

  nonmkl()

endif(MKL IN_LIST BLACS_FIND_COMPONENTS)

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(BLACS
  REQUIRED_VARS BLACS_LIBRARY
  HANDLE_COMPONENTS)

if(BLACS_FOUND)
# need if _FOUND guard to allow project to autobuild; can't overwrite imported target even if bad
set(BLACS_INCLUDE_DIRS ${BLACS_INCLUDE_DIR})
set(BLACS_LIBRARIES ${BLACS_LIBRARY})

if(NOT TARGET BLACS::BLACS)
  add_library(BLACS::BLACS INTERFACE IMPORTED)
  set_target_properties(BLACS::BLACS PROPERTIES
                        INTERFACE_LINK_LIBRARIES "${BLACS_LIBRARY}"
                        INTERFACE_INCLUDE_DIRECTORIES "${BLACS_INCLUDE_DIR}"
                      )
endif()
endif(BLACS_FOUND)

mark_as_advanced(BLACS_LIBRARY BLACS_INCLUDE_DIR)
