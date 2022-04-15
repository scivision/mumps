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
  find_package(MUMPS)
else()
  find_package(MUMPS COMPONENTS mpiseq)
endif()

if(MUMPS_FOUND)
  if(parallel)
    target_link_libraries(MUMPS::MUMPS INTERFACE SCALAPACK::SCALAPACK MPI::MPI_Fortran MPI::MPI_C)
  else()
    add_library(MPI::MPI_C ALIAS MUMPS::MPISEQ)
    add_library(MPI::MPI_Fortran ALIAS MUMPS::MPISEQ)
  endif()
  target_link_libraries(MUMPS::MUMPS INTERFACE LAPACK::LAPACK)
else()
  include(${PROJECT_SOURCE_DIR}/../cmake/mumps.cmake)
  if(parallel)
    target_link_libraries(MUMPS::MUMPS INTERFACE SCALAPACK::SCALAPACK MPI::MPI_Fortran MPI::MPI_C)
  else()
    target_link_libraries(MUMPS::MUMPS INTERFACE MUMPS::MPISEQ)
  endif()
  target_link_libraries(MUMPS::MUMPS INTERFACE LAPACK::LAPACK)
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
  set_tests_properties(mumps:example_${a} PROPERTIES
  RESOURCE_LOCK cpu_mpi
  TIMEOUT 10
  )

  if(MUMPS_UPSTREAM_VERSION VERSION_GREATER_EQUAL 5.2)
    add_executable(${a}simpletest_save_restore ${a}simpletest_save_restore.F)
    target_link_libraries(${a}simpletest_save_restore PRIVATE MUMPS::MUMPS)

    add_test(NAME mumps:saveRestore_${a}
    COMMAND ${CMAKE_COMMAND} -Dparallel:BOOL=${parallel} -Dexe:FILEPATH=$<TARGET_FILE:${a}simpletest_save_restore> -Din:PATH=${CMAKE_CURRENT_SOURCE_DIR}/${_${a}filename} -P ${PROJECT_SOURCE_DIR}/run_ex.cmake
    )
    set_tests_properties(mumps:saveRestore_${a} PROPERTIES
    RESOURCE_LOCK cpu_mpi
    TIMEOUT 10
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
  set_tests_properties(mumps:example_C PROPERTIES
  RESOURCE_LOCK cpu_mpi
  TIMEOUT 10
  )
endif()
