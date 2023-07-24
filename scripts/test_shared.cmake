# For dev testing, to ease testing of shared libraries, which
# may not show run path problems until executables are run.
include(${CMAKE_CURRENT_LIST_DIR}/tempdir.cmake)

if(NOT bindir)
  get_temp_dir(bindir)
endif()
if(NOT prefix)
  get_temp_dir(prefix)
endif()

message(STATUS "binary_dir: ${bindir}
prefix: ${prefix}")

execute_process(
COMMAND ${CMAKE_COMMAND}
  -B${bindir} -S${CMAKE_CURRENT_LIST_DIR}/..
  -DCMAKE_INSTALL_PREFIX:PATH=${prefix}
  -DBUILD_SHARED_LIBS:BOOL=true
  -DCMAKE_BUILD_TYPE:STRING=Release
  -DCMAKE_PREFIX_PATH:PATH=${CMAKE_PREFIX_PATH}
RESULT_VARIABLE ret
)
if(NOT ret EQUAL 0)
  message(FATAL_ERROR "shared libs failed to configure in ${bindir}")
endif()

execute_process(COMMAND ${CMAKE_COMMAND} --build ${bindir}
RESULT_VARIABLE ret
)
if(NOT ret EQUAL 0)
  message(FATAL_ERROR "shared libs failed to build in ${bindir}")
endif()

execute_process(COMMAND ${CMAKE_COMMAND} --install ${bindir})
if(NOT ret EQUAL 0)
  message(FATAL_ERROR "shared libs failed to install in ${prefix}")
endif()

# example
get_temp_dir(example_bin)
execute_process(
COMMAND ${CMAKE_COMMAND}
  -B${example_bin} -S${CMAKE_CURRENT_LIST_DIR}/../example
  -DCMAKE_INSTALL_PREFIX:PATH=${prefix}
  -DBUILD_SHARED_LIBS:BOOL=true
  -DCMAKE_PREFIX_PATH:PATH=${CMAKE_PREFIX_PATH}
  -DMUMPS_ROOT:PATH=${prefix}
RESULT_VARIABLE ret
)
if(NOT ret EQUAL 0)
  message(FATAL_ERROR "shared example failed to configure in ${example_bin}")
endif()

execute_process(COMMAND ${CMAKE_COMMAND} --build ${example_bin}
RESULT_VARIABLE ret
)
if(NOT ret EQUAL 0)
  message(FATAL_ERROR "shared libs failed to build in ${example_bin}")
endif()

execute_process(COMMAND ${CMAKE_CTEST_COMMAND} --test-dir ${example_bin} -V
RESULT_VARIABLE ret
)
if(NOT ret EQUAL 0)
  message(FATAL_ERROR "shared libs failed to run tests in ${example_bin}")
endif()
