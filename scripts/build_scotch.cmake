cmake_minimum_required(VERSION 3.19)

option(intsize64 "use 64-bit integers in C and Fortran--Scotch must be consistent with MUMPS")
# -Dprefix is where to install

if(NOT bindir)
  find_program(mktemp NAMES mktemp)
  if(mktemp)
    execute_process(COMMAND mktemp -d OUTPUT_VARIABLE bindir OUTPUT_STRIP_TRAILING_WHITESPACE)
  else()
    string(RANDOM LENGTH 12 _s)
    if(DEFINED ENV{TEMP})
      set(bindir $ENV{TEMP}/${_s})
    elseif(IS_DIRECTORY "/tmp")
      set(bindir /tmp/${_s})
    else()
      set(bindir ${CMAKE_CURRENT_BINARY_DIR}/${_s})
    endif()
  endif()
endif()

execute_process(COMMAND ${CMAKE_COMMAND} ${args}
-B${bindir}
-S${CMAKE_CURRENT_LIST_DIR}
-DCMAKE_INSTALL_PREFIX:PATH=${prefix}
RESULT_VARIABLE ret
)

# avoid overloading CPU/RAM with extreme GNU Make --parallel
cmake_host_system_information(RESULT N QUERY NUMBER_OF_PHYSICAL_CORES)

if(ret EQUAL 0)
  message(STATUS "Scotch build with ${N} workers")
else()
  message(FATAL_ERROR "Scotch failed to configure.")
endif()

execute_process(
COMMAND ${CMAKE_COMMAND} --build ${bindir} --parallel ${N} -t scotch
RESULT_VARIABLE ret
)

if(ret EQUAL 0)
  message(STATUS "Scotch install complete.")
else()
  message(FATAL_ERROR "Scotch failed to build and install.")
endif()
