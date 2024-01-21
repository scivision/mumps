# a few versions of MUMPS are known to work and are specifically listed in the
# libraries.json file.

include(FetchContent)

string(TOLOWER ${PROJECT_NAME}_src name)

if(local)

find_file(${name}_archive
NAMES ${name}.tar.bz2 ${name}.tar.gz ${name}.tar ${name}.zip ${name}.tar.zstd ${name}.tar.xz ${name}.tar.lz
HINTS ${local}
NO_DEFAULT_PATH
REQUIRED
)

message(STATUS "${name}: using source archive ${${name}_archive}")

FetchContent_Declare(${PROJECT_NAME}
URL ${${name}_archive}
)

else()

if(NOT MUMPS_UPSTREAM_VERSION)
  message(FATAL_ERROR "please specify MUMPS_UPSTREAM_VERSION")
endif()

set(urls)
set(sha256)

file(READ ${CMAKE_CURRENT_LIST_DIR}/libraries.json json)

string(JSON N LENGTH ${json} ${name} ${MUMPS_UPSTREAM_VERSION} "urls")
if(NOT "${N}")
  message(FATAL_ERROR "MUMPS ${MUMPS_UPSTREAM_VERSION} not found in ${CMAKE_CURRENT_LIST_DIR}/libraries.json
  ${N}")
endif()
math(EXPR N "${N}-1")
foreach(i RANGE ${N})
  string(JSON _u GET ${json} ${name} ${MUMPS_UPSTREAM_VERSION} urls ${i})
  list(APPEND urls ${_u})
endforeach()

string(JSON sha256 GET ${json} ${name} ${MUMPS_UPSTREAM_VERSION} sha256)

if(NOT urls)
  message(FATAL_ERROR "unknown MUMPS_UPSTREAM_VERSION ${MUMPS_UPSTREAM_VERSION}.
  Make a GitHub issue to request this in ${CMAKE_CURRENT_LIST_DIR}/libraries.json
  ")
endif()

message(DEBUG "MUMPS archive source URLs: ${urls}")

set(FETCHCONTENT_QUIET no)

FetchContent_Declare(${PROJECT_NAME}
URL ${urls}
URL_HASH SHA256=${sha256}
)

endif()

FetchContent_GetProperties(${PROJECT_NAME})
if(NOT ${PROJECT_NAME}_POPULATED)
  FetchContent_Populate(${PROJECT_NAME})
endif()
