
if(parallel)
  set(cmd mpiexec -n 2 ${exe})
else()
  set(cmd ${exe})
endif()

execute_process(COMMAND ${cmd}
INPUT_FILE ${in}
RESULT_VARIABLE ret
)

if(NOT ret EQUAL 0)
  message(FATAL_ERROR "return code ${ret}")
endif()
