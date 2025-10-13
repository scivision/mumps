function(get_tempdir var)

foreach(n IN ITEMS $ENV{TEMP} $ENV{TMP} $ENV{TMPDIR})
  if(EXISTS "${n}")
    set(${var} ${n} PARENT_SCOPE)
    return()
  endif()
endforeach()

set(${var} /tmp PARENT_SCOPE)

endfunction()
