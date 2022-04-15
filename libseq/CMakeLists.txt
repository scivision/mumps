add_library(mpiseq elapse.c mpi.f mpic.c)
target_include_directories(mpiseq PUBLIC
"$<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR};${CMAKE_CURRENT_BINARY_DIR}/include>"
$<INSTALL_INTERFACE:include>
)
set_target_properties(mpiseq PROPERTIES
Fortran_MODULE_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/include
LIBRARY_OUTPUT_DIRECTORY ${PROJECT_BINARY_DIR}
ARCHIVE_OUTPUT_DIRECTORY ${PROJECT_BINARY_DIR}
RUNTIME_OUTPUT_DIRECTORY  ${PROJECT_BINARY_DIR}
EXPORT_NAME MPISEQ
)

# target for FetchContent
# this must NOT be an ALIAS or linking in other packages breaks.
add_library(MUMPS::MPISEQ INTERFACE IMPORTED GLOBAL)
target_link_libraries(MUMPS::MPISEQ INTERFACE mpiseq)

install(TARGETS mpiseq EXPORT ${PROJECT_NAME}-targets)

install(FILES
${CMAKE_CURRENT_SOURCE_DIR}/elapse.h
${CMAKE_CURRENT_SOURCE_DIR}/mpi.h
${CMAKE_CURRENT_SOURCE_DIR}/mpif.h
TYPE INCLUDE
)

# so that tests/examples work
add_library(MPI::MPI_C ALIAS MUMPS::MPISEQ)
add_library(MPI::MPI_Fortran ALIAS MUMPS::MPISEQ)
