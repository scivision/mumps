function(example_build example_bin)

execute_process(
COMMAND ${CMAKE_COMMAND}
  -B${example_bin} -S${CMAKE_CURRENT_LIST_DIR}/../example
  -DCMAKE_PREFIX_PATH:PATH=${CMAKE_PREFIX_PATH}
  -DMUMPS_ROOT:PATH=${prefix}
  -DCMAKE_C_COMPILER:FILEPATH=${CMAKE_C_COMPILER}
  -DCMAKE_Fortran_COMPILER:FILEPATH=${CMAKE_Fortran_COMPILER}
COMMAND_ERROR_IS_FATAL ANY
)

execute_process(COMMAND ${CMAKE_COMMAND} --build ${example_bin} --parallel
COMMAND_ERROR_IS_FATAL ANY
)

execute_process(COMMAND ${CMAKE_CTEST_COMMAND} --test-dir ${example_bin} -V
COMMAND_ERROR_IS_FATAL ANY
)

endfunction()
