cmake_minimum_required(VERSION 3.22)

project(MUMPSExamples
LANGUAGES C CXX Fortran
)

enable_testing()

if(CMAKE_C_COMPILER_ID MATCHES "Clang|GNU|Intel")
  add_compile_options($<$<COMPILE_LANGUAGE:C>:-Werror-implicit-function-declaration>)
elseif(CMAKE_C_COMPILER_ID MATCHES "MSVC")
  add_link_options($<$<COMPILE_LANGUAGE:C>:/NODEFAULTLIB:MSVCRT>)
endif()

find_package(MUMPS CONFIG REQUIRED)
message(STATUS "MUMPS_DIR: ${MUMPS_DIR}")

find_package(MPI COMPONENTS CXX REQUIRED)

include(${CMAKE_CURRENT_SOURCE_DIR}/../cmake/launcher.cmake)

function(precision_ex a lang)

  add_executable(${a}_example_${lang} ${a}_example.${lang})
  target_link_libraries(${a}_example_${lang} PRIVATE MUMPS::MUMPS
  "$<$<BOOL:${MPI_CXX_FOUND}>:MPI::MPI_CXX>"
  )

  add_test(NAME ${a}_example_${lang} COMMAND ${a}_example_${lang})

  if(MUMPS_parallel)
    test_mpi_launcher(${a}_example_${lang} 2)
  endif()

endfunction()

if(MUMPS_d_FOUND)
  precision_ex("d" c)
  precision_ex("d" cpp)
endif()
if(MUMPS_z_FOUND)
  precision_ex("z" c)
endif()


# test properties
get_property(test_names DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR} PROPERTY TESTS)

if(MUMPS_parallel)
  set_property(TEST ${test_names} PROPERTY RESOURCE_LOCK cpu_mpi)
endif()

if(WIN32)
  get_property(imp_mumps TARGET MUMPS::COMMON PROPERTY IMPORTED_LOCATION_RELEASE)
  if(imp_mumps)
    cmake_path(GET imp_mumps PARENT_PATH imp_mumps_dir)
  endif()
  set_property(TEST ${test_names} PROPERTY
  ENVIRONMENT_MODIFICATION "PATH=path_list_prepend:${imp_mumps_dir};PATH=path_list_prepend:${CMAKE_PREFIX_PATH}/bin"
  )
endif()

file(GENERATE OUTPUT .gitignore CONTENT "*")
