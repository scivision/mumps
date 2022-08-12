cmake_minimum_required(VERSION 3.13...3.25)

project(MUMPSExamples
LANGUAGES C Fortran
)

enable_testing()

option(parallel "use MPI" true)

# --- auto-ignore build directory
if(NOT EXISTS ${PROJECT_BINARY_DIR}/.gitignore)
  file(WRITE ${PROJECT_BINARY_DIR}/.gitignore "*")
endif()

find_package(MUMPS CONFIG REQUIRED)

# --- Examples from MUMPS itself
set(_sfilename input_simpletest_real)
set(_dfilename input_simpletest_real)
set(_cfilename input_simpletest_cmplx)
set(_zfilename input_simpletest_cmplx)

get_property(mumps_incdir TARGET MUMPS::COMMON PROPERTY INTERFACE_INCLUDE_DIRECTORIES)

foreach(a s d)
  find_file(${a}_inc NAMES ${a}mumps_struc.h
  HINTS ${mumps_incdir}
  NO_DEFAULT_PATH
  )
  if(NOT ${a}_inc)
    continue()
  endif()

  add_executable(${a}simpletest ${a}simpletest.F)
  target_link_libraries(${a}simpletest PRIVATE MUMPS::MUMPS)

  add_test(NAME example_${a}
  COMMAND ${CMAKE_COMMAND} -Dparallel:BOOL=${parallel} -Dexe:FILEPATH=$<TARGET_FILE:${a}simpletest> -Din:PATH=${CMAKE_CURRENT_SOURCE_DIR}/${_${a}filename} -P ${PROJECT_SOURCE_DIR}/run_ex.cmake
  )

  if(MUMPS_UPSTREAM_VERSION VERSION_GREATER_EQUAL 5.2)
    add_executable(${a}simpletest_save_restore ${a}simpletest_save_restore.F)
    target_link_libraries(${a}simpletest_save_restore PRIVATE MUMPS::MUMPS)

    add_test(NAME saveRestore_${a}
    COMMAND ${CMAKE_COMMAND} -Dparallel:BOOL=${parallel} -Dexe:FILEPATH=$<TARGET_FILE:${a}simpletest_save_restore> -Din:PATH=${CMAKE_CURRENT_SOURCE_DIR}/${_${a}filename} -P ${PROJECT_SOURCE_DIR}/run_ex.cmake
    )
    set_property(TEST saveRestore_${a} PROPERTY DISABLED $<BOOL:${intsize64}>)
  endif()
endforeach()

if(d_inc)
  add_executable(c_example c_example.c)
  target_link_libraries(c_example PRIVATE MUMPS::MUMPS)
  set_property(TARGET c_example PROPERTY LINKER_LANGUAGE Fortran)
  # GCC needs Fortran

  if(parallel)
    add_test(NAME example_C
      COMMAND ${MPIEXEC_EXECUTABLE} ${MPIEXEC_NUMPROC_FLAG} 2 $<TARGET_FILE:c_example>)
  else()
    add_test(NAME example_C COMMAND c_example)
  endif()
endif()


# Windows DLL
get_property(test_names DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR} PROPERTY TESTS)

set_property(TEST ${test_names} PROPERTY TIMEOUT 10)
set_property(TEST ${test_names} PROPERTY RESOURCE_LOCK cpu_mpi)

if(WIN32 AND CMAKE_VERSION VERSION_GREATER_EQUAL 3.22)
  set_property(TEST ${test_names} PROPERTY
  ENVIRONMENT_MODIFICATION "PATH=path_list_append:${CMAKE_INSTALL_PREFIX}/bin;PATH=path_list_append:${CMAKE_PREFIX_PATH}/bin;PATH=path_list_append:${PROJECT_BINARY_DIR}"
  )
endif()
