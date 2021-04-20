set(names lapack scalapack)

if(CMAKE_VERSION VERSION_LESS 3.19)

file(READ ${CMAKE_CURRENT_LIST_DIR}/libraries.txt _libj)

foreach(n ${names})
  foreach(t git tag zip sha1)
    string(REGEX MATCH "${n}_${t} ([^ \t\r\n]*)" m ${_libj})
    if(m)
      set(${n}_${t} ${CMAKE_MATCH_1})
    endif()
  endforeach()
endforeach()

else()
# CMake >= 3.19

file(READ ${CMAKE_CURRENT_LIST_DIR}/libraries.json _libj)

foreach(n ${names})
  foreach(t git tag zip sha1)
    string(JSON m ERROR_VARIABLE e GET ${_libj} ${n} ${t})
    if(m)
      set(${n}_${t} ${m})
    endif()
  endforeach()
endforeach()

endif()
