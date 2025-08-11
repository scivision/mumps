cmake_minimum_required(VERSION 3.21)

project(MUMPSmetisExamples
LANGUAGES C Fortran
)

enable_testing()

if(PROJECT_IS_TOP_LEVEL)
  find_package(MUMPS CONFIG REQUIRED)
endif()

function(precision_ex a)
  add_executable(${a}_metis ${a}_metis.f90)
  target_link_libraries(${a}_metis PRIVATE MUMPS::MUMPS
  MPI::MPI_Fortran MPI::MPI_C
  $<$<BOOL:${MUMPS_openmp}>:OpenMP::OpenMP_Fortran>
  )
  # always link MPI as we use the libmpiseq if not MUMPS_parallel

  add_test(NAME ${a}_metis COMMAND ${a}_metis)
  set_tests_properties(${a}_metis PROPERTIES LABELS "Metis")
endfunction()

if(MUMPS_d_FOUND OR BUILD_DOUBLE)
  precision_ex("d")
endif()

file(GENERATE OUTPUT .gitignore CONTENT "*")
