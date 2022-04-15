cmake_minimum_required(VERSION 3.19...3.23)

project(MUMPSExamples
LANGUAGES C Fortran
)

enable_testing()

list(APPEND CMAKE_MODULE_PATH ${PROJECT_SOURCE_DIR}/../cmake/Modules)

option(parallel "use MPI" true)
set(FETCHCONTENT_UPDATES_DISCONNECTED_MUMPS true)
set_directory_properties(PROPERTIES EP_UPDATE_DISCONNECTED true)

if(CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
  set(CMAKE_INSTALL_PREFIX ${CMAKE_BINARY_DIR} CACHE PATH "Install top-level directory" FORCE)
endif()

if(parallel)
  find_package(MUMPS REQUIRED)
else()
  find_package(MUMPS COMPONENTS mpiseq REQUIRED)
endif()

# --- Examples from MUMPS itself
set(_sfilename input_simpletest_real)
set(_dfilename input_simpletest_real)
set(_cfilename input_simpletest_cmplx)
set(_zfilename input_simpletest_cmplx)

foreach(a s d)
  if(NOT MUMPS_${a}_FOUND)
    continue()
  endif()

  add_executable(${a}simpletest ${a}simpletest.F)
  target_link_libraries(${a}simpletest PRIVATE MUMPS::MUMPS)

  add_test(NAME mumps:example_${a}
  COMMAND ${CMAKE_COMMAND} -Dparallel:BOOL=${parallel} -Dexe:FILEPATH=$<TARGET_FILE:${a}simpletest> -Din:PATH=${CMAKE_CURRENT_SOURCE_DIR}/${_${a}filename} -P ${PROJECT_SOURCE_DIR}/run_ex.cmake
  )

  if(MUMPS_UPSTREAM_VERSION VERSION_GREATER_EQUAL 5.2)
    add_executable(${a}simpletest_save_restore ${a}simpletest_save_restore.F)
    target_link_libraries(${a}simpletest_save_restore PRIVATE MUMPS::MUMPS)

    add_test(NAME mumps:saveRestore_${a}
    COMMAND ${CMAKE_COMMAND} -Dparallel:BOOL=${parallel} -Dexe:FILEPATH=$<TARGET_FILE:${a}simpletest_save_restore> -Din:PATH=${CMAKE_CURRENT_SOURCE_DIR}/${_${a}filename} -P ${PROJECT_SOURCE_DIR}/run_ex.cmake
    )
    set_tests_properties(mumps:saveRestore_${a} PROPERTIES
    DISABLED $<BOOL:${intsize64}>
    )
  endif()
endforeach()

if(MUMPS_d_FOUND)
  add_executable(c_example c_example.c)
  target_link_libraries(c_example PRIVATE MUMPS::MUMPS)
  set_target_properties(c_example PROPERTIES LINKER_LANGUAGE Fortran)  # GCC needs Fortran

  if(parallel)
    add_test(NAME mumps:example_C
      COMMAND ${MPIEXEC_EXECUTABLE} ${MPIEXEC_NUMPROC_FLAG} 2 $<TARGET_FILE:c_example>)
  else()
    add_test(NAME mumps:example_C COMMAND c_example)
  endif()
endif()


# Windows DLL
get_property(test_names DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR} PROPERTY TESTS)

set_tests_properties(${test_names} PROPERTIES
RESOURCE_LOCK cpu_mpi
TIMEOUT 10
)

if(WIN32 AND CMAKE_VERSION VERSION_GREATER_EQUAL 3.22)
  set_tests_properties(${test_names} PROPERTIES
  ENVIRONMENT_MODIFICATION "PATH=path_list_append:${CMAKE_INSTALL_PREFIX}/bin;PATH=path_list_append:${CMAKE_PREFIX_PATH}/bin;PATH=path_list_append:${PROJECT_BINARY_DIR}"
  )
endif()
