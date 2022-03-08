cmake_minimum_required(VERSION 3.19...3.22)

project(MUMPSExamples
LANGUAGES C Fortran
)

enable_testing()

list(APPEND CMAKE_MODULE_PATH ${PROJECT_SOURCE_DIR}/../cmake/Modules)

set(MUMPS_UPSTREAM_VERSION 5.3.5)
set(arith s d)
option(parallel "use MPI" true)
set(autobuild true)
set(FETCHCONTENT_UPDATES_DISCONNECTED_MUMPS true)
set_directory_properties(PROPERTIES EP_UPDATE_DISCONNECTED true)

if(CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
  set(CMAKE_INSTALL_PREFIX ${CMAKE_BINARY_DIR} CACHE PATH "Install top-level directory" FORCE)
endif()

find_package(LAPACK REQUIRED)

if(parallel)
  find_package(MPI COMPONENTS C Fortran REQUIRED)
  find_package(SCALAPACK REQUIRED)
  find_package(MUMPS)
else()
  find_package(MUMPS COMPONENTS mpiseq)
endif()

if(NOT MUMPS_FOUND)
  include(${PROJECT_SOURCE_DIR}/../cmake/mumps.cmake)
endif()

# --- Examples from MUMPS itself
set(_sfilename input_simpletest_real)
set(_dfilename input_simpletest_real)
set(_cfilename input_simpletest_cmplx)
set(_zfilename input_simpletest_cmplx)

foreach(a s d)
  if(NOT ${a} IN_LIST arith)
    continue()
  endif()

  add_executable(${a}simpletest ${a}simpletest.F)
  target_link_libraries(${a}simpletest PRIVATE MUMPS::MUMPS
  LAPACK::LAPACK
  )
  if(parallel)
    target_link_libraries(${a}simpletest PRIVATE SCALAPACK::SCALAPACK MPI::MPI_Fortran MPI::MPI_C)
  else()
    target_link_libraries(${a}simpletest PRIVATE MUMPS::MPISEQ)
  endif()

  add_test(NAME mumps:example_${a}
  COMMAND ${CMAKE_COMMAND} -Dparallel:BOOL=${parallel} -Dexe:FILEPATH=$<TARGET_FILE:${a}simpletest> -Din:PATH=${CMAKE_CURRENT_SOURCE_DIR}/${_${a}filename} -P ${PROJECT_SOURCE_DIR}/run_ex.cmake
  )
  set_tests_properties(mumps:example_${a} PROPERTIES
  RESOURCE_LOCK cpu_mpi
  TIMEOUT 10
  )

  if(MUMPS_UPSTREAM_VERSION VERSION_GREATER_EQUAL 5.2)
    add_executable(${a}simpletest_save_restore ${a}simpletest_save_restore.F)
    target_link_libraries(${a}simpletest_save_restore PRIVATE MUMPS::MUMPS
    LAPACK::LAPACK
    )
    if(parallel)
      target_link_libraries(${a}simpletest_save_restore PRIVATE SCALAPACK::SCALAPACK MPI::MPI_Fortran MPI::MPI_C)
    else()
      target_link_libraries(${a}simpletest_save_restore PRIVATE MUMPS::MPISEQ)
    endif()

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

if(d IN_LIST arith)
  add_executable(c_example c_example.c)
  target_link_libraries(c_example PRIVATE MUMPS::MUMPS
  LAPACK::LAPACK
  )
  set_target_properties(c_example PROPERTIES LINKER_LANGUAGE Fortran)
  if(parallel)
    target_link_libraries(c_example PRIVATE SCALAPACK::SCALAPACK MPI::MPI_Fortran MPI::MPI_C)
  else()
    target_link_libraries(c_example PRIVATE MUMPS::MPISEQ)
  endif()

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
