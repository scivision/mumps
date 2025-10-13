# For dev testing, to ease testing of shared libraries, which
# may not show run path problems until executables are run.
include(${CMAKE_CURRENT_LIST_DIR}/GetTempdir.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/ProjectBuild.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/ExampleBuild.cmake)

get_tempdir(tempdir)

set(BUILD_SINGLE off)
set(BUILD_DOUBLE on)
set(BUILD_SHARED_LIBS on)

foreach(MUMPS_parallel IN ITEMS true false)

set(bindir ${tempdir}/mumps_shared_build_${MUMPS_parallel})
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
