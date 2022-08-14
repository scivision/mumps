cmake_minimum_required(VERSION 3.13...3.25)

project(MUMPSExamples
LANGUAGES C Fortran
)

enable_testing()

# --- auto-ignore build directory
if(NOT EXISTS ${PROJECT_BINARY_DIR}/.gitignore)
  file(WRITE ${PROJECT_BINARY_DIR}/.gitignore "*")
endif()

find_package(MUMPS CONFIG REQUIRED)

if(MUMPS_d_FOUND)
  add_executable(c_example c_example.c)
  target_link_libraries(c_example PRIVATE MUMPS::MUMPS)

  if(MUMPS_parallel)
    add_test(NAME example_C
      COMMAND ${MPIEXEC_EXECUTABLE} ${MPIEXEC_NUMPROC_FLAG} 2 $<TARGET_FILE:c_example>)
  else()
    add_test(NAME example_C COMMAND c_example)
  endif()
endif()


# Windows DLL
get_property(test_names DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR} PROPERTY TESTS)

set_property(TEST ${test_names} PROPERTY TIMEOUT 10)
if(MUMPS_paralllel)
  set_property(TEST ${test_names} PROPERTY RESOURCE_LOCK cpu_mpi)
endif()

if(WIN32 AND CMAKE_VERSION VERSION_GREATER_EQUAL 3.22)
  get_property(imp_mumps TARGET MUMPS::COMMON PROPERTY IMPORTED_LOCATION_RELEASE)
  if(imp_mumps)
    get_filename_component(imp_mumps_dir ${imp_mumps} DIRECTORY)
  endif()
  set_property(TEST ${test_names} PROPERTY
  ENVIRONMENT_MODIFICATION "PATH=path_list_append:${imp_mumps_dir};PATH=path_list_append:${CMAKE_PREFIX_PATH}/bin;PATH=path_list_append:${PROJECT_BINARY_DIR}"
  )
endif()
