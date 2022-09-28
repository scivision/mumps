# --- abi check

# check C and Fortran compiler ABI compatibility

if(NOT abi_ok)
  message(CHECK_START "checking that C and Fortran compilers can link")
  try_compile(abi_ok
  ${CMAKE_CURRENT_BINARY_DIR}/abi_check ${CMAKE_CURRENT_LIST_DIR}/abi_check
  abi_check
  OUTPUT_VARIABLE abi_log
  )
  if(abi_ok)
    message(CHECK_PASS "OK")
  else()
    message(FATAL_ERROR "ABI-incompatible compilers:
    C compiler ${CMAKE_C_COMPILER_ID} ${CMAKE_C_COMPILER_VERSION}
    Fortran compiler ${CMAKE_Fortran_COMPILER_ID} ${CMAKE_Fortran_COMPILER_VERSION}
    ${abi_log}
    "
    )
  endif()
endif()

# --- compiler options

if(DEFINED ENV{CRAYPE_VERSION})
  set(CRAY true)
else()
  set(CRAY false)
endif()

add_compile_definitions("$<$<COMPILE_LANGUAGE:C>:Add_>")
# "Add_" works for all modern compilers we tried.

add_compile_definitions($<$<AND:$<COMPILE_LANGUAGE:C>,$<BOOL:${MSVC}>>:_CRT_SECURE_NO_WARNINGS>)

add_compile_definitions("$<$<BOOL:${intsize64}>:INTSIZE64;PORD_INTSIZE64>")

if(CMAKE_C_COMPILER_ID MATCHES "^Intel")
  add_compile_options($<$<COMPILE_LANGUAGE:C>:-Werror-implicit-function-declaration>)

  if(NOT CMAKE_CROSSCOMPILING AND NOT CRAY)
    if(WIN32)
      add_compile_options($<$<COMPILE_LANGUAGE:C>:/QxHost>)
    else()
      add_compile_options($<$<COMPILE_LANGUAGE:C>:-xHost>)
    endif()
  endif()

  if(openmp AND NOT WIN32 AND CMAKE_VERSION VERSION_GREATER_EQUAL 3.15)
    add_compile_options(
    $<$<COMPILE_LANG_AND_ID:C,IntelLLVM>:-fiopenmp>
    $<$<COMPILE_LANG_AND_ID:C,Intel>:-qopenmp>
    )
  endif()
elseif(CMAKE_C_COMPILER_ID STREQUAL "Clang|GNU")
  add_compile_options($<$<COMPILE_LANGUAGE:C>:-Werror-implicit-function-declaration>)
endif()


if(CMAKE_Fortran_COMPILER_ID MATCHES "^Intel")
  add_compile_options(
  "$<$<COMPILE_LANGUAGE:Fortran>:$<IF:$<BOOL:${WIN32}>,/warn:declarations;/heap-arrays,-implicitnone>>"
  $<$<AND:$<COMPILE_LANGUAGE:Fortran>,$<BOOL:${intsize64}>>:-i8>
  )

  if(NOT CMAKE_CROSSCOMPILING AND NOT CRAY)
    if(WIN32)
      add_compile_options($<$<COMPILE_LANGUAGE:Fortran>:/QxHost>)
    else()
      add_compile_options($<$<COMPILE_LANGUAGE:Fortran>:-xHost>)
    endif()
  endif()

  if(openmp AND NOT WIN32 AND CMAKE_VERSION VERSION_GREATER_EQUAL 3.15)
    add_compile_options(
    $<$<COMPILE_LANG_AND_ID:Fortran,IntelLLVM>:-fiopenmp>
    $<$<COMPILE_LANG_AND_ID:Fortran,Intel>:-qopenmp>
    )
  endif()

  if(intsize64)
    add_compile_definitions($<$<COMPILE_LANGUAGE:Fortran>:WORKAROUNDINTELILP64MPI2INTEGER>)
  endif()

elseif(CMAKE_Fortran_COMPILER_ID STREQUAL "GNU")
  add_compile_options(
  $<$<COMPILE_LANGUAGE:Fortran>:-fimplicit-none>
  $<$<BOOL:${MINGW}>:-w>
  "$<$<AND:$<VERSION_GREATER_EQUAL:${CMAKE_Fortran_COMPILER_VERSION},10>,$<COMPILE_LANGUAGE:Fortran>>:-fallow-argument-mismatch;-fallow-invalid-boz>"
  )
  # MS-MPI emits extreme amounts of nuisance warnings

  if(NOT CMAKE_CROSSCOMPILING AND NOT CRAY)
    add_compile_options(-mtune=native)
  endif()

  if(intsize64 AND DEFINED ENV{I_MPI_ROOT})
    add_compile_options($<$<COMPILE_LANGUAGE:Fortran>:-fdefault-integer-8>)
  endif()
endif()

# Per MUMPS 5.4 manual section 9, not necessary to set default int64. Doing so causes problems at runtime.
