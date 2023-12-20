if(NOT BUILD_DOUBLE)
  message(FATAL_ERROR "Matlab requires real64: `cmake -DBUILD_DOUBLE=true`")
endif()

if(parallel)
  message(WARNING "MUMPS MEX assumes no MPI (cmake -Dparallel=no)")
endif()

set(mumps_matlab_path ${mumps_SOURCE_DIR}/MATLAB)

if(matlab)

find_package(Matlab REQUIRED COMPONENTS MEX_COMPILER MAIN_PROGRAM)

matlab_add_mex(NAME dmumpsmex
SHARED
SRC ${mumps_matlab_path}/mumpsmex.c
LINK_TO MUMPS::MUMPS
)

add_test(NAME matlabMEX
COMMAND ${Matlab_MAIN_PROGRAM} -sd ${mumps_matlab_path}
-batch "addpath('$<TARGET_FILE_DIR:dmumps>'), sparserhs_example"
)
set_property(TEST matlabMEX PROPERTY TIMEOUT 15)
# sometimes the example succeeds but hangs on cleanup

elseif(octave)

find_package(Octave REQUIRED COMPONENTS Development Interpreter)

add_library(dmumpsmex SHARED ${mumps_matlab_path}/mumpsmex.c)
target_link_libraries(dmumpsmex PRIVATE MUMPS::MUMPS Octave::Octave)
set_property(TARGET dmumpsmex PROPERTY SUFFIX .mex)
set_property(TARGET dmumpsmex PROPERTY PREFIX "")


add_test(NAME octaveMEX
COMMAND ${Octave_EXECUTABLE} -p ${mumps_matlab_path}
--eval "addpath('$<TARGET_FILE_DIR:dmumps>'), sparserhs_example"
)
set_property(TEST octaveMEX PROPERTY TIMEOUT 15)

endif()

target_compile_definitions(dmumpsmex PRIVATE MUMPS_ARITH=MUMPS_ARITH_d)
