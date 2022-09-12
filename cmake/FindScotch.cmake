###
#
# @copyright (c) 2009-2014 The University of Tennessee and The University
#                          of Tennessee Research Foundation.
#                          All rights reserved.
# @copyright (c) 2012-2014 Inria. All rights reserved.
# @copyright (c) 2012-2014 Bordeaux INP, CNRS (LaBRI UMR 5800), Inria, Univ. Bordeaux. All rights reserved.
#
###
#
# - Find Scotch include dirs and libraries
# Use this module by invoking find_package with the form:
#  find_package(Scotch
#               [REQUIRED]             # Fail with error if scotch is not found
#               [COMPONENTS <comp1> <comp2> ...] # dependencies
#              )
#
#  COMPONENTS:
#
#  * ESMUMPS: detect Scotch esmumps interface
#  * parallel: detect parallel (MPI) Scotch
#
# This module finds headers and scotch library.
# Results are reported in variables:
#  Scotch_FOUND           - True if headers and requested libraries were found
#  Scotch_INCLUDE_DIRS    - scotch include directories
#  Scotch_LIBRARIES       - scotch component libraries to be linked
#
# Imported Targets
# ^^^^^^^^^^^^^^^^
#
# Scotch::Scotch
#
#=============================================================================
# Copyright 2012-2013 Inria
# Copyright 2012-2013 Emmanuel Agullo
# Copyright 2012-2013 Mathieu Faverge
# Copyright 2012      Cedric Castagnede
# Copyright 2013      Florent Pruvost
# (C) 2018 Michael Hirsch
#
# Distributed under the OSI-approved BSD License (the "License");
# see accompanying file MORSE-Copyright.txt for details.
#
# This software is distributed WITHOUT ANY WARRANTY; without even the
# implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
# See the License for more information.
#=============================================================================

set(Scotch_LIBRARIES)

find_path(Scotch_INCLUDE_DIR
NAMES scotch.h
PATH_SUFFIXES scotch openmpi openmpi-x86_64 mpich-x86_64
DOC "Scotch include directory"
)

# need plain scotch when using ptscotch
set(scotch_names scotch scotcherr)
if(ESMUMPS IN_LIST Scotch_FIND_COMPONENTS)
  list(INSERT scotch_names 0 esmumps)
endif()

if(parallel IN_LIST Scotch_FIND_COMPONENTS)
  list(INSERT scotch_names 0 ptscotch ptscotcherr)
  if(ESMUMPS IN_LIST Scotch_FIND_COMPONENTS)
    list(INSERT scotch_names 0 ptesmumps)
  endif()
endif()

foreach(l IN LISTS scotch_names)
  find_library(Scotch_${l}_LIBRARY
  NAMES ${l}
  PATH_SUFFIXES openmpi/lib mpich/lib
  DOC "Scotch library"
  )

  list(APPEND Scotch_LIBRARIES ${Scotch_${l}_LIBRARY})
  mark_as_advanced(Scotch_${l}_LIBRARY)
endforeach()

if(parallel IN_LIST Scotch_FIND_COMPONENTS)
  if(Scotch_ptesmumps_LIBRARY AND Scotch_ptscotch_LIBRARY)
    set(Scotch_ESMUMPS_FOUND true)
    set(Scotch_parallel_FOUND true)
  endif()
elseif(Scotch_esmumps_LIBRARY)
  set(Scotch_ESMUMPS_FOUND true)
endif()

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(Scotch
REQUIRED_VARS Scotch_LIBRARIES Scotch_INCLUDE_DIR
HANDLE_COMPONENTS
)

if(Scotch_FOUND)
set(Scotch_INCLUDE_DIRS ${Scotch_INCLUDE_DIR})

message(VERBOSE "Scotch libraries: ${Scotch_LIBRARIES}
Scotch include directories: ${Scotch_INCLUDE_DIRS}")

if(NOT TARGET Scotch::Scotch)
  add_library(Scotch::Scotch INTERFACE IMPORTED)
  set_property(TARGET Scotch::Scotch PROPERTY INTERFACE_LINK_LIBRARIES "${Scotch_LIBRARIES}")
  set_property(TARGET Scotch::Scotch PROPERTY INTERFACE_INCLUDE_DIRECTORIES "${Scotch_INCLUDE_DIR}")
endif()
endif(Scotch_FOUND)

mark_as_advanced(Scotch_INCLUDE_DIR)
