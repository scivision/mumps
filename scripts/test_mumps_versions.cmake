# For dev testing, to ensure each expected version of MUMPS builds

include(${CMAKE_CURRENT_LIST_DIR}/tempdir.cmake)


foreach(u IN ITEMS 4.8.4 4.9.2 5.0.2 5.1.2 5.2.1 5.3.5 5.4.1 5.5.1 5.6.2 5.7.3)
  get_temp_dir(bindir)
  message(STATUS "Testing MUMPS ${u} in ${bindir}")

  execute_process(COMMAND ${CMAKE_COMMAND} -B${bindir} -S${CMAKE_CURRENT_LIST_DIR}/.. -DMUMPS_UPSTREAM_VERSION=${u}
  RESULT_VARIABLE ret
  )
  if(NOT ret EQUAL 0)
    message(SEND_ERROR "MUMPS ${u} failed to configure in ${bindir}")
    continue()
  endif()

  execute_process(COMMAND ${CMAKE_COMMAND} --build ${bindir} RESULT_VARIABLE ret)
  if(NOT ret EQUAL 0)
    message(SEND_ERROR "MUMPS ${u} failed to build in ${bindir}")
    continue()
  endif()
endforeach()
