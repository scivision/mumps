if(NOT prefix)
  set(prefix ${CMAKE_CURRENT_BINARY_DIR}/build_${target})
endif()

if(NOT bindir)
  include(${CMAKE_CURRENT_LIST_DIR}/mkdtemp.cmake)
endif()

execute_process(
  COMMAND ${CMAKE_COMMAND}
  -B${bindir}
  -S${CMAKE_CURRENT_LIST_DIR}
  ${args} -DCMAKE_INSTALL_PREFIX:PATH=${prefix}
  RESULT_VARIABLE ret
)

# avoid overloading CPU/RAM with extreme GNU Make --parallel
cmake_host_system_information(RESULT N QUERY NUMBER_OF_PHYSICAL_CORES)

if(ret EQUAL 0)
  message(STATUS "${target} build with ${N} workers")
else()
  message(FATAL_ERROR "${target} failed to configure.")
endif()

execute_process(
COMMAND ${CMAKE_COMMAND} --build ${bindir} --parallel ${N} --target ${target}
RESULT_VARIABLE ret
)

if(ret EQUAL 0)
  message(STATUS "${target} install complete.")
else()
  message(FATAL_ERROR "${target} failed to build and install.")
endif()
