set_property(DIRECTORY PROPERTY LABELS "unit;mumps")

include(${PROJECT_SOURCE_DIR}/cmake/launcher.cmake)

if(BUILD_DOUBLE)
  add_executable(test_mumps_config test_mumps.f90)
  target_link_libraries(test_mumps_config PRIVATE MUMPS::MUMPS)
  add_test(NAME test_mumps_config COMMAND test_mumps_config)

  if(parallel)
    test_mpi_launcher(test_mumps_config 2)
  endif()
endif()

if(MUMPS_UPSTREAM_VERSION VERSION_LESS 5.1)
  return()
endif()

if(BUILD_SINGLE)
  add_executable(test_mumps_simple32 s_simple.f90)
  target_link_libraries(test_mumps_simple32 PRIVATE MUMPS::MUMPS)
  add_test(NAME test_mumps_simple32 COMMAND test_mumps_simple32)

  if(parallel)
    test_mpi_launcher(test_mumps_simple32 2)
  endif()
endif()

if(BUILD_DOUBLE)
  add_executable(test_mumps_simple64 d_simple.f90)
  target_link_libraries(test_mumps_simple64 PRIVATE MUMPS::MUMPS)
  add_test(NAME test_mumps_simple64 COMMAND test_mumps_simple64)

  if(parallel)
    test_mpi_launcher(test_mumps_simple64 2)
  endif()

  add_executable(test_mumps_complex128 simple.c)
  target_link_libraries(test_mumps_complex128 PRIVATE MUMPS::MUMPS)
  add_test(NAME test_mumps_complex128 COMMAND test_mumps_complex128)

  if(parallel)
    test_mpi_launcher(test_mumps_complex128 2)
  endif()
endif()

get_property(test_names DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR} PROPERTY TESTS)

set_property(TEST ${test_names} PROPERTY RESOURCE_LOCK cpu_mpi)

# Windows DLL
if(WIN32 AND BUILD_SHARED_LIBS)
  set_property(TEST ${test_names} PROPERTY
  ENVIRONMENT_MODIFICATION "PATH=path_list_prepend:${CMAKE_INSTALL_FULL_BINDIR};PATH=path_list_prepend:${CMAKE_PREFIX_PATH}/bin;PATH=path_list_prepend:${PROJECT_BINARY_DIR}"
  )
endif()
