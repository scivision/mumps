# a few versions of MUMPS are known to work and are specifically listed in the
# libraries.json file.
# We allow other versions of MUMPS to be requested, but they might not build or run.

include(FetchContent)

set(FETCHCONTENT_QUIET no)

if(NOT MUMPS_UPSTREAM_VERSION)
  message(FATAL_ERROR "please specify MUMPS_UPSTREAM_VERSION")
endif()

file(READ ${CMAKE_CURRENT_LIST_DIR}/libraries.json json)

set(mumps_urls)
set(mumps_sha256)

string(JSON N LENGTH ${json} mumps ${MUMPS_UPSTREAM_VERSION} urls)
math(EXPR N "${N}-1")
foreach(i RANGE ${N})
  string(JSON _u GET ${json} mumps ${MUMPS_UPSTREAM_VERSION} urls ${i})
  list(APPEND mumps_urls ${_u})
endforeach()

if(NOT mumps_urls)
  message(FATAL_ERROR "unknown MUMPS_UPSTREAM_VERSION ${MUMPS_UPSTREAM_VERSION}.
  Make a GitHub issue to request this in ${CMAKE_CURRENT_LIST_DIR}/libraries.json
  ")
endif()

string(JSON mumps_sha256 GET ${json} mumps ${MUMPS_UPSTREAM_VERSION} sha256)

FetchContent_Declare(mumps
URL ${mumps_urls}
URL_HASH SHA256=${mumps_sha256}
INACTIVITY_TIMEOUT 60
)

FetchContent_Populate(mumps)
