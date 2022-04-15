# testing what we just built

if("d" IN_LIST arith)
  add_executable(mumpscfg test_mumps.f90)
  target_link_libraries(mumpscfg PRIVATE MUMPS::MUMPS ${NUMERIC_LIBS})

  if(parallel)
    add_test(NAME mumps:config COMMAND ${MPIEXEC_EXECUTABLE} ${MPIEXEC_NUMPROC_FLAG} 2 $<TARGET_FILE:mumpscfg>)
  else()
    add_test(NAME mumps:config COMMAND mumpscfg)
  endif()
endif()

if(MUMPS_UPSTREAM_VERSION VERSION_LESS 5.1)
  return()
endif()

if("s" IN_LIST arith)
  add_executable(s_simple s_simple.f90)
  target_link_libraries(s_simple PRIVATE MUMPS::MUMPS ${NUMERIC_LIBS})

  if(parallel)
    add_test(NAME mumps:simpleReal32 COMMAND ${MPIEXEC_EXECUTABLE} ${MPIEXEC_NUMPROC_FLAG} 2 $<TARGET_FILE:s_simple>)
  else()
    add_test(NAME mumps:simpleReal32 COMMAND s_simple)
  endif()
endif()

if("d" IN_LIST arith)
  add_executable(d_simple d_simple.f90)
  target_link_libraries(d_simple PRIVATE MUMPS::MUMPS ${NUMERIC_LIBS})

  if(parallel)
    add_test(NAME mumps:simpleReal64 COMMAND ${MPIEXEC_EXECUTABLE} ${MPIEXEC_NUMPROC_FLAG} 2 $<TARGET_FILE:d_simple>)
  else()
    add_test(NAME mumps:simpleReal64 COMMAND d_simple)
  endif()

  if(ClangTest)
    add_executable(Csimple simple.c)
    target_link_libraries(Csimple PRIVATE MUMPS::MUMPS ${NUMERIC_LIBS})

    if(parallel)
      add_test(NAME mumps:CsimpleReal64 COMMAND ${MPIEXEC_EXECUTABLE} ${MPIEXEC_NUMPROC_FLAG} 2 $<TARGET_FILE:Csimple>)
    else()
      add_test(NAME mumps:CsimpleReal64 COMMAND Csimple)
    endif()
  endif()
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
