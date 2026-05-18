! main_mumps_omp.F90
!
! A simple Fortran example to solve Ax=b using the MUMPS solver with OpenMP.
! The matrix A is a small, sparse, symmetric positive definite matrix.
! The loop responsible for assembling the matrix is parallelized with OpenMP.
!
PROGRAM MAIN_MUMPS_OMP

  use, intrinsic :: iso_fortran_env

  IMPLICIT NONE

  include 'mpif.h'
  INCLUDE 'dmumps_struc.h'

  TYPE(DMUMPS_STRUC) :: id

  ! Variable declarations
  INTEGER :: i, ierr, myid, n, nz
  INTEGER, ALLOCATABLE :: irn(:), jcn(:)
  REAL(KIND=8), ALLOCATABLE :: a(:), b(:)

  ! ====================================================================
  ! 1. Initialization
  ! ====================================================================

  n = 5  ! The size of the square matrix A
  ierr = 0

  ! MUMPS requires MPI, so we initialize it first.
  CALL MPI_INIT(ierr)
  CALL MPI_COMM_RANK(MPI_COMM_WORLD, myid, ierr)

  IF (myid == 0) THEN
    WRITE(*,*) ">> MUMPS simple example with OpenMP <<"
    WRITE(*,*) "   Matrix size (N) = ", n
  END IF

  ! Initialize the MUMPS control structure with default values.
  id%job = -1 ! -1 indicates an initialization call.
  id%par = 1  ! The host process will participate in computations.
  id%sym = 2  ! The matrix is symmetric positive definite.
  ! Set the MPI communicator for MUMPS.
  id%COMM = MPI_COMM_WORLD
  CALL DMUMPS(id)
  IF (id%infog(1) < 0) THEN
    WRITE(error_Unit,*) "MUMPS initialization error:", id%infog(1)
    error stop
  END IF

  ! Set the problem size.
  id%n = n

  ! Use an automatic ordering strategy chosen by MUMPS.
  id%icntl(7) = 5

  ! ====================================================================
  ! 2. Matrix and RHS Assembly (Parallelized with OpenMP)
  ! ====================================================================

  ! nz is the number of non-zero entries in the lower triangular part, including the diagonal.
  nz = n + (n - 1)
  ALLOCATE(irn(nz), jcn(nz), a(nz), b(n))

  ! Use OpenMP to parallelize the matrix assembly.
  ! Each thread will work on a portion of the loop iterations.
  !$OMP PARALLEL DEFAULT(SHARED) PRIVATE(i)

  ! Populate the matrix A in coordinate format (COO).
  ! We are creating a simple tridiagonal matrix:
  !
  !   A = | 2 -1  0  0  0 |
  !       |-1  2 -1  0  0 |
  !       | 0 -1  2 -1  0 |
  !       | 0  0 -1  2 -1 |
  !       | 0  0  0 -1  2 |
  !
  ! For a symmetric matrix, we only need to provide the lower triangular part.
  print '(a)', 'entering OMP DO'
  !$OMP DO
  DO i = 1, n
    ! Diagonal elements
    irn(i) = i
    jcn(i) = i
    a(i)   = 2.0D0

    ! Off-diagonal elements (sub-diagonal)
    IF (i < n) THEN
      irn(n + i) = i + 1
      jcn(n + i) = i
      a(n + i)   = -1.0D0
    END IF
  END DO
  !$OMP END DO

  ! Use a single thread to initialize the right-hand side vector b to avoid race conditions.
  !$OMP SINGLE
  b(:) = 1.0D0
  !$OMP END SINGLE

  !$OMP END PARALLEL

  print '(a)', "Exited OMP PARALLEL"
  ! ====================================================================
  ! 3. Solve the system Ax = b
  ! ====================================================================

  ! Pass the matrix and RHS to the MUMPS structure.
  ALLOCATE( id%IRN ( nz ) )
  ALLOCATE( id%JCN ( nz ) )
  ALLOCATE( id%A( nz ) )
  ALLOCATE( id%RHS ( n  ) )
  id%nz = nz
  id%irn = irn
  id%jcn = jcn
  id%a = a
  id%rhs = b  ! MUMPS will use this as the RHS and return the solution in it.
  
  print '(a)', 'entering MUMPS solve'
  ! Call MUMPS to perform analysis, factorization, and solve (Job = 6).
  id%job = 6
  CALL DMUMPS(id)
  IF (id%infog(1) < 0) THEN
    WRITE(*,*) "Error during MUMPS solve:", id%infog(1)
    error stop
  END IF

  ! ====================================================================
  ! 4. Display Results
  ! ====================================================================

  ! Only the host process prints the solution.
  IF (myid == 0) THEN
    WRITE(*,*)
    WRITE(*,*) "Solution vector x:"
    ! The solution is returned in the id%rhs array.
    DO i = 1, n
      WRITE(*,'(F8.4)') id%rhs(i)
    END DO
  END IF

  ! ====================================================================
  ! 5. Finalize
  ! ====================================================================

  ! Terminate MUMPS and release its internal memory.
  id%job = -2 ! -2 indicates a termination call.
  CALL DMUMPS(id)

  ! Finalize MPI.
  CALL MPI_FINALIZE(ierr)

  ! Deallocate arrays.
  DEALLOCATE(irn, jcn, a, b)

END PROGRAM MAIN_MUMPS_OMP
