# a few versions of MUMPS are known to work and are specifically listed in the
# libraries.json file.

include(FetchContent)

set(FETCHCONTENT_QUIET no)

if(NOT MUMPS_UPSTREAM_VERSION)
  message(FATAL_ERROR "please specify MUMPS_UPSTREAM_VERSION")
endif()

file(READ ${CMAKE_CURRENT_LIST_DIR}/libraries.json json)

set(mumps_urls)
set(mumps_sha256)

if(CMAKE_VERSION VERSION_LESS 3.19)
  include(${CMAKE_CURRENT_LIST_DIR}/Modules/JsonParse.cmake)
  sbeParseJson(meta json)
  set(mumps_urls ${meta.mumps.${MUMPS_UPSTREAM_VERSION}.urls_0} ${meta.mumps.${MUMPS_UPSTREAM_VERSION}.urls_1})
  set(mumps_sha256 ${meta.mumps.${MUMPS_UPSTREAM_VERSION}.sha256})
else()
  string(JSON N LENGTH ${json} mumps ${MUMPS_UPSTREAM_VERSION} urls)
  math(EXPR N "${N}-1")
  foreach(i RANGE ${N})
    string(JSON _u GET ${json} mumps ${MUMPS_UPSTREAM_VERSION} urls ${i})
    list(APPEND mumps_urls ${_u})
  endforeach()

  string(JSON mumps_sha256 GET ${json} mumps ${MUMPS_UPSTREAM_VERSION} sha256)
endif()

if(NOT mumps_urls)
  message(FATAL_ERROR "unknown MUMPS_UPSTREAM_VERSION ${MUMPS_UPSTREAM_VERSION}.
  Make a GitHub issue to request this in ${CMAKE_CURRENT_LIST_DIR}/libraries.json
  ")
endif()

message(DEBUG "MUMPS archive source URLs: ${mumps_urls}")


FetchContent_Declare(mumps
URL "${mumps_urls}"
URL_HASH SHA256=${mumps_sha256}
TLS_VERIFY true
INACTIVITY_TIMEOUT 60
)

FetchContent_Populate(mumps)
