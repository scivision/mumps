include(FeatureSummary)
add_feature_info(Parallel MUMPS_parallel "parallel MUMPS (using MPI and Scalapack)")
add_feature_info(64-bit-integer intsize64 "use 64-bit integers in C and Fortran")
add_feature_info(GEMMT BLAS_HAVE_GEMMT "use GEMMT for symmetric matrix-matrix multiplication")

add_feature_info(ScalaPACK MUMPS_scalapack "Scalapack linear algebra library https://www.netlib.org/scalapack/")
add_feature_info(METIS metis "METIS graph partitioning https://github.com/KarypisLab/METIS")
add_feature_info(parMETIS parmetis "parMETIS parallel graph partitioning")

add_feature_info(Scotch scotch "Scotch graph partitioning https://www.labri.fr/perso/pelegrin/scotch/")

add_feature_info(Openmp MUMPS_openmp "OpenMP API https://www.openmp.org/")

add_feature_info(real32 ${BUILD_SINGLE} "Build with single precision")
add_feature_info(real64 ${BUILD_DOUBLE} "Build with double precision")
add_feature_info(complex32 ${BUILD_COMPLEX} "Build with complex precision")
add_feature_info(complex64 ${BUILD_COMPLEX16} "Build with complex16 precision")
add_feature_info(shared ${BUILD_SHARED_LIBS} "Build shared libraries")

feature_summary(WHAT ENABLED_FEATURES DISABLED_FEATURES)
