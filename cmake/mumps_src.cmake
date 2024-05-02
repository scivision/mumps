# a few versions of MUMPS are known to work and are specifically listed in the
# libraries.json file.

include(FetchContent)

string(TOLOWER ${PROJECT_NAME}_src name)

if(NOT MUMPS_UPSTREAM_VERSION)
  message(FATAL_ERROR "please specify MUMPS_UPSTREAM_VERSION")
endif()

file(READ ${CMAKE_CURRENT_LIST_DIR}/libraries.json json)

string(JSON url GET ${json} ${name} ${MUMPS_UPSTREAM_VERSION})

if(NOT url)
  message(FATAL_ERROR "unknown MUMPS_UPSTREAM_VERSION ${MUMPS_UPSTREAM_VERSION}.
  Make a GitHub issue to request this in ${CMAKE_CURRENT_LIST_DIR}/libraries.json
  ")
endif()

set(FETCHCONTENT_QUIET no)

FetchContent_Declare(${PROJECT_NAME}
SOURCE_DIR ${PROJECT_SOURCE_DIR}/mumps/${MUMPS_UPSTREAM_VERSION}
URL ${url}
TLS_VERIFY ${CMAKE_TLS_VERIFY}
)

FetchContent_GetProperties(${PROJECT_NAME})
if(NOT ${PROJECT_NAME}_POPULATED)
  FetchContent_Populate(${PROJECT_NAME})
endif()
