# a few versions of MUMPS are known to work and are specifically listed in the
# libraries.json file.
# We allow other versions of MUMPS to be requested, but they might not build or run.

include(FetchContent)

function(find_url version)

file(READ ${CMAKE_CURRENT_LIST_DIR}/libraries.json json)

set(mumps_urls)
set(mumps_sha256)

string(JSON N LENGTH ${json} mumps ${version} urls)
math(EXPR N "${N}-1")
foreach(i RANGE ${N})
  string(JSON _u GET ${json} mumps ${version} urls ${i})
  list(APPEND mumps_urls ${_u})
endforeach()

string(JSON mumps_sha256 GET ${json} mumps ${version} sha256)

set(mumps_urls ${mumps_urls} PARENT_SCOPE)
set(mumps_sha256 ${mumps_sha256} PARENT_SCOPE)

endfunction()


find_url(${MUMPS_UPSTREAM_VERSION})

set(FETCHCONTENT_QUIET no)

if(NOT mumps_urls)
  message(FATAL_ERROR "unknown MUMPS_UPSTREAM_VERSION ${MUMPS_UPSTREAM_VERSION}.
  Make a GitHub issue to request this in ${CMAKE_CURRENT_LIST_DIR}/libraries.json
  ")
endif()

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
