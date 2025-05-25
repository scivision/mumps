# For dev testing, to ensure each expected version of MUMPS builds

include(${CMAKE_CURRENT_LIST_DIR}/tempdir.cmake)

# MUMPS 4.8.4, 4.9.2, 5.0.2 source no longer available from mumps-solver.org

set(vers 5.1.2 5.2.1 5.3.5 5.4.1 5.5.1 5.6.2 5.7.3 5.8.0)

foreach(u IN LISTS vers)
  get_temp_dir(bindir)
  message(STATUS "Testing MUMPS ${u} in ${bindir}")

  execute_process(COMMAND ${CMAKE_COMMAND} -B${bindir} -S${CMAKE_CURRENT_LIST_DIR}/.. -DMUMPS_UPSTREAM_VERSION=${u}
  RESULT_VARIABLE ret
  COMMAND_ERROR_IS_FATAL ANY
  )

  execute_process(COMMAND ${CMAKE_COMMAND} --build ${bindir}
  RESULT_VARIABLE ret
  COMMAND_ERROR_IS_FATAL ANY
  )

endforeach()
