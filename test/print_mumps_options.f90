program main

use, intrinsic :: iso_fortran_env, only : output_unit

implicit none

external :: mumps_print_if_defined

call mumps_print_if_defined(output_unit)

end program main
