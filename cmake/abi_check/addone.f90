module adder

use, intrinsic :: iso_c_binding, only : C_INT
implicit none (type, external)

contains

pure integer(C_INT) function addone(N) bind(C)
integer(C_INT), intent(in), value :: N
addone = N + 1
end function addone

end module adder
