cmake_minimum_required(VERSION 3.21)

project(MUMPSscotchExamples
LANGUAGES C Fortran
)

enable_testing()

if(PROJECT_IS_TOP_LEVEL)
  find_package(MUMPS CONFIG REQUIRED)
endif()

function(precision_ex a)
  add_executable(${a}_scotch ${a}_scotch.f90)
  target_link_libraries(${a}_scotch PRIVATE MUMPS::MUMPS
  $<$<NOT:$<BOOL:${PROJECT_IS_TOP_LEVEL}>>:SCOTCH::scotch>
  MPI::MPI_Fortran MPI::MPI_C
  )
  # always link MPI as we use the libmpiseq if not MUMPS_parallel

  add_test(NAME ${a}_scotch COMMAND ${a}_scotch)
  set_tests_properties(${a}_scotch PROPERTIES LABELS "Scotch")
endfunction()

if(MUMPS_d_FOUND OR BUILD_DOUBLE)
  precision_ex("d")
endif()

file(GENERATE OUTPUT .gitignore CONTENT "*")
