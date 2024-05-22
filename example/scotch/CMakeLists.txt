cmake_minimum_required(VERSION 3.19)

project(MUMPSscotchExamples
LANGUAGES C Fortran
)

enable_testing()

find_package(MUMPS CONFIG REQUIRED)

function(precision_ex a)
  add_executable(${a}_scotch ${a}_scotch.f90)
  target_link_libraries(${a}_scotch PRIVATE MUMPS::MUMPS)
  add_test(NAME ${a}_scotch COMMAND ${a}_scotch)
endfunction()

if(MUMPS_d_FOUND)
  precision_ex("d")
endif()

file(GENERATE OUTPUT .gitignore CONTENT "*")
