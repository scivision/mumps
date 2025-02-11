# If the environment variable(s) aren't set, ensure you've first run oneapi-vars.{sh|bat}
# from the desired oneAPI installation.

function(check_env var)

if(NOT DEFINED ENV{${var}})
  message(WARNING "environment variable ${var} not defined, this is an unexpected system configuration for oneAPI")
  return()
endif()

if(NOT IS_DIRECTORY $ENV{${var}})
  message(FATAL_ERROR "${var}=$ENV{${var}} is not a directory")
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
  if(WIN32)
    # CMake doesn't yet handle icpx on Windows
    set(name icx)
  endif()
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
REQUIRED
)

message(STATUS "${lang} compiler: ${CMAKE_${lang}_COMPILER}")

endfunction()

check_compiler(C)
check_compiler(Fortran)
