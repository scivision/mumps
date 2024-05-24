# If the environment variable(s) aren't set, ensure you've first run oneapi-vars.[sh|bat]
# from the desired oneAPI installation.

function(check_env var)

if(NOT DEFINED ENV{${var}})
  message(WARNING "environment variable ${var} not defined, this is an unexpected system configuration for oneAPI")
  return()
endif()

if(NOT IS_DIRECTORY $ENV{${var}})
  message(WARNING "${var}=$ENV{${var}} is not a directory")
  return()
endif()

message(STATUS "${var}: $ENV{${var}}")

endfunction()

check_env(ONEAPI_ROOT)
check_env(CMPLR_ROOT)
check_env(MKLROOT)

function(check_compiler lang)

if(lang STREQUAL "C")
  set(name icx)
elseif(lang STREQUAL "CXX")
  set(name icpx)
elseif(lang STREQUAL "Fortran")
  set(name ifx)
else()
  message(FATAL_ERROR "unsupported language ${lang}")
endif()

find_program(CMAKE_${lang}_COMPILER
NAMES ${name}
HINTS $ENV{CMPLR_ROOT}
PATH_SUFFIXES bin
NO_DEFAULT_PATH
)

if(CMAKE_${lang}_COMPILER)
  message(STATUS "${lang} compiler: ${CMAKE_${lang}_COMPILER}")
else()
  message(FATAL_ERROR "no ${lang} compiler found")
endif()

endfunction()

check_compiler(C)
check_compiler(Fortran)

find_library(mkl
NAMES mkl_core
HINTS $ENV{MKLROOT}
NO_DEFAULT_PATH
PATH_SUFFIXES lib
)

if(mkl)
  message(STATUS "MKL core: ${mkl}")
else()
  message(WARNING "MKL not found")
endif()

find_library(mkl_scalapack
NAMES mkl_scalapack_lp64
HINTS $ENV{MKLROOT}
PATH_SUFFIXES lib
NO_DEFAULT_PATH
)

if(mkl_scalapack)
  message(STATUS "MKL Scalapack: ${mkl_scalapack}")
else()
  message(wARNING "MKL Scalapack not found")
endif()
