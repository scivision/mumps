% from mumps/MATLAB/README
% Example of using MUMPS in matlab
% initialization of a matlab MUMPS structure
id = initmumps;
% here JOB = -1, the call to MUMPS will initialize C and fortran MUMPS structure
id = dmumps(id);
% load a sparse matrix
load lhr01;
mat = Problem.A;
% JOB = 6 means analysis+factorization+solve
id.JOB = 6;
id.ICNTL(6) = 0;
% we set the rigth hand side
id.RHS = ones(size(mat,1),1);
%call to mumps
id = dmumps(id,mat);
% we see that there is a memory problem in INFO(1) and INFO(2)
id.INFOG(1)
id.INFOG(2)
% we activate the numerical maximum transversal
id.ICNTL(6) = 6;
id = dmumps(id,mat);
norm(mat*id.SOL - ones(size(mat,1),1),'inf')
% solution OK
% destroy mumps instance
id.JOB = -2;
id = dmumps(id)
