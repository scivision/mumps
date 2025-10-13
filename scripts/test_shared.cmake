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
set(CMAKE_Fortran_COMPILER gfortran)

if(APPLE)
  # update periodically with latest Homebrew GCC version, as 'gcc' is AppleClang
  set(CCs clang)
  find_program(brew NAMES brew)
  if(brew)
    execute_process(COMMAND ${brew} --prefix gcc RESULT_VARIABLE ret OUTPUT_VARIABLE gcc_root OUTPUT_STRIP_TRAILING_WHITESPACE)
    file(GLOB cand LIST_DIRECTORIES false ${gcc_root}/bin/gcc-*)
    # filter out non-numeric suffixes like gcc-ar, gcc-nm, gcc-ranlib
    list(FILTER cand INCLUDE REGEX ".*gcc-[0-9]+$")
    # sort to get latest version last
    list(SORT cand COMPARE NATURAL)
    list(GET cand -1 _latest_gcc)
    list(APPEND CCs ${_latest_gcc})
  endif()
endif()

message(VERBOSE "CCs: ${CCs}")


foreach(CMAKE_C_COMPILER IN LISTS CCs)
  foreach(MUMPS_parallel IN ITEMS true false)

    cmake_path(GET CMAKE_C_COMPILER STEM cc)
    cmake_path(GET CMAKE_Fortran_COMPILER STEM fc)

    set(bindir ${tempdir}/mumps_shared_build_${MUMPS_parallel}_${cc}_${fc})
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
