set(_sfilename input_simpletest_real)
set(_dfilename input_simpletest_real)
set(_cfilename input_simpletest_cmplx)
set(_zfilename input_simpletest_cmplx)

foreach(a s d)
  if(NOT ${a} IN_LIST arith)
    continue()
  endif()

  add_executable(${a}simpletest ${a}simpletest.F)
  target_link_libraries(${a}simpletest PRIVATE MUMPS::MUMPS MPI::MPI_Fortran)

  add_test(NAME mumps:example_${a} COMMAND ${CMAKE_COMMAND} -Dexe:FILEPATH=$<TARGET_FILE:${a}simpletest> -Din:PATH=${CMAKE_CURRENT_SOURCE_DIR}/${_${a}filename} -P ${PROJECT_SOURCE_DIR}/examples/run_ex.cmake)
  set_tests_properties(mumps:example_${a} PROPERTIES
  RESOURCE_LOCK cpu_mpi
  TIMEOUT 10
  )

  if(MUMPS_UPSTREAM_VERSION VERSION_GREATER_EQUAL 5.2)
    add_executable(${a}simpletest_save_restore ${a}simpletest_save_restore.F)
    target_link_libraries(${a}simpletest_save_restore PRIVATE MUMPS::MUMPS MPI::MPI_Fortran)

    add_test(NAME mumps:saveRestore_${a} COMMAND ${CMAKE_COMMAND} -Dexe:FILEPATH=$<TARGET_FILE:${a}simpletest_save_restore> -Din:PATH=${CMAKE_CURRENT_SOURCE_DIR}/${_${a}filename} -P ${PROJECT_SOURCE_DIR}/examples/run_ex.cmake)
    set_tests_properties(mumps:saveRestore_${a} PROPERTIES
    RESOURCE_LOCK cpu_mpi
    TIMEOUT 10
    DISABLED $<BOOL:${intsize64}>
    )
  endif()
endforeach()

if(d IN_LIST arith)
  add_executable(c_example c_example.c)
  target_link_libraries(c_example PRIVATE MUMPS::MUMPS MPI::MPI_C)
  if(parallel)
    add_test(NAME mumps:example_C
      COMMAND ${MPIEXEC_EXECUTABLE} ${MPIEXEC_NUMPROC_FLAG} 2 $<TARGET_FILE:c_example>)
  else()
    add_test(NAME mumps:example_C COMMAND $<TARGET_FILE:c_example>)
  endif()
  set_tests_properties(mumps:example_C PROPERTIES
  RESOURCE_LOCK cpu_mpi
  TIMEOUT 10
  )
endif()
