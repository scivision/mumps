function(src_getter json upstream key srcs_var)

string(JSON L LENGTH ${json} ${key})
math(EXPR L "${L}-1")
foreach(i RANGE ${L})
  string(JSON _max GET ${json} ${key} ${i} "less")
  if("${_max}" AND upstream VERSION_GREATER_EQUAL "${_max}")
    message(DEBUG "${key} upstream: ${upstream} max: ${_max}")
    continue()
  endif()

  string(JSON _min GET ${json} ${key} ${i} "min")
  if("${_min}" AND upstream VERSION_LESS "${_min}")
    message(DEBUG "${key} upstream: ${upstream} min: ${_min}")
    continue()
  endif()

  string(JSON M LENGTH ${json} ${key} ${i} "src")
  message(DEBUG "${key} max: ${_max} min: ${_min} Nsrc: ${M}")

  math(EXPR M "${M}-1")

  foreach(j RANGE ${M})
    string(JSON v GET ${json} ${key} ${i} src ${j})
    list(APPEND ${srcs_var} ${v})
  endforeach()
endforeach()

set(${srcs_var} ${${srcs_var}} PARENT_SCOPE)

endfunction()

set(mumps_upstream 5.3)

file(READ cmake/mumps_sources.json json)

foreach(k IN ITEMS comm_Fortran comm_other_C comm_other_Fortran metis scotch mumps_C mumps_Fortran)
  src_getter(${json} ${mumps_upstream} ${k} ${k})

  list(LENGTH ${k} L)
  message(STATUS "${k} ${L} srcs: ${${k}}")
endforeach()
