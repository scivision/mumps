# Distributed under the OSI-approved BSD 3-Clause License.  See accompanying
# file Copyright.txt or https://cmake.org/licensing for details.

#[=======================================================================[.rst:
FindMPI
-------

by Michael Hirsch www.scivision.dev

Finds compiler flags or library necessary to use MPI library (MPICH, OpenMPI, MS-MPI, Intel MPI, ...)

Components
==========

MPI code languages are specified by components:

``C``
  C interface for MPI--all MPI libraries have this. Default.

``CXX``
  C++ interface for MPI (not all MPI libraries have C++ interface)

``Fortran``
  Fortran interface for interface for MPI (some MPI libraries don't build this by default)


Result Variables
^^^^^^^^^^^^^^^^

``MPI_FOUND``
  indicates MPI library found

``MPI_LIBRARIES``
  MPI library path

``MPI_INCLUDE_DIRS``
  MPI include path

``MPI_<LANG>_LIBRARIES``
  libraries for <LANG>

``MPI_<LANG>_INCLUDE_DIRS``
  include dirs for <LANG>

``MPI_<LANG>_LINK_FLAGS``
  link flags for <LANG>

``MPI_Fortran_HAVE_F90_MODULE``
  has MPI-2 Fortran 90 interface

``MPI_Fortran_HAVE_F08_MODULE``
  has MPI-3 Fortran 2008 interface

Imported Targets
^^^^^^^^^^^^^^^^

``MPI::MPI_<LANG>``
  imported target for <LANG>  e.g. ``MPI::MPI_C`` or ``MPI::MPI_Fortran``




#]=======================================================================]
include(CheckFortranSourceCompiles)
include(CheckCSourceCompiles)
include(CheckCXXSourceCompiles)

set(CMAKE_REQUIRED_FLAGS)
set(_hints)
set(_hints_inc)


function(get_flags exec outvar)

execute_process(COMMAND ${exec} -show
OUTPUT_STRIP_TRAILING_WHITESPACE
OUTPUT_VARIABLE ret
RESULT_VARIABLE code
TIMEOUT 10
)
if(NOT code EQUAL 0)
  return()
endif()

set(${outvar} ${ret} PARENT_SCOPE)

endfunction(get_flags)


function(get_link_flags raw outvar)


string(REGEX MATCHALL "(^| )(${CMAKE_LIBRARY_PATH_FLAG})([^\" ]+|\"[^\"]+\")" _Lflags "${raw}")
list(TRANSFORM _Lflags STRIP)
set(_flags ${_Lflags})

string(REGEX MATCHALL "(^| )(-Wl,)([^\" ]+|\"[^\"]+\")" _Wflags "${raw}")
list(TRANSFORM _Wflags STRIP)
if(_Wflags)
  set(CMAKE_C_LINKER_WRAPPER_FLAG "-Wl,")
  set(CMAKE_C_LINKER_WRAPPER_FLAG_SEP ",")
  set(CMAKE_CXX_LINKER_WRAPPER_FLAG "-Wl,")
  set(CMAKE_CXX_LINKER_WRAPPER_FLAG_SEP ",")
  set(CMAKE_Fortran_LINKER_WRAPPER_FLAG "-Wl,")
  set(CMAKE_Fortran_LINKER_WRAPPER_FLAG_SEP ",")
  list(APPEND _flags ${_Wflags})
else()
  pop_flag("${raw}" -Xlinker _Xflags)
  if(_Xflags)
    set(CMAKE_C_LINKER_WRAPPER_FLAG "-Xlinker" " ")
    set(CMAKE_CXX_LINKER_WRAPPER_FLAG "-Xlinker" " ")
    set(CMAKE_Fortran_LINKER_WRAPPER_FLAG "-Xlinker" " ")
    string(REPLACE ";" "," _Xflags "${_Xflags}")
    list(APPEND _flags "LINKER:${_Xflags}")
  endif()
endif()

string(REPLACE ";" " " _flags "${_flags}")

set(${outvar} ${_flags} PARENT_SCOPE)

endfunction(get_link_flags)


function(pop_flag raw flag outvar)
# this gives the argument to flags to get their paths like -I or -l or -L

set(_v)
string(REGEX MATCHALL "(^| )${flag} *([^\" ]+|\"[^\"]+\")" _vars "${raw}")
foreach(_p IN LISTS _vars)
  string(REGEX REPLACE "(^| )${flag} *" "" _p "${_p}")
  list(APPEND _v "${_p}")
endforeach()

set(${outvar} ${_v} PARENT_SCOPE)

endfunction(pop_flag)


function(pop_path raw outvar)
# these are file paths without flags like /usr/lib/mpi.so

if(MSVC)
  return()
endif()

set(flag /)
set(_v)
string(REGEX MATCHALL "(^| )${flag} *([^\" ]+|\"[^\"]+\")" _vars "${raw}")
foreach(_p IN LISTS _vars)
  string(REGEX REPLACE "(^| )${flag} *" "" _p "${_p}")
  list(APPEND _v "/${_p}")
endforeach()

set(${outvar} ${_v} PARENT_SCOPE)

endfunction(pop_path)


function(find_c)

# mpich: mpi pmpi
# openmpi: mpi
# MS-MPI: msmpi
# Intel Windows: impi
# Intel MPI: mpi

set(MPI_C_LIBRARY)

if(WIN32)
  if(CMAKE_C_COMPILER_ID MATCHES Intel)
    set(names impi)
  else()
    set(names msmpi)
  endif()
elseif(DEFINED ENV{I_MPI_ROOT})
  set(names mpi)
else()
  set(names mpi pmpi)
endif()

if(NOT MPI_C_FOUND)
  pkg_search_module(pc_mpi_c ompi-c)
endif()

if(CMAKE_C_COMPILER_ID MATCHES Intel)
  set(wrap_name mpiicc mpiicc.bat)
else()
  set(wrap_name mpicc mpicc.openmpi mpicc.mpich)
endif()

find_program(c_wrap
  NAMES ${wrap_name}
  HINTS ${_hints}
  NAMES_PER_DIR
  PATHS /usr/lib64
  PATH_SUFFIXES bin openmpi/bin mpich/bin
  )
if(c_wrap)
  get_filename_component(_wrap_hint ${c_wrap} DIRECTORY)
  get_filename_component(_wrap_hint ${_wrap_hint} DIRECTORY)

  get_flags(${c_wrap} c_raw)
  if(c_raw)
    pop_flag(${c_raw} -I inc_dirs)
    pop_flag(${c_raw} ${CMAKE_LIBRARY_PATH_FLAG} lib_dirs)

    pop_flag(${c_raw} -l lib_names)
    if(lib_names)
      set(names ${lib_names})
    endif()

    pop_path(${c_raw} lib_paths)
    set(MPI_C_LIBRARY ${lib_paths})

    get_link_flags(${c_raw} MPI_C_LINK_FLAGS)
  endif(c_raw)
endif(c_wrap)

foreach(n ${names})

  find_library(MPI_C_${n}_LIBRARY
    NAMES ${n}
    HINTS ${lib_dirs} ${_wrap_hint} ${pc_mpi_c_LIBRARY_DIRS} ${pc_mpi_c_LIBDIR} ${_hints}
    PATH_SUFFIXES release openmpi/lib mpich/lib
  )
  if(MPI_C_${n}_LIBRARY)
    list(APPEND MPI_C_LIBRARY ${MPI_C_${n}_LIBRARY})
  endif()

endforeach()
if(NOT MPI_C_LIBRARY)
  return()
endif()

find_path(MPI_C_INCLUDE_DIR
  NAMES mpi.h
  HINTS ${inc_dirs} ${_wrap_hint} ${pc_mpi_c_INCLUDE_DIRS} ${_hints} ${_hints_inc}
  PATH_SUFFIXES openmpi-x86_64 mpich-x86_64
)
if(NOT MPI_C_INCLUDE_DIR)
  return()
endif()

set(CMAKE_REQUIRED_INCLUDES ${MPI_C_INCLUDE_DIR})
set(CMAKE_REQUIRED_LIBRARIES ${MPI_C_LIBRARY})
list(APPEND CMAKE_REQUIRED_LIBRARIES ${CMAKE_THREAD_LIBS_INIT})

check_c_source_compiles("
#include <mpi.h>
#ifndef NULL
#define NULL 0
#endif
int main(void) {
    MPI_Init(NULL, NULL);
    MPI_Finalize();
    return 0;}
" MPI_C_links)
if(NOT MPI_C_links)
  return()
endif()

set(MPI_C_INCLUDE_DIR ${MPI_C_INCLUDE_DIR} PARENT_SCOPE)
set(MPI_C_LIBRARY ${MPI_C_LIBRARY} PARENT_SCOPE)
set(MPI_C_LINK_FLAGS ${MPI_C_LINK_FLAGS} PARENT_SCOPE)
set(MPI_C_FOUND true PARENT_SCOPE)

endfunction(find_c)


function(find_cxx)

# mpich: mpi pmpi
# openmpi: mpi_cxx mpi
# MS-MPI: msmpi
# Intel Windows: impi
# Intel MPI: mpi

set(MPI_CXX_LIBRARY)

if(WIN32)
  if(CMAKE_CXX_COMPILER_ID MATCHES Intel)
    set(names impi)
  else()
    set(names msmpi)
  endif()
elseif(DEFINED ENV{I_MPI_ROOT})
  set(names mpi)
else()
  set(names
    mpi_cxx mpi
    mpichcxx mpi pmpi)
endif()

if(NOT MPI_CXX_FOUND)
  pkg_search_module(pc_mpi_cxx ompi-cxx)
endif()

if(CMAKE_CXX_COMPILER_ID MATCHES Intel)
  set(wrap_name mpiicpc mpiicpc.bat)
else()
  set(wrap_name mpicxx mpicxx.openmpi mpicxx.mpich)
endif()

find_program(cxx_wrap
  NAMES ${wrap_name}
  HINTS ${_hints}
  NAMES_PER_DIR
  PATHS /usr/lib64
  PATH_SUFFIXES bin openmpi/bin mpich/bin
  )
if(cxx_wrap)
  get_filename_component(_wrap_hint ${cxx_wrap} DIRECTORY)
  get_filename_component(_wrap_hint ${_wrap_hint} DIRECTORY)

  get_flags(${cxx_wrap} cxx_raw)
  if(cxx_raw)
    pop_flag(${cxx_raw} -I inc_dirs)
    pop_flag(${cxx_raw} ${CMAKE_LIBRARY_PATH_FLAG} lib_dirs)

    pop_flag(${cxx_raw} -l lib_names)
    if(lib_names)
      set(names ${lib_names})
    endif()

    pop_path(${cxx_raw} lib_paths)
    set(MPI_CXX_LIBRARY ${lib_paths})

    get_link_flags(${cxx_raw} MPI_CXX_LINK_FLAGS)
  endif(cxx_raw)
endif(cxx_wrap)

foreach(n ${names})

  find_library(MPI_CXX_${n}_LIBRARY
    NAMES ${n}
    HINTS ${lib_dirs} ${_wrap_hint} ${pc_mpi_cxx_LIBRARY_DIRS} ${pc_mpi_cxx_LIBDIR} ${_hints}
    PATH_SUFFIXES release openmpi/lib mpich/lib
  )
  if(MPI_CXX_${n}_LIBRARY)
    list(APPEND MPI_CXX_LIBRARY ${MPI_CXX_${n}_LIBRARY})
  endif()

endforeach()
if(NOT MPI_CXX_LIBRARY)
  return()
endif()

find_path(MPI_CXX_INCLUDE_DIR
  NAMES mpi.h
  HINTS ${inc_dirs} ${_wrap_hint} ${pc_mpi_cxx_INCLUDE_DIRS} ${_hints} ${_hints_inc}
  PATH_SUFFIXES openmpi-x86_64 mpich-x86_64
)
if(NOT MPI_CXX_INCLUDE_DIR)
  return()
endif()

set(CMAKE_REQUIRED_INCLUDES ${MPI_CXX_INCLUDE_DIR})
set(CMAKE_REQUIRED_LIBRARIES ${MPI_CXX_LIBRARY})
if(Threads_FOUND)
  list(APPEND CMAKE_REQUIRED_LIBRARIES Threads::Threads)
endif()
check_cxx_source_compiles("
#include <mpi.h>
#ifndef NULL
#define NULL 0
#endif
int main(void) {
    MPI_Init(NULL, NULL);
    MPI_Finalize();
    return 0;}
" MPI_CXX_links)
if(NOT MPI_CXX_links)
  return()
endif()

set(MPI_CXX_INCLUDE_DIR ${MPI_CXX_INCLUDE_DIR} PARENT_SCOPE)
set(MPI_CXX_LIBRARY ${MPI_CXX_LIBRARY} PARENT_SCOPE)
set(MPI_CXX_LINK_FLAGS ${MPI_CXX_LINK_FLAGS} PARENT_SCOPE)
set(MPI_CXX_FOUND true PARENT_SCOPE)

endfunction(find_cxx)


function(find_fortran)

# mpich: mpifort mpi pmpi
# openmpi: mpi_usempif08 mpi_usempi_ignore_tkr mpi_mpifh mpi
# MS-MPI: msmpi
# Intel Windows: impi
# Intel MPI: mpifort mpi

set(MPI_Fortran_LIBRARY)

if(WIN32)
  if(CMAKE_Fortran_COMPILER_ID MATCHES Intel)
    set(names impi)
  else()
    set(names msmpi)
  endif()
elseif(DEFINED ENV{I_MPI_ROOT})
  set(names mpifort mpi)
else()
  set(names
    mpi_usempif08 mpi_usempi_ignore_tkr mpi_mpifh mpi
    mpifort mpichfort mpi pmpi
    )
endif()

if(NOT MPI_Fortran_FOUND)
  pkg_search_module(pc_mpi_f ompi-fort)
endif()

if(CMAKE_Fortran_COMPILER_ID MATCHES Intel)
  set(wrap_name mpiifort mpiifort.bat)
else()
  set(wrap_name mpifort mpifc mpifort.openmpi mpifort.mpich)
endif()

find_program(f_wrap
  NAMES ${wrap_name}
  HINTS ${_hints}
  NAMES_PER_DIR
  PATHS /usr/lib64
  PATH_SUFFIXES bin openmpi/bin mpich/bin
  )
if(f_wrap)
  get_filename_component(_wrap_hint ${f_wrap} DIRECTORY)
  get_filename_component(_wrap_hint ${_wrap_hint} DIRECTORY)

  get_flags(${f_wrap} f_raw)
  if(f_raw)
    pop_flag(${f_raw} -I inc_dirs)
    pop_flag(${f_raw} ${CMAKE_LIBRARY_PATH_FLAG} lib_dirs)

    pop_flag(${f_raw} -l lib_names)
    if(lib_names)
      set(names ${lib_names})
    endif()

    pop_path(${f_raw} lib_paths)
    set(MPI_Fortran_LIBRARY ${lib_paths})

    get_link_flags(${f_raw} MPI_Fortran_LINK_FLAGS)
  endif(f_raw)
endif(f_wrap)

foreach(n ${names})

  find_library(MPI_Fortran_${n}_LIBRARY
    NAMES ${n}
    HINTS ${lib_dirs} ${_wrap_hint} ${pc_mpi_f_LIBRARY_DIRS} ${pc_mpi_f_LIBDIR} ${_hints}
    PATH_SUFFIXES release openmpi/lib mpich/lib
  )
  if(MPI_Fortran_${n}_LIBRARY)
    list(APPEND MPI_Fortran_LIBRARY ${MPI_Fortran_${n}_LIBRARY})
  endif()

endforeach()
if(NOT MPI_Fortran_LIBRARY)
  return()
endif()

set(_msuf)
if(CMAKE_Fortran_COMPILER_ID STREQUAL GNU)
  set(_msuf gfortran/modules/openmpi gfortran/modules/mpich)
endif()

find_path(MPI_Fortran_INCLUDE_DIR
  NAMES mpi.mod
  HINTS ${inc_dirs} ${_wrap_hint} ${pc_mpi_f_INCLUDE_DIRS} ${_hints} ${_hints_inc}
  PATH_SUFFIXES lib ${_msuf}
  # yes, openmpi puts .mod files into lib/
)
if(NOT MPI_Fortran_INCLUDE_DIR)
  return()
endif()

if(WIN32 AND NOT CMAKE_Fortran_COMPILER_ID MATCHES Intel)
  find_path(MPI_Fortran_INCLUDE_EXTRA
    NAMES mpifptr.h
    HINTS ${inc_dirs} ${_wrap_hint} ${pc_mpi_f_INCLUDE_DIRS} ${_hints} ${_hints_inc}
    PATH_SUFFIXES x64
  )

  if(MPI_Fortran_INCLUDE_EXTRA AND NOT MPI_Fortran_INCLUDE_EXTRA STREQUAL ${MPI_Fortran_INCLUDE_DIR})
    list(APPEND MPI_Fortran_INCLUDE_DIR ${MPI_Fortran_INCLUDE_EXTRA})
  endif()
endif()

set(CMAKE_REQUIRED_INCLUDES ${MPI_Fortran_INCLUDE_DIR})
set(CMAKE_REQUIRED_LIBRARIES ${MPI_Fortran_LIBRARY})
if(Threads_FOUND)
  list(APPEND CMAKE_REQUIRED_LIBRARIES Threads::Threads)
endif()

check_fortran_source_compiles("
program test
use mpi
implicit none
integer :: i
call mpi_init(i)
call mpi_finalize(i)
end program" MPI_Fortran_links SRC_EXT F90)
if(NOT MPI_Fortran_links)
  return()
endif()

check_fortran_source_compiles(
"program test
use mpi_f08, only : mpi_comm_rank, mpi_comm_world, mpi_init, mpi_finalize
end program"
MPI_Fortran_HAVE_F08_MODULE SRC_EXT f90)

set(MPI_Fortran_INCLUDE_DIR ${MPI_Fortran_INCLUDE_DIR} PARENT_SCOPE)
set(MPI_Fortran_LIBRARY ${MPI_Fortran_LIBRARY} PARENT_SCOPE)
set(MPI_Fortran_LINK_FLAGS ${MPI_Fortran_LINK_FLAGS} PARENT_SCOPE)
set(MPI_Fortran_HAVE_F90_MODULE true PARENT_SCOPE)
set(MPI_Fortran_HAVE_F08_MODULE ${MPI_Fortran_HAVE_F08_MODULE} PARENT_SCOPE)
set(MPI_Fortran_FOUND true PARENT_SCOPE)

endfunction(find_fortran)

#===== main program ======

find_package(PkgConfig)
find_package(Threads)

# Intel MPI, which works with non-Intel compilers on Linux
if((CMAKE_SYSTEM_NAME STREQUAL Linux OR CMAKE_C_COMPILER_ID MATCHES Intel) AND
      DEFINED ENV{I_MPI_ROOT})
  list(APPEND _hints $ENV{I_MPI_ROOT})
endif()

if(WIN32 AND NOT CMAKE_C_COMPILER_ID MATCHES Intel)
  list(APPEND _hints $ENV{MSMPI_LIB64})
  list(APPEND _hints_inc $ENV{MSMPI_INC})
endif()

# must have MPIexec to be worthwhile (de facto standard is mpiexec)
find_program(MPIEXEC_EXECUTABLE
  NAMES mpiexec mpirun orterun
  HINTS ${_hints} $ENV{MSMPI_BIN}
  PATHS /usr/lib64
  PATH_SUFFIXES bin openmpi/bin mpich/bin
)

# like factory FindMPI, always find MPI_C
if(NOT C IN_LIST MPI_FIND_COMPONENTS)
  list(APPEND MPI_FIND_COMPONENTS C)
endif()
find_c()

if(CXX IN_LIST MPI_FIND_COMPONENTS)
  find_cxx()
endif()

if(Fortran IN_LIST MPI_FIND_COMPONENTS)
  find_fortran()
endif()

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(MPI
  REQUIRED_VARS MPIEXEC_EXECUTABLE
  HANDLE_COMPONENTS)

if(MPI_C_FOUND)
  set(MPI_C_LIBRARIES ${MPI_C_LIBRARY})
  set(MPI_C_INCLUDE_DIRS ${MPI_C_INCLUDE_DIR})
  if(NOT TARGET MPI::MPI_C)
    add_library(MPI::MPI_C IMPORTED INTERFACE)
    set_target_properties(MPI::MPI_C PROPERTIES
      INTERFACE_LINK_LIBRARIES "${MPI_C_LIBRARIES}"
      INTERFACE_INCLUDE_DIRECTORIES "${MPI_C_INCLUDE_DIRS}"
    )
    if(MPI_C_LINK_FLAGS)
      set_target_properties(MPI::MPI_C PROPERTIES INTERFACE_LINK_OPTIONS "${MPI_C_LINK_FLAGS}")
    endif()
  endif()
endif(MPI_C_FOUND)

if(MPI_CXX_FOUND)
  set(MPI_CXX_LIBRARIES ${MPI_CXX_LIBRARY})
  set(MPI_CXX_INCLUDE_DIRS ${MPI_CXX_INCLUDE_DIR})
  if(NOT TARGET MPI::MPI_CXX)
    add_library(MPI::MPI_CXX IMPORTED INTERFACE)
    set_target_properties(MPI::MPI_CXX PROPERTIES
      INTERFACE_LINK_LIBRARIES "${MPI_CXX_LIBRARIES}"
      INTERFACE_INCLUDE_DIRECTORIES "${MPI_CXX_INCLUDE_DIRS}"
    )
    if(MPI_CXX_LINK_FLAGS)
      set_target_properties(MPI::MPI_CXX PROPERTIES INTERFACE_LINK_OPTIONS "${MPI_CXX_LINK_FLAGS}")
    endif()
  endif()
endif(MPI_CXX_FOUND)

if(MPI_Fortran_FOUND)
  set(MPI_Fortran_LIBRARIES ${MPI_Fortran_LIBRARY})
  set(MPI_Fortran_INCLUDE_DIRS ${MPI_Fortran_INCLUDE_DIR})
  if(NOT TARGET MPI::MPI_Fortran)
    add_library(MPI::MPI_Fortran IMPORTED INTERFACE)
    set_target_properties(MPI::MPI_Fortran PROPERTIES
      INTERFACE_LINK_LIBRARIES "${MPI_Fortran_LIBRARIES}"
      INTERFACE_INCLUDE_DIRECTORIES "${MPI_Fortran_INCLUDE_DIRS}"
    )
    if(MPI_Fortran_LINK_FLAGS)
      set_target_properties(MPI::MPI_Fortran PROPERTIES INTERFACE_LINK_OPTIONS "${MPI_Fortran_LINK_FLAGS}")
    endif()
  endif()

endif(MPI_Fortran_FOUND)

if(MPI_FOUND)
  set(MPI_LIBRARIES ${MPI_Fortran_LIBRARIES} ${MPI_C_LIBRARIES})
  set(MPI_INCLUDE_DIRS ${MPI_Fortran_INCLUDE_DIRS} ${MPI_C_INCLUDE_DIRS})

  set(MPIEXEC_NUMPROC_FLAG "-n"  CACHE STRING "Flag used by MPI to specify the number of processes for mpiexec; the next option will be the number of processes.")
  cmake_host_system_information(RESULT _n QUERY NUMBER_OF_PHYSICAL_CORES)
  set(MPIEXEC_MAX_NUMPROCS "${_n}" CACHE STRING "Maximum number of processors available to run MPI applications.")
endif()

mark_as_advanced(MPI_Fortran_LIBRARY MPI_Fortran_INCLUDE_DIR MPI_C_LIBRARY MPI_C_INCLUDE_DIR
MPIEXEC_EXECUTABLE MPIEXEC_NUMPROC_FLAG MPIEXEC_MAX_NUMPROCS)
