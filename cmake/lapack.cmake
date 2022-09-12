# Handle options for finding LAPACK

include(CheckFortranSourceCompiles)

if(NOT DEFINED LAPACK_COMPONENTS AND DEFINED ENV{MKLROOT})
  set(LAPACK_COMPONENTS MKL)
endif()

if(MKL IN_LIST LAPACK_COMPONENTS)
  if(intsize64)
    list(APPEND LAPACK_COMPONENTS MKL64)
  endif()
  if(openmp)
    list(APPEND LAPACK_COMPONENTS OpenMP)
  endif()
endif()

if(find_static)
  list(APPEND LAPACK_COMPONENTS STATIC)
endif()

find_package(LAPACK REQUIRED COMPONENTS ${LAPACK_COMPONENTS})

# GEMMT is recommeded in MUMPS User Manual if available
if(gemmt)

set(CMAKE_REQUIRED_INCLUDES ${LAPACK_INCLUDE_DIRS})

if(find_static AND NOT WIN32 AND
  MKL IN_LIST LAPACK_COMPONENTS AND
  CMAKE_VERSION VERSION_GREATER_EQUAL 3.24
  )
  set(CMAKE_REQUIRED_LIBRARIES $<LINK_GROUP:RESCAN,${LAPACK_LIBRARIES}>)
else()
  set(CMAKE_REQUIRED_LIBRARIES ${LAPACK_LIBRARIES})
endif()

set(BLAS_HAVE_GEMMT true)

if("d" IN_LIST arith AND BLAS_HAVE_GEMMT)
check_fortran_source_compiles(
"program check
use, intrinsic :: iso_fortran_env, only : real64
implicit none
external :: dgemmt
real(real64), dimension(2,2) :: A, B, C
CALL DGEMMT( 'U', 'N', 'T',  2 , 1 , 1._real64 , A , 2 , B , 2 , 1._real64 , C , 2 )
end program"
BLAS_HAVE_dGEMMT
SRC_EXT f90
)
if(NOT BLAS_HAVE_dGEMMT)
  set(BLAS_HAVE_GEMMT false)
endif()
endif()

if("s" IN_LIST arith AND BLAS_HAVE_GEMMT)
check_fortran_source_compiles(
"program check
use, intrinsic :: iso_fortran_env, only : real32
implicit none
external :: sgemmt
real(real32), dimension(2,2) :: A, B, C
CALL SGEMMT( 'U', 'N', 'T',  2 , 1 , 1._real32 , A , 2 , B , 2 , 1._real32 , C , 2 )
end program"
BLAS_HAVE_sGEMMT
SRC_EXT f90
)
if(NOT BLAS_HAVE_sGEMMT)
  set(BLAS_HAVE_GEMMT false)
endif()
endif()

if("c" IN_LIST arith AND BLAS_HAVE_GEMMT)
check_fortran_source_compiles(
"program check
use, intrinsic :: iso_fortran_env, only : real32
implicit none
external :: cgemmt
complex(real32), dimension(2,2) :: A, B, C
CALL CGEMMT( 'U', 'N', 'T',  2 , 1 , 1._real32 , A , 2 , B , 2 , 1._real32 , C , 2 )
end program"
BLAS_HAVE_cGEMMT
SRC_EXT f90
)
if(NOT BLAS_HAVE_cGEMMT)
  set(BLAS_HAVE_GEMMT false)
endif()
endif()

if("z" IN_LIST arith AND BLAS_HAVE_GEMMT)
check_fortran_source_compiles(
"program check
use, intrinsic :: iso_fortran_env, only : real64
implicit none
external :: zgemmt
complex(real64), dimension(2,2) :: A, B, C
CALL ZGEMMT( 'U', 'N', 'T',  2 , 1 , 1._real64 , A , 2 , B , 2 , 1._real64 , C , 2 )
end program"
BLAS_HAVE_zGEMMT
SRC_EXT f90
)
if(NOT BLAS_HAVE_zGEMMT)
  set(BLAS_HAVE_GEMMT false)
endif()
endif()

if(BLAS_HAVE_GEMMT)
  add_compile_definitions($<$<COMPILE_LANGUAGE:Fortran>:GEMMT_AVAILABLE>)
endif()

endif(gemmt)
