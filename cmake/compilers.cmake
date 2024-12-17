# --- compiler options

add_compile_definitions("$<$<COMPILE_LANGUAGE:C>:Add_>")
# "Add_" works for all modern compilers we tried.

add_compile_definitions("$<$<BOOL:${intsize64}>:INTSIZE64;PORD_INTSIZE64>")

# --- C options

add_compile_options(
"$<$<COMPILE_LANG_AND_ID:C,IntelLLVM>:$<IF:$<BOOL:${WIN32}>,/Qopenmp,-fiopenmp>>"
"$<$<COMPILE_LANG_AND_ID:C,AppleClang,Clang,GNU,IntelLLVM>:-Werror-implicit-function-declaration;-fno-strict-aliasing>"
"$<$<COMPILE_LANG_AND_ID:C,MSVC>:/openmp>"
)

# --- Fortran options

add_compile_options(
"$<$<COMPILE_LANG_AND_ID:Fortran,IntelLLVM>:$<IF:$<BOOL:${WIN32}>,/Qopenmp,-fiopenmp>>"
"$<$<COMPILE_LANG_AND_ID:Fortran,IntelLLVM>:$<IF:$<BOOL:${WIN32}>,/warn:declarations;/heap-arrays,-implicitnone>>"
"$<$<COMPILE_LANG_AND_ID:Fortran,GNU>:-fimplicit-none>"
"$<$<COMPILE_LANG_AND_ID:Fortran,GNU>:-fno-strict-aliasing>"
"$<$<AND:$<COMPILE_LANG_AND_ID:Fortran,GNU>,$<VERSION_GREATER_EQUAL:${CMAKE_Fortran_COMPILER_VERSION},10>>:-fallow-argument-mismatch;-fallow-invalid-boz>"
)
# IntelLLVM does not have -fno-strict-aliasing for Fortran

if(intsize64)
  add_compile_options(
    "$<$<COMPILE_LANG_AND_ID:Fortran,Intel,IntelLLVM>:-i8>"
    "$<$<COMPILE_LANG_AND_ID:Fortran,GNU>:-fdefault-integer-8>"
  )
  # ALL libraries must be compiled with -fdefault-integer-8, including MPI,
  # or runtime fails
  # See MUMPS 5.7.0 User manual about error -69


  add_compile_definitions($<$<COMPILE_LANG_AND_ID:Fortran,Intel,IntelLLVM>:WORKAROUNDINTELILP64MPI2INTEGER>)
endif()

list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_LIST_DIR})

# Necessary for shared library with Visual Studio / Windows oneAPI
set(CMAKE_WINDOWS_EXPORT_ALL_SYMBOLS true)
