set_property(DIRECTORY PROPERTY LABELS matlab)

if(NOT "d" IN_LIST arith)
  message(STATUS "Matlab requires arith=d be present.")
  return()
endif()

if(parallel)
  message(WARNING "MUMPS MEX assumes no MPI (cmake -Dparallel=no)")
endif()

if(matlab)
  find_package(Matlab REQUIRED COMPONENTS MEX_COMPILER MAIN_PROGRAM)
elseif(octave)
  find_package(Octave REQUIRED COMPONENTS Development Interpreter)
endif()

set(mumps_matlab_path ${mumps_SOURCE_DIR}/MATLAB)

if(matlab)

matlab_add_mex(NAME dmumpsmex
SHARED
SRC mumpsmex.c
LINK_TO MUMPS::MUMPS
)

add_test(NAME matlabMEX
COMMAND ${Matlab_MAIN_PROGRAM} -batch "addpath('${PROJECT_BINARY_DIR}', '${mumps_matlab_path}', '${PROJECT_SOURCE_DIR}/matlab'), example"
)
set_property(TEST matlabMEX PROPERTY TIMEOUT 90)

elseif(octave)

add_library(dmumpsmex SHARED mumpsmex.c)
target_link_libraries(dmumpsmex PRIVATE MUMPS::MUMPS Octave::Octave)
set_property(TARGET dmumpsmex PROPERTY SUFFIX .mex)
set_property(TARGET dmumpsmex PROPERTY PREFIX "")


add_test(NAME octaveMEX
COMMAND ${Octave_EXECUTABLE} --eval "addpath('${PROJECT_BINARY_DIR}', '${mumps_matlab_path}', '${PROJECT_SOURCE_DIR}/matlab'), example"
)

set_property(TEST octaveMEX PROPERTY TIMEOUT 15)

endif()

target_compile_definitions(dmumpsmex PRIVATE MUMPS_ARITH=MUMPS_ARITH_d)

set_property(TARGET dmumpsmex PROPERTY RUNTIME_OUTPUT_DIRECTORY ${PROJECT_BINARY_DIR})
set_property(TARGET dmumpsmex PROPERTY LIBRARY_OUTPUT_DIRECTORY ${PROJECT_BINARY_DIR})
