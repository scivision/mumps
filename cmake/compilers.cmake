# --- abi check

# check C and Fortran compiler ABI compatibility

if(NOT abi_ok)
  message(CHECK_START "checking that C and Fortran compilers can link")
  try_compile(abi_ok ${CMAKE_CURRENT_BINARY_DIR}/abi_check ${CMAKE_CURRENT_LIST_DIR}/abi_check abi_check)
  if(abi_ok)
    message(CHECK_PASS "OK")
  else()
    message(FATAL_ERROR "ABI-incompatible: C compiler ${CMAKE_C_COMPILER_ID} ${CMAKE_C_COMPILER_VERSION} and Fortran compiler ${CMAKE_Fortran_COMPILER_ID} ${CMAKE_Fortran_COMPILER_VERSION}")
  endif()
endif()

# --- compiler check

add_compile_definitions(CDEFS "Add_")
# "Add_" works for all modern compilers we tried.

set(_gcc10opts)
if(CMAKE_Fortran_COMPILER_ID STREQUAL GNU AND CMAKE_Fortran_COMPILER_VERSION VERSION_GREATER_EQUAL 10)
  set(_gcc10opts "-fallow-argument-mismatch -fallow-invalid-boz")
endif()



if(CMAKE_Fortran_COMPILER_ID STREQUAL Intel)
  if(WIN32)
    add_compile_options(/QxHost)
    # /heap-arrays is necessary to avoid runtime errors in programs using this library
    string(APPEND CMAKE_Fortran_FLAGS " /warn:declarations /heap-arrays")
  else()
    add_compile_options(-xHost)
    string(APPEND CMAKE_Fortran_FLAGS " -warn declarations")
  endif()
elseif(CMAKE_Fortran_COMPILER_ID STREQUAL GNU)
  add_compile_options(-mtune=native)
  string(APPEND CMAKE_Fortran_FLAGS " -fimplicit-none ${_gcc10opts}")
  if(MINGW)
    # presumably using MS-MPI, which emits extreme amounts of nuisance warnings
    string(APPEND CMAKE_Fortran_FLAGS " -w")
  endif(MINGW)
endif()

if(intsize64)
  set(FORTRAN_FLAG_INT64 "")
  if(CMAKE_Fortran_COMPILER_ID STREQUAL Intel)
    if(WIN32)
      set(FORTRAN_FLAG_INT64 " /i8")
    else()
      set(FORTRAN_FLAG_INT64 " -i8")
    endif()
  elseif(CMAKE_Fortran_COMPILER_ID STREQUAL GNU)
    set(FORTRAN_FLAG_INT64 " -fdefault-integer-8")
  endif()
  message(STATUS "setting Fortran integer 64 bits using:${FORTRAN_FLAG_INT64}")
  string(APPEND CMAKE_Fortran_FLAGS ${FORTRAN_FLAG_INT64})
endif(intsize64)
