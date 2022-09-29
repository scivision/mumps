include(${CMAKE_CURRENT_LIST_DIR}/lapack.cmake)

if(parallel)
  include(${CMAKE_CURRENT_LIST_DIR}/scalapack.cmake)
endif()

# --- MUMPS

if(CMAKE_Fortran_COMPILER_ID STREQUAL "GNU")
  set(mumps_comp ${arith})
  if(NOT parallel)
    list(APPEND mumps_comp mpiseq)
  endif()

  find_package(MUMPS COMPONENTS ${mumps_comp} REQUIRED)

  if(MUMPS_Scotch_FOUND)
    find_package(Scotch COMPONENTS ESMUMPS REQUIRED)
    find_package(METIS REQUIRED)
  endif()

  if(MUMPS_OpenMP_FOUND)
    find_package(OpenMP COMPONENTS C Fortran REQUIRED)
    target_link_libraries(MUMPS::MUMPS INTERFACE OpenMP::OpenMP_Fortran OpenMP::OpenMP_C)
  endif()
endif()
