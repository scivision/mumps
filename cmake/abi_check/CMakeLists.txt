cmake_minimum_required(VERSION 3.1...3.25)
project(abi_check LANGUAGES C Fortran)

enable_testing()

add_library(addone OBJECT addone.c)
add_executable(main_f main.f90 $<TARGET_OBJECTS:addone>)
set_property(TARGET main_f PROPERTY LINKER_LANGUAGE Fortran)
add_test(NAME Fortran_main COMMAND main_f)

add_library(addone_f OBJECT addone.f90)

add_executable(main_c main.c $<TARGET_OBJECTS:addone_f>)
set_property(TARGET main_c PROPERTY LINKER_LANGUAGE C)
add_test(NAME C_main COMMAND main_c)

set_property(TEST Fortran_main C_main PROPERTY TIMEOUT 10)
