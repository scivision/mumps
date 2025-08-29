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
#  This does not check that intsize and realsize are compatible.
#
#  COMPONENTS:
#
#  * ESMUMPS: detect Scotch esmumps interface
#  * PTScotch: detect parallel (MPI) Scotch
#
# This module finds headers and scotch library.
# Results are reported in variables:
#  SCOTCH_FOUND           - True if headers and requested libraries were found
#  SCOTCH_INCLUDE_DIRS    - scotch include directories
#  SCOTCH_LIBRARIES       - scotch component libraries to be linked
#
# Imported Targets
# ^^^^^^^^^^^^^^^^
#
# SCOTCH::scotch
#
#=============================================================================
# Copyright 2012-2013 Inria
# Copyright 2012-2013 Emmanuel Agullo
# Copyright 2012-2013 Mathieu Faverge
# Copyright 2012      Cedric Castagnede
# Copyright 2013      Florent Pruvost
# (C) 2018-2025 SciVision
#
# Distributed under the OSI-approved BSD License (the "License");
# see accompanying file MORSE-Copyright.txt for details.
#
# This software is distributed WITHOUT ANY WARRANTY; without even the
# implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
# See the License for more information.
#=============================================================================

set(SCOTCH_LIBRARIES)

set(scotch_h scotch.h)
if(PTScotch IN_LIST SCOTCH_FIND_COMPONENTS)
  string(PREPEND scotch_h pt)
endif()

find_path(SCOTCH_INCLUDE_DIR
NAMES ${scotch_h}
PATH_SUFFIXES scotch
DOC "Scotch include directory"
)
# PATH_SUFFIXES scotch
# for Ubuntu, Debian, RHEL, ...

# need plain scotch when using ptscotch
set(scotch_names scotch scotcherr)
if(ESMUMPS IN_LIST SCOTCH_FIND_COMPONENTS)
  list(PREPEND scotch_names esmumps)
endif()

if(PTScotch IN_LIST SCOTCH_FIND_COMPONENTS)
  list(PREPEND scotch_names ptscotch ptscotcherr)
  if(ESMUMPS IN_LIST SCOTCH_FIND_COMPONENTS)
    list(PREPEND scotch_names ptesmumps)
  endif()
endif()

foreach(l IN LISTS scotch_names)
  find_library(SCOTCH_${l}_LIBRARY
  NAMES ${l}
  DOC "Scotch library"
  )

  list(APPEND SCOTCH_LIBRARIES ${SCOTCH_${l}_LIBRARY})
  mark_as_advanced(SCOTCH_${l}_LIBRARY)
endforeach()

if(PTScotch IN_LIST SCOTCH_FIND_COMPONENTS)
  if(SCOTCH_ptesmumps_LIBRARY AND SCOTCH_ptscotch_LIBRARY)
    set(SCOTCH_ESMUMPS_FOUND true)
    set(SCOTCH_PTScotch_FOUND true)
  endif()
elseif(SCOTCH_esmumps_LIBRARY)
  set(SCOTCH_ESMUMPS_FOUND true)
endif()

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(SCOTCH
REQUIRED_VARS SCOTCH_LIBRARIES SCOTCH_INCLUDE_DIR
HANDLE_COMPONENTS
)

if(SCOTCH_FOUND)
  set(SCOTCH_INCLUDE_DIRS ${SCOTCH_INCLUDE_DIR})

  message(DEBUG "Scotch libraries: ${SCOTCH_LIBRARIES}
  Scotch include directories: ${SCOTCH_INCLUDE_DIRS}")

  foreach(l IN LISTS scotch_names)
    if(NOT TARGET SCOTCH::${l})
      add_library(SCOTCH::${l} INTERFACE IMPORTED)
      set_property(TARGET SCOTCH::${l} PROPERTY INTERFACE_LINK_LIBRARIES "${SCOTCH_${l}_LIBRARY}")
      set_property(TARGET SCOTCH::${l} PROPERTY INTERFACE_INCLUDE_DIRECTORIES "${SCOTCH_INCLUDE_DIR}")
    endif()
  endforeach()
endif()

mark_as_advanced(SCOTCH_INCLUDE_DIR)
