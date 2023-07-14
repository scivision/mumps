cmake_minimum_required(VERSION 3.13...3.25)

project(MUMPSscotchExamples
LANGUAGES C Fortran
)

enable_testing()

list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_LIST_DIR}/../../cmake/)

if(CMAKE_C_COMPILER_ID MATCHES "Clang|GNU|Intel")
  add_compile_options($<$<COMPILE_LANGUAGE:C>:-Werror-implicit-function-declaration>)
endif()

if(NOT PROJECT_SOURCE_DIR STREQUAL PROJECT_BINARY_DIR)
  file(GENERATE OUTPUT .gitignore CONTENT "*")
endif()

find_package(Threads)
find_package(MPI REQUIRED COMPONENTS C Fortran)
find_package(Scotch REQUIRED COMPONENTS ESMUMPS)
find_package(LAPACK REQUIRED)
find_package(SCALAPACK REQUIRED)
find_package(MUMPS REQUIRED COMPONENTS Scotch)

function(precision_ex a)
  add_executable(${a}_scotch ${a}_scotch.f90)
  target_link_libraries(${a}_scotch PRIVATE MUMPS::MUMPS Scotch::Scotch ${CMAKE_THREAD_LIBS_INIT})
  add_test(NAME ${a}_scotch COMMAND ${a}_scotch)
endfunction()

if(MUMPS_d_FOUND)
  precision_ex("d")
endif()
