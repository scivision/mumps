program s_simple
!  This file is part of MUMPS 5.2.1, released
!  on Fri Jun 14 14:46:05 UTC 2019

use, intrinsic :: iso_fortran_env, only: stderr=>error_unit, stdout=>output_unit, int32

implicit none

include 'mpif.h'
INCLUDE 'smumps_struc.h'
TYPE (sMUMPS_STRUC) mumps_par
INTEGER :: num_mpi
integer(int32) :: ierr

CALL MPI_INIT(IERR)
if(ierr/=0) error stop 'problem initializing MPI'

call MPI_COMM_size(MPI_COMM_WORLD, num_mpi, ierr)
if(ierr/=0) error stop 'problem getting number of MPI processes'
print '(A,I3,A)', 'using ',num_mpi,' MPI processes'
! Define a communicator for the package.
mumps_par%COMM = MPI_COMM_WORLD
!  Initialize an instance of the package
!  for L U factorization (sym = 0, with working host)
mumps_par%JOB = -1
mumps_par%SYM = 0
mumps_par%PAR = 1

CALL sMUMPS(mumps_par)

mumps_par%icntl(1) = stderr  ! error messages
mumps_par%icntl(2) = stdout !  diagnostic, statistics, and warning messages
mumps_par%icntl(3) = stdout! ! global info, for the host (myid==0)
mumps_par%icntl(4) = 1           ! default is 2, this reduces verbosity

! === config done, now check config
IF (mumps_par%INFOG(1) < 0) THEN
  WRITE(stderr,'(A,A,I6,A,I9)') " ERROR RETURN: ", &
  "  mumps_par%INFOG(1)= ", mumps_par%INFOG(1), &
  "  mumps_par%INFOG(2)= ", mumps_par%INFOG(2)

  error stop
END IF
!  Define problem on the host (processor 0)
IF ( mumps_par%MYID == 0 ) THEN
  mumps_par%N = 5
  mumps_par%NNZ = 12
  ALLOCATE( mumps_par%IRN ( mumps_par%NNZ ) )
  ALLOCATE( mumps_par%JCN ( mumps_par%NNZ ) )
  ALLOCATE( mumps_par%A( mumps_par%NNZ ) )
  ALLOCATE( mumps_par%RHS ( mumps_par%N  ) )
  mumps_par%IRN = [1,2,4,5,2,1,5,3,2,3,1,3]
  mumps_par%JCN = [2,3,3,5,1,1,2,4,5,2,3,3]
  mumps_par%A   = [3., -3., 2., 1., 3., 2., 4., 2., 6., -1., 4., 1.]

  mumps_par%RHS = [20., 24., 9., 6., 13.]
END IF
!  Call package for solution
mumps_par%JOB = 6
CALL sMUMPS(mumps_par)
IF (mumps_par%INFOG(1) < 0) THEN
  WRITE(stderr,'(A,A,I6,A,I9)') " ERROR RETURN: ", &
  "  mumps_par%INFOG(1)= ", mumps_par%INFOG(1), &
  "  mumps_par%INFOG(2)= ", mumps_par%INFOG(2)

 error stop
END IF
!  Solution has been assembled on the host

IF ( mumps_par%MYID == 0 ) THEN
  print *, ' Solution is: '
  print *, mumps_par%RHS

  if (sum(mumps_par%rhs-[1,2,3,4,5]) > 0.01) error stop 'excessive error in computation'
END IF
!  Deallocate user data
IF ( mumps_par%MYID == 0 )THEN
  DEALLOCATE( mumps_par%IRN )
  DEALLOCATE( mumps_par%JCN )
  DEALLOCATE( mumps_par%A   )
  DEALLOCATE( mumps_par%RHS )
END IF
!  Destroy the instance (deallocate internal data structures)
mumps_par%JOB = -2
CALL sMUMPS(mumps_par)
IF (mumps_par%INFOG(1) < 0) THEN
  WRITE(stderr,'(A,A,I6,A,I9)') " ERROR RETURN: ", &
  "  mumps_par%INFOG(1)= ", mumps_par%INFOG(1), &
  "  mumps_par%INFOG(2)= ", mumps_par%INFOG(2)

 error stop
END IF

call mpi_finalize(ierr)

END program
