set(MPI_C_INCLUDE_DIRS "${mumps_SOURCE_DIR}/libseq")
set(MPI_Fortran_INCLUDE_DIRS "${mumps_SOURCE_DIR}/libseq")

add_library(mpiseq_c
${mumps_SOURCE_DIR}/libseq/elapse.c
${mumps_SOURCE_DIR}/libseq/mpic.c
)
target_include_directories(mpiseq_c PUBLIC
"$<BUILD_INTERFACE:${MPI_C_INCLUDE_DIRS}>"
$<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
)
target_compile_options(mpiseq_c PRIVATE ${mumps_cflags})
target_compile_definitions(mpiseq_c PRIVATE ${mumps_cdefs})

add_library(mpiseq_fortran ${mumps_SOURCE_DIR}/libseq/mpi.f)
target_include_directories(mpiseq_fortran PUBLIC
"$<BUILD_INTERFACE:${MPI_Fortran_INCLUDE_DIRS}>"
$<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
)
target_compile_options(mpiseq_fortran PRIVATE ${mumps_fflags})

# Ensure linking mpi_fortran to mpi_c for missing symbol resolution
target_link_libraries(mpiseq_fortran PUBLIC mpiseq_c)

# we don't use this target directly, but it's to be compatible with other build systems that make a
# libmpiseq file
add_library(mpiseq $<TARGET_OBJECTS:mpiseq_c> $<TARGET_OBJECTS:mpiseq_fortran>)
target_link_libraries(mpiseq PUBLIC mpiseq_c mpiseq_fortran)

set_property(TARGET mpiseq PROPERTY EXPORT_NAME MPISEQ)

install(TARGETS mpiseq mpiseq_c mpiseq_fortran EXPORT ${PROJECT_NAME}-targets)

# mpi.f doesn't have Fortran module
install(FILES ${MPI_C_INCLUDE_DIRS}/elapse.h ${MPI_C_INCLUDE_DIRS}/mpi.h ${MPI_C_INCLUDE_DIRS}/mpif.h TYPE INCLUDE)

# This is used in place of find_package(MPI) in MUMPS when MUMPS_parallel is OFF
add_library(MPI::MPI_C INTERFACE IMPORTED)
target_link_libraries(MPI::MPI_C INTERFACE mpiseq_c)

add_library(MPI::MPI_Fortran INTERFACE IMPORTED)
target_link_libraries(MPI::MPI_Fortran INTERFACE mpiseq_fortran)
