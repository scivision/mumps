# For dev testing, to ease testing of shared libraries, which
# may not show run path problems until executables are run.

cmake_minimum_required(VERSION 3.21)

include(${CMAKE_CURRENT_LIST_DIR}/GetTempdir.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/ProjectBuild.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/ExampleBuild.cmake)

get_tempdir(tempdir)

set(BUILD_SINGLE off)
set(BUILD_DOUBLE on)
set(BUILD_SHARED_LIBS on)

if(APPLE)
  # update periodically with latest Homebrew GCC version, as 'gcc' is AppleClang
  set(CCs clang)
  set(FCs flang)
  find_program(brew NAMES brew)
  if(brew)
    execute_process(COMMAND ${brew} --prefix gcc RESULT_VARIABLE ret OUTPUT_VARIABLE gcc_root OUTPUT_STRIP_TRAILING_WHITESPACE)
    if(ret EQUAL 0)
      list(APPEND CCs ${gcc_root}/bin/gcc)
      list(APPEND FCs ${gcc_root}/bin/gfortran)
    endif()
  endif()
else()
  set(CCs gcc)
  set(FCs gfortran)
endif()


foreach(CMAKE_C_COMPILER CMAKE_Fortran_COMPILER IN ZIP_LISTS CCs FCs)
  foreach(MUMPS_parallel IN ITEMS true false)

    set(bindir ${tempdir}/mumps_shared_build_${MUMPS_parallel}_${CMAKE_C_COMPILER}_${CMAKE_Fortran_COMPILER})
    set(prefix ${bindir}/install)

    message(STATUS "MUMP_parallel=${MUMPS_parallel}
    binary_dir: ${bindir}
    temp install dir: ${prefix}"
    )

    project_build(${prefix} ${bindir})

    execute_process(COMMAND ${CMAKE_CTEST_COMMAND} --test-dir ${bindir} -V
    COMMAND_ERROR_IS_FATAL ANY
    )

    example_build(${bindir}/example)

  endforeach()
endforeach()
