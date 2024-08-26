option(intsize64 "use 64-bit integers in C and Fortran--METIS must be consistent with MUMPS")

# -Dprefix is where to install
# -Dbindir is where to install

set(target "metis")

set(args -Dintsize64:BOOL=${intsize64})
if(prefix)
  list(APPEND args -DCMAKE_INSTALL_PREFIX:PATH=${prefix})
endif()

include(${CMAKE_CURRENT_LIST_DIR}/run_cmake.cmake)
