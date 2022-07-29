program adder

use, intrinsic :: iso_fortran_env, only : stderr=>error_unit

implicit none (type, external)

interface

integer function addone(N) bind(C)
integer, intent(in), value :: N
end function addone

end interface


if (addone(2) /= 3)  then
  write(stderr,*) "ERROR: 2+1 /= ", addone(2)
  error stop
endif

print *, "OK: Fortran main with C libraries"


end program
