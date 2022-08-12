execute_process(COMMAND mpiexec -n 2 ${exe}
INPUT_FILE ${in}
RESULT_VARIABLE ret
)

if(NOT ret EQUAL 0)
  message(FATAL_ERROR "${exe} failed with exit code ${ret}")
endif()
