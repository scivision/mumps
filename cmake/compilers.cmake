# --- compiler options

if(DEFINED ENV{CRAYPE_VERSION})
  set(CRAY true)
else()
  set(CRAY false)
endif()

add_compile_definitions("$<$<COMPILE_LANGUAGE:C>:Add_>")
# "Add_" works for all modern compilers we tried.

add_compile_definitions(
  "$<$<AND:$<COMPILE_LANGUAGE:C>,$<BOOL:${MSVC}>>:_CRT_SECURE_NO_WARNINGS;_CRT_NONSTDC_NO_WARNINGS>"
)

add_compile_definitions("$<$<BOOL:${intsize64}>:INTSIZE64;PORD_INTSIZE64>")

if(CMAKE_C_COMPILER_ID MATCHES "^Intel")
  add_compile_options($<$<COMPILE_LANGUAGE:C>:-Werror-implicit-function-declaration>)

  if(NOT CMAKE_CROSSCOMPILING AND NOT CRAY)
    add_compile_options($<$<COMPILE_LANGUAGE:C>:$<IF:$<BOOL:${WIN32}>,/QxHost,-xHost>>)
  endif()

  add_compile_options($<$<COMPILE_LANG_AND_ID:C,IntelLLVM>:$<IF:$<BOOL:${WIN32}>,/Qopenmp,-fiopenmp>>)
elseif(CMAKE_C_COMPILER_ID MATCHES "Clang|GNU")
  add_compile_options("$<$<COMPILE_LANGUAGE:C>:-Werror-implicit-function-declaration;-fno-strict-aliasing>")
elseif(CMAKE_C_COMPILER_ID MATCHES "MSVC")
  add_compile_options($<$<COMPILE_LANGUAGE:C>:/openmp>)
endif()


if(CMAKE_Fortran_COMPILER_ID MATCHES "^Intel")
  add_compile_options(
  "$<$<COMPILE_LANGUAGE:Fortran>:$<IF:$<BOOL:${WIN32}>,/warn:declarations;/heap-arrays,-implicitnone>>"
  $<$<AND:$<COMPILE_LANGUAGE:Fortran>,$<BOOL:${intsize64}>>:-i8>
  )

  if(NOT CMAKE_CROSSCOMPILING AND NOT CRAY)
    add_compile_options($<$<COMPILE_LANGUAGE:Fortran>:$<IF:$<BOOL:${WIN32}>,/QxHost,-xHost>>)
  endif()

  add_compile_options($<$<COMPILE_LANG_AND_ID:Fortran,IntelLLVM>:$<IF:$<BOOL:${WIN32}>,/Qopenmp,-fiopenmp>>)

  if(intsize64)
    add_compile_definitions($<$<COMPILE_LANGUAGE:Fortran>:WORKAROUNDINTELILP64MPI2INTEGER>)
  endif()

elseif(CMAKE_Fortran_COMPILER_ID STREQUAL "GNU")
  add_compile_options(
  $<$<COMPILE_LANGUAGE:Fortran>:-fimplicit-none>
  "$<$<AND:$<VERSION_GREATER_EQUAL:${CMAKE_Fortran_COMPILER_VERSION},10>,$<COMPILE_LANGUAGE:Fortran>>:-fallow-argument-mismatch;-fallow-invalid-boz;-fno-strict-aliasing>"
  )

  if(NOT CMAKE_CROSSCOMPILING AND NOT CRAY)
    add_compile_options(-mtune=native)
  endif()

  if(intsize64)
    # ALL libraries must be compiled with -fdefault-integer-8, including MPI or runtime fails
    # See MUMPS 5.7.0 User manual about error -69
    add_compile_options($<$<COMPILE_LANGUAGE:Fortran>:-fdefault-integer-8>)
  endif()
endif()

list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_LIST_DIR})

# Necessary for shared library with Visual Studio / Windows oneAPI
set(CMAKE_WINDOWS_EXPORT_ALL_SYMBOLS true)
