# convenience for testing MUMPS on physical machines, especially for Windows
# as GitHub Actions takes a couple hours to setup Windows oneAPI.
# So a dev might test MUMPS with Windows oneAPI on a laptop.
cmake_minimum_required(VERSION 3.21)

message(STATUS "ENV{CMAKE_BUILD_PARALLEL_LEVEL}: $ENV{CMAKE_BUILD_PARALLEL_LEVEL}")

include(${CMAKE_CURRENT_LIST_DIR}/oneapi_check.cmake)

find_package(MKL CONFIG REQUIRED)

include(${CMAKE_CURRENT_LIST_DIR}/tempdir.cmake)

get_temp_dir(tmpdir)

# save build time
set(BUILD_SINGLE off)
set(BUILD_DOUBLE on)

foreach(MUMPS_parallel IN ITEMS true false)

set(bindir ${tmpdir}/parallel_${MUMPS_parallel})

set(prefix ${bindir}/install)

message(STATUS "Testing MUMPS_parallel=${MUMPS_parallel} in ${bindir}  prefix: ${prefix}")

execute_process(
COMMAND ${CMAKE_COMMAND} -B${bindir} -S${CMAKE_CURRENT_LIST_DIR}/..
  --install-prefix=${prefix}
  -DMUMPS_parallel=${MUMPS_parallel}
  -DCMAKE_C_COMPILER:FILEPATH=${CMAKE_C_COMPILER}
  -DCMAKE_Fortran_COMPILER:FILEPATH=${CMAKE_Fortran_COMPILER}
  -DBUILD_SINGLE:BOOL=${BUILD_SINGLE}
  -DBUILD_DOUBLE:BOOL=${BUILD_DOUBLE}
COMMAND_ERROR_IS_FATAL ANY
)

execute_process(COMMAND ${CMAKE_COMMAND} --build ${bindir}
COMMAND_ERROR_IS_FATAL ANY
)

find_library(mpiseq NAMES mpiseq
PATHS ${bindir}
NO_DEFAULT_PATH
)

if(MUMPS_parallel)
  if(mpiseq)
    message(FATAL_ERROR "mpiseq found in ${mpiseq}, but should not exist for MUMPS_parallel=true build")
  else()
   message(STATUS "mpiseq not found, as expected")
  endif()
else()
  if(mpiseq)
    message(STATUS "mpiseq found in ${mpiseq}, as expected")
  else()
    message(FATAL_ERROR "mpiseq not found, but should exist for serial build")
  endif()
endif()

execute_process(COMMAND ${CMAKE_CTEST_COMMAND} --test-dir ${bindir}
COMMAND_ERROR_IS_FATAL ANY
)

execute_process(COMMAND ${CMAKE_COMMAND} --install ${bindir}
COMMAND_ERROR_IS_FATAL ANY
)

# example
execute_process(
COMMAND ${CMAKE_COMMAND} -B${bindir}/build_example -S${CMAKE_CURRENT_LIST_DIR}/../example
  -DMUMPS_ROOT=${prefix}
  -DCMAKE_C_COMPILER:FILEPATH=${CMAKE_C_COMPILER}
  -DCMAKE_Fortran_COMPILER:FILEPATH=${CMAKE_Fortran_COMPILER}
COMMAND_ERROR_IS_FATAL ANY
)

execute_process(COMMAND ${CMAKE_COMMAND} --build ${bindir}/build_example
COMMAND_ERROR_IS_FATAL ANY
)

execute_process(COMMAND ${CMAKE_CTEST_COMMAND} --test-dir ${bindir}/build_example
COMMAND_ERROR_IS_FATAL ANY
)

endforeach()
