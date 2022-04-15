include(FeatureSummary)
add_feature_info(Parallel parallel "parallel MUMPS (using MPI and Scalapack)")
add_feature_info(64-bit-integer intsize64 "use 64-bit integers in C and Fortran")

add_feature_info(Scotch scotch "Scotch graph partitioning https://www.labri.fr/perso/pelegrin/scotch/")
add_feature_info(Openmp openmp "OpenMP API https://www.openmp.org/")

feature_summary(WHAT ENABLED_FEATURES DISABLED_FEATURES)
