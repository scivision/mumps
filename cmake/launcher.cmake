function(test_mpi_launcher name Nworker)
# assumes target and test have same "name" (could be made different)

if(NOT (DEFINED MPIEXEC_EXECUTABLE AND DEFINED MPIEXEC_NUMPROC_FLAG))
  message(FATAL_ERROR "MPIEXEC_EXECUTABLE and MPIEXEC_NUMPROC_FLAG must be defined to use test_mpi_launcher")
endif()

if(CMAKE_VERSION VERSION_GREATER_EQUAL 3.29)
  set_property(TEST ${name} PROPERTY TEST_LAUNCHER ${MPIEXEC_EXECUTABLE} ${MPIEXEC_NUMPROC_FLAG} ${Nworker})
else()
  set_property(TARGET ${name} PROPERTY CROSSCOMPILING_EMULATOR ${MPIEXEC_EXECUTABLE} ${MPIEXEC_NUMPROC_FLAG} ${Nworker})
endif()

set_property(TEST ${name} PROPERTY PROCESSORS ${Nworker})

if(DEFINED mpi_tmpdir)
  set_property(TEST ${name} PROPERTY ENVIRONMENT "TMPDIR=${mpi_tmpdir}")
endif()

endfunction()
