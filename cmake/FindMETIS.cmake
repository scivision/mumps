# Distributed under the OSI-approved BSD 3-Clause License.  See accompanying
# file Copyright.txt or https://cmake.org/licensing for details.

#[=======================================================================[.rst:
FindMETIS
-------
Michael Hirsch, Ph.D.

Finds the METIS library.
NOTE: If libparmetis used, libmetis must also be linked.

Imported Targets
^^^^^^^^^^^^^^^^

METIS::METIS

Result Variables
^^^^^^^^^^^^^^^^

METIS_LIBRARIES
  libraries to be linked

METIS_INCLUDE_DIRS
  dirs to be included

#]=======================================================================]


if(ParMETIS IN_LIST METIS_FIND_COMPONENTS)
  find_library(PARMETIS_LIBRARY
  NAMES parmetis
  PATH_SUFFIXES METIS libmetis
  DOC "ParMETIS library"
  )
  if(PARMETIS_LIBRARY)
    set(METIS_ParMETIS_FOUND true)
  endif()
endif()

find_library(METIS_LIBRARY
NAMES metis
PATH_SUFFIXES METIS libmetis
DOC "METIS library"
)

if(ParMETIS IN_LIST METIS_FIND_COMPONENTS)
  set(metis_inc parmetis.h)
else()
  set(metis_inc metis.h)
endif()

find_path(METIS_INCLUDE_DIR
NAMES ${metis_inc}
PATH_SUFFIXES METIS openmpi-x86_64 mpich-x86_64
DOC "METIS include directory"
)

set(METIS_LIBRARIES ${PARMETIS_LIBRARY} ${METIS_LIBRARY})

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(METIS
REQUIRED_VARS METIS_LIBRARIES METIS_INCLUDE_DIR
HANDLE_COMPONENTS
)

if(METIS_FOUND)
  set(METIS_INCLUDE_DIRS ${METIS_INCLUDE_DIR})

  message(VERBOSE "METIS libraries: ${METIS_LIBRARIES}
  METIS include directories: ${METIS_INCLUDE_DIRS}")

  if(NOT TARGET METIS::METIS)
    add_library(METIS::METIS INTERFACE IMPORTED)
    set_property(TARGET METIS::METIS PROPERTY INTERFACE_LINK_LIBRARIES "${METIS_LIBRARIES}")
    set_property(TARGET METIS::METIS PROPERTY INTERFACE_INCLUDE_DIRECTORIES "${METIS_INCLUDE_DIR}")
  endif()
endif(METIS_FOUND)

mark_as_advanced(METIS_INCLUDE_DIR METIS_LIBRARY PARMETIS_LIBRARY)
