
if(parallel)
  set(cmd mpiexec -n 2 ${exe})
else()
  set(cmd ${exe})
endif()

execute_process(COMMAND ${cmd}
INPUT_FILE ${in}
COMMAND_ERROR_IS_FATAL ANY
)
