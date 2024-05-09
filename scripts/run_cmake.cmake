if(NOT bindir)
  include(${CMAKE_CURRENT_LIST_DIR}/mkdtemp.cmake)
endif()

execute_process(
  COMMAND ${CMAKE_COMMAND}
  -B${bindir}
  -S${CMAKE_CURRENT_LIST_DIR}
  ${args}
  RESULT_VARIABLE ret
)

if(NOT ret EQUAL 0)
  message(FATAL_ERROR "${target} failed to configure.")
endif()

execute_process(
COMMAND ${CMAKE_COMMAND} --build ${bindir} --target ${target}
RESULT_VARIABLE ret
)

if(ret EQUAL 0)
  message(STATUS "${target} install complete.")
else()
  message(FATAL_ERROR "${target} failed to build and install.")
endif()
