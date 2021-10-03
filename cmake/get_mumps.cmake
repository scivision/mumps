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

FetchContent_Declare(mumps
URL ${mumps_urls}
URL_HASH SHA256=${mumps_sha256}
)

if(NOT mumps_POPULATED)
  FetchContent_Populate(mumps)
endif()
