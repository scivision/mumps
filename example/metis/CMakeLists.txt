cmake_minimum_required(VERSION 3.20)

project(MUMPSmetisExamples
LANGUAGES C Fortran
)

enable_testing()

find_package(MUMPS CONFIG REQUIRED)

function(precision_ex a)
  add_executable(${a}_metis ${a}_metis.f90)
  target_link_libraries(${a}_metis PRIVATE MUMPS::MUMPS)
  add_test(NAME ${a}_metis COMMAND ${a}_metis)
endfunction()

if(MUMPS_d_FOUND)
  precision_ex("d")
endif()

file(GENERATE OUTPUT .gitignore CONTENT "*")
