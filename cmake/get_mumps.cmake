file(READ ${CMAKE_CURRENT_LIST_DIR}/mumps.json json)

string(JSON url0 GET ${json} mumps url0)
string(JSON url1 GET ${json} mumps url1)
string(JSON url2 GET ${json} mumps url2)
string(JSON mumps_sha256 GET ${json} mumps sha256)
set(mumps_urls ${url0} ${url1} ${url2})

FetchContent_Declare(
  mumps
  URL ${mumps_urls}
  URL_HASH SHA256=${mumps_sha256})

if(NOT mumps_POPULATED)
  FetchContent_Populate(mumps)
endif()
