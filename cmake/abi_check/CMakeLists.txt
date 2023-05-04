cmake_minimum_required(VERSION 3.5)

project(abi_check LANGUAGES C Fortran)

enable_testing()

# test libraries
add_library(addone OBJECT addone.c)
add_library(addtwo OBJECT addtwo.c)
add_library(addone_f OBJECT addone.f90)

# Fortran main using library.
add_executable(main_f main.f90 $<TARGET_OBJECTS:addone> $<TARGET_OBJECTS:addtwo>)
set_property(TARGET main_f PROPERTY LINKER_LANGUAGE Fortran)
add_test(NAME Fortran_main COMMAND main_f)

# C main using library.
# This can be an issue mixing Clang and Gfortran

add_executable(main_c main.c $<TARGET_OBJECTS:addone_f> $<TARGET_OBJECTS:addtwo>)
target_include_directories(main_c PRIVATE ${CMAKE_CURRENT_SOURCE_DIR})
set_property(TARGET main_c PROPERTY LINKER_LANGUAGE C)
add_test(NAME C_main COMMAND main_c)
