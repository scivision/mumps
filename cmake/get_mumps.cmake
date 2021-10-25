include(FetchContent)

file(READ ${CMAKE_CURRENT_LIST_DIR}/libraries.json json)

set(mumps_urls)
string(JSON N LENGTH ${json} mumps ${MUMPS_UPSTREAM_VERSION} urls)
math(EXPR N "${N}-1")
foreach(i RANGE ${N})
  string(JSON _u GET ${json} mumps ${MUMPS_UPSTREAM_VERSION} urls ${i})
  list(APPEND mumps_urls ${_u})
endforeach()

string(JSON mumps_sha256 GET ${json} mumps ${MUMPS_UPSTREAM_VERSION} sha256)

set(FETCHCONTENT_QUIET no)

FetchContent_Declare(mumps
URL ${mumps_urls}
URL_HASH SHA256=${mumps_sha256}
INACTIVITY_TIMEOUT 15
)

if(NOT mumps_POPULATED)
  FetchContent_Populate(mumps)
endif()

if(MUMPS_UPSTREAM_VERSION VERSION_EQUAL 5.4.0 OR MUMPS_UPSTREAM_VERSION VERSION_EQUAL 5.4.1)
  include(${CMAKE_CURRENT_LIST_DIR}/mumps_patch.cmake)
endif()

# --- dynamic shared library
set(CMAKE_INSTALL_NAME_DIR ${CMAKE_INSTALL_PREFIX}/lib)
set(CMAKE_INSTALL_RPATH ${CMAKE_INSTALL_PREFIX}/lib)
