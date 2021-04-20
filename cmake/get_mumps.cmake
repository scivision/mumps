file(READ ${CMAKE_CURRENT_LIST_DIR}/mumps.json json)

string(JSON url GET ${json} mumps url1)
set(mumps_urls ${url})
string(JSON url GET ${json} mumps url2)
list(APPEND mumps_urls ${url})

FetchContent_Declare(mumps
URL ${mumps_urls}
TLS_VERIFY ON)

if(NOT mumps_POPULATED)
  FetchContent_Populate(mumps)
endif()
