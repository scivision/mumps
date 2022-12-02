program test_scotch
implicit none
external :: mumps_scotch_version
integer :: vers
call mumps_scotch_version(vers)
print '(a,i0)', "MUMPS Scotch version: ", vers
end program
