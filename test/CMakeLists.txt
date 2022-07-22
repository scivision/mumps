set_directory_properties(PROPERTIES LABELS "unit;mumps")

function(mumps_test name tgt)

if(parallel)
  add_test(NAME ${name} COMMAND ${MPIEXEC_EXECUTABLE} ${MPIEXEC_NUMPROC_FLAG} 2 $<TARGET_FILE:${tgt}>)
else()
  add_test(NAME ${name} COMMAND ${tgt})
endif()

endfunction(mumps_test)

if("d" IN_LIST arith AND LAPACK_d_FOUND)
  add_executable(mumpscfg test_mumps.f90)
  target_link_libraries(mumpscfg PRIVATE MUMPS::MUMPS)

  mumps_test(Cfg mumpscfg)
endif()

if(MUMPS_UPSTREAM_VERSION VERSION_LESS 5.1)
  return()
endif()

if("s" IN_LIST arith AND LAPACK_s_FOUND)
  add_executable(s_simple s_simple.f90)
  target_link_libraries(s_simple PRIVATE MUMPS::MUMPS)

  mumps_test(SimpleReal32 s_simple)
endif()

if("d" IN_LIST arith AND LAPACK_d_FOUND)
  add_executable(d_simple d_simple.f90)
  target_link_libraries(d_simple PRIVATE MUMPS::MUMPS)

  mumps_test(SimpleReal64 d_simple)

  add_executable(Csimple simple.c)
  target_link_libraries(Csimple PRIVATE MUMPS::MUMPS)

  mumps_test(CsimpleReal64 Csimple)

  set_tests_properties(CsimpleReal64 PROPERTIES
  DISABLED $<BOOL:${intsize64}>
  )

endif()

# Windows DLL
get_property(test_names DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR} PROPERTY TESTS)

set_tests_properties(${test_names} PROPERTIES
RESOURCE_LOCK cpu_mpi
TIMEOUT 30
)

if(WIN32 AND CMAKE_VERSION VERSION_GREATER_EQUAL 3.22)
  set_tests_properties(${test_names} PROPERTIES
  ENVIRONMENT_MODIFICATION "PATH=path_list_append:${CMAKE_INSTALL_PREFIX}/bin;PATH=path_list_append:${CMAKE_PREFIX_PATH}/bin;PATH=path_list_append:${PROJECT_BINARY_DIR}"
  )
endif()
