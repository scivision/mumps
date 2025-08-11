program test_omp

implicit none
external :: mumps_ana_omp_return, MUMPS_ICOPY_32TO64_64C

call mumps_ana_omp_return()
call MUMPS_ICOPY_32TO64_64C()

end program
