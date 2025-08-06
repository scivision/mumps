# For dev testing, to ensure each expected version of MUMPS builds

foreach(n IN ITEMS $ENV{TEMP} $ENV{TMP} $ENV{TMPDIR})
  if(EXISTS ${n})
    set(tempdir ${n})
    break()
  endif()
endforeach()

if(NOT DEFINED tempdir)
  set(tempdir ${CMAKE_CURRENT_BINARY_DIR}/temp)
endif()

# MUMPS 4.8.4, 4.9.2, 5.0.2 source no longer available from mumps-solver.org

if(NOT DEFINED vers)
  set(vers 5.1.2 5.2.1 5.3.5 5.4.1 5.5.1 5.6.2 5.7.0 5.7.3 5.8.1)
endif()

message(STATUS "Testing MUMPS versions: ${vers}")

foreach(u IN LISTS vers)

  set(bindir_${u} ${tempdir}/mumps-${u})
  message(STATUS "Testing MUMPS ${u} in ${bindir_${u}}")

  execute_process(COMMAND ${CMAKE_COMMAND} -B${bindir_${u}} -S${CMAKE_CURRENT_LIST_DIR}/.. -DMUMPS_UPSTREAM_VERSION=${u}
  RESULT_VARIABLE ret
  COMMAND_ERROR_IS_FATAL ANY
  )

  execute_process(COMMAND ${CMAKE_COMMAND} --build ${bindir_${u}}
  RESULT_VARIABLE ret
  COMMAND_ERROR_IS_FATAL ANY
  )

endforeach()


foreach(u IN LISTS vers)

  message(STATUS "Testing MUMPS ${u} in ${bindir_${u}}")

  execute_process(COMMAND ${CMAKE_CTEST_COMMAND} --test-dir ${bindir_${u}} --progress --timeout 15
  COMMAND_ECHO STDOUT
  )

endforeach()
