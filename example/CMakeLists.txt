cmake_minimum_required(VERSION 3.22)

project(MUMPSExamples
LANGUAGES C Fortran
)

enable_testing()

if(CMAKE_C_COMPILER_ID MATCHES "Clang|GNU|Intel")
  add_compile_options($<$<COMPILE_LANGUAGE:C>:-Werror-implicit-function-declaration>)
elseif(CMAKE_C_COMPILER_ID MATCHES "MSVC")
  add_link_options($<$<COMPILE_LANGUAGE:C>:/NODEFAULTLIB:MSVCRT>)
endif()

find_package(MUMPS CONFIG REQUIRED)
message(STATUS "MUMPS_DIR: ${MUMPS_DIR}")

function(precision_ex a)

  add_executable(${a}_example ${a}_example.c)
  target_link_libraries(${a}_example PRIVATE MUMPS::MUMPS)

  if(MUMPS_parallel)
    add_test(NAME ${a}_example_C
      COMMAND ${MPIEXEC_EXECUTABLE} ${MPIEXEC_NUMPROC_FLAG} 2 $<TARGET_FILE:${a}_example>)
  else()
    add_test(NAME ${a}_example_C COMMAND ${a}_example)
  endif()

endfunction()

if(MUMPS_d_FOUND)
  precision_ex("d")
endif()
if(MUMPS_z_FOUND)
  precision_ex("z")
endif()


# test properties
get_property(test_names DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR} PROPERTY TESTS)

if(MUMPS_parallel)
  set_property(TEST ${test_names} PROPERTY RESOURCE_LOCK cpu_mpi)
endif()

if(WIN32)
  get_property(imp_mumps TARGET MUMPS::COMMON PROPERTY IMPORTED_LOCATION_RELEASE)
  if(imp_mumps)
    get_filename_component(imp_mumps_dir ${imp_mumps} DIRECTORY)
  endif()
  set_property(TEST ${test_names} PROPERTY
  ENVIRONMENT_MODIFICATION "PATH=path_list_prepend:${imp_mumps_dir};PATH=path_list_prepend:${CMAKE_PREFIX_PATH}/bin"
  )
endif()

file(GENERATE OUTPUT .gitignore CONTENT "*")
