cmake_minimum_required(VERSION 3.13...3.20)

project(MUMPS_examples
LANGUAGES C Fortran)

include(CTest)

if(NOT MUMPS_ROOT AND NOT DEFINED ENV{MUMPS_ROOT})
  set(MUMPS_ROOT ${PROJECT_SOURCE_DIR}/../build)
endif()

find_package(MUMPS REQUIRED)

if(CMAKE_Fortran_COMPILER_ID STREQUAL GNU AND CMAKE_Fortran_COMPILER_VERSION VERSION_GREATER_EQUAL 10)
  string(APPEND CMAKE_Fortran_FLAGS "-fallow-argument-mismatch -fallow-invalid-boz")
  if(MINGW)
    add_compile_options(-w)
  endif()
endif()

# --- build examples

find_program(PWSH NAMES pwsh powershell)

set(_sfilename input_simpletest_real)
set(_dfilename input_simpletest_real)
set(_cfilename input_simpletest_cmplx)
set(_zfilename input_simpletest_cmplx)

foreach(a s d)
  # echo_target_properties(MUMPS::${a}mumps)
  string(TOUPPER ${a} aup)
  if(NOT TARGET MUMPS::${aup}MUMPS)
    continue()
  endif()

  add_executable(${a}simpletest ${a}simpletest.F)
  target_link_libraries(${a}simpletest PRIVATE MUMPS::MUMPS MPI::MPI_Fortran)
  if(PWSH)
    add_test(NAME mumps:example_${a} COMMAND ${PWSH} -c \"Get-Content ${CMAKE_CURRENT_SOURCE_DIR}/${_${a}filename} | ${MPIEXEC_EXECUTABLE} ${MPIEXEC_NUMPROC_FLAG} 2 $<TARGET_FILE:${a}simpletest>\")
  elseif(UNIX)
    add_test(NAME mumps:example_${a} COMMAND sh -c "${MPIEXEC_EXECUTABLE} ${MPIEXEC_NUMPROC_FLAG} 2 $<TARGET_FILE:${a}simpletest> < ${CMAKE_CURRENT_SOURCE_DIR}/${_${a}filename}")
  endif()
  if(TEST mumps:example_${a})
    set_tests_properties(mumps:example_${a} PROPERTIES RESOURCE_LOCK cpu_mpi)
  endif()

  add_executable(${a}simpletest_save_restore ${a}simpletest_save_restore.F)
  target_link_libraries(${a}simpletest_save_restore PRIVATE MUMPS::MUMPS MPI::MPI_Fortran)
  if(PWSH)
    add_test(NAME mumps:saveRestore_${a} COMMAND ${PWSH} -c \"Get-Content ${CMAKE_CURRENT_SOURCE_DIR}/${_${a}filename} | ${MPIEXEC_EXECUTABLE} ${MPIEXEC_NUMPROC_FLAG} 2 $<TARGET_FILE:${a}simpletest_save_restore>\")
  elseif(UNIX)
    add_test(NAME mumps:saveRestore_${a} COMMAND ${SHELL} -c "${MPIEXEC_EXECUTABLE} ${MPIEXEC_NUMPROC_FLAG} 2 $<TARGET_FILE:${a}simpletest_save_restore> < ${CMAKE_CURRENT_SOURCE_DIR}/${_${a}filename}")
  endif()
  if(TEST)
    set_tests_properties(mumps:saveRestore_${a} PROPERTIES RESOURCE_LOCK cpu_mpi)
  endif()
endforeach()

if(TARGET MUMPS::DMUMPS)
  add_executable(c_example c_example.c)
  target_link_libraries(c_example PRIVATE MUMPS::MUMPS MPI::MPI_C)
  add_test(NAME mumps:example_C COMMAND ${MPIEXEC_EXECUTABLE} ${MPIEXEC_NUMPROC_FLAG} 2 $<TARGET_FILE:c_example>)
  set_tests_properties(mumps:example_C PROPERTIES RESOURCE_LOCK cpu_mpi)
endif()
