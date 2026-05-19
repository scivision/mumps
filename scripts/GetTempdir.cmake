function(get_tempdir var)

foreach(n IN ITEMS $ENV{TEMP} $ENV{TMP} $ENV{TMPDIR})
  if(EXISTS "${n}")
    set(${var} ${n})
    return(PROPAGATE ${var})
  endif()
endforeach()

set(${var} /tmp)
return(PROPAGATE ${var})

endfunction()
