set(names lapack scalapack)

file(READ ${CMAKE_CURRENT_LIST_DIR}/libraries.json _libj)

foreach(n ${names})
  foreach(t git tag)
    string(JSON m GET ${_libj} ${n} ${t})
    set(${n}_${t} ${m})
  endforeach()
endforeach()
