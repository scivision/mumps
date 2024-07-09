include(CheckSourceCompiles)

if(TARGET MKL::MKL)
  set(CMAKE_REQUIRED_LIBRARIES MKL::MKL)
  if(MUMPS_parallel)
    list(APPEND CMAKE_REQUIRED_LIBRARIES MPI::MPI_Fortran)
  endif()
else()
  set(CMAKE_REQUIRED_LIBRARIES LAPACK::LAPACK)
endif()

function(check_gemmt)

set(CMAKE_TRY_COMPILE_TARGET_TYPE "EXECUTABLE")

if(BUILD_DOUBLE)
check_source_compiles(Fortran
"program check
use, intrinsic :: iso_fortran_env, only : real64
implicit none
external :: dgemmt
real(real64), dimension(2,2) :: A, B, C
CALL DGEMMT( 'U', 'N', 'T',  2 , 1 , 1._real64 , A , 2 , B , 2 , 1._real64 , C , 2 )
end program"
BLAS_HAVE_dGEMMT
)
endif()

if(BUILD_SINGLE)
check_source_compiles(Fortran
"program check
use, intrinsic :: iso_fortran_env, only : real32
implicit none
external :: sgemmt
real(real32), dimension(2,2) :: A, B, C
CALL SGEMMT( 'U', 'N', 'T',  2 , 1 , 1._real32 , A , 2 , B , 2 , 1._real32 , C , 2 )
end program"
BLAS_HAVE_sGEMMT
)
endif()

if(BUILD_COMPLEX)
check_source_compiles(Fortran
"program check
use, intrinsic :: iso_fortran_env, only : real32
implicit none
external :: cgemmt
complex(real32), dimension(2,2) :: A, B, C
CALL CGEMMT( 'U', 'N', 'T',  2 , 1 , 1._real32 , A , 2 , B , 2 , 1._real32 , C , 2 )
end program"
BLAS_HAVE_cGEMMT
)
endif()

if(BUILD_COMPLEX16)
check_source_compiles(Fortran
"program check
use, intrinsic :: iso_fortran_env, only : real64
implicit none
external :: zgemmt
complex(real64), dimension(2,2) :: A, B, C
CALL ZGEMMT( 'U', 'N', 'T',  2 , 1 , 1._real64 , A , 2 , B , 2 , 1._real64 , C , 2 )
end program"
BLAS_HAVE_zGEMMT
)
endif()

endfunction(check_gemmt)

check_gemmt()
