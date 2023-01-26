cmake_minimum_required(VERSION 3.1...3.25)

project(abi_check LANGUAGES C)

enable_testing()

option(fortran "use Fortran" true)

if(fortran)
  enable_language(Fortran)
endif()

# test libraries
add_library(addone OBJECT addone.c)
add_library(addtwo OBJECT addtwo.c)
add_library(addone_f OBJECT "$<IF:$<BOOL:${fortran}>,addone.f90,addone.c>")

# Fortran main using C and C++ libraries
if(fortran)
  add_executable(main_f main.f90 $<TARGET_OBJECTS:addone> $<TARGET_OBJECTS:addtwo>)
  set_property(TARGET main_f PROPERTY LINKER_LANGUAGE Fortran)
  add_test(NAME Fortran_main COMMAND main_f)
endif()

# C main using library.
# This can be an issue mixing Clang and Gfortran

add_executable(main_c main.c $<TARGET_OBJECTS:addone_f> $<TARGET_OBJECTS:addtwo>)
set_property(TARGET main_c PROPERTY LINKER_LANGUAGE C)
add_test(NAME C_main COMMAND main_c)

# test properties
get_property(test_names DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR} PROPERTY TESTS)
set_property(TEST ${test_names} PROPERTY TIMEOUT 10)
