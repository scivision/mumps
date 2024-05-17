set(_l "${mumps_SOURCE_DIR}/libseq/")

add_library(mpiseq_C OBJECT ${_l}elapse.c ${_l}mpic.c)
target_include_directories(mpiseq_C PUBLIC
"$<BUILD_INTERFACE:${_l}>"
$<INSTALL_INTERFACE:include>
)

add_library(mpiseq_FORTRAN OBJECT ${_l}mpi.f)
target_include_directories(mpiseq_FORTRAN PUBLIC
"$<BUILD_INTERFACE:${_l}>"
$<INSTALL_INTERFACE:include>
)

add_library(mpiseq $<TARGET_OBJECTS:mpiseq_C> $<TARGET_OBJECTS:mpiseq_FORTRAN>)

target_include_directories(mpiseq PUBLIC
"$<BUILD_INTERFACE:${_l}>"
$<INSTALL_INTERFACE:include>
)

set_property(TARGET mpiseq PROPERTY EXPORT_NAME MPISEQ)

install(TARGETS mpiseq EXPORT ${PROJECT_NAME}-targets)

install(FILES ${_l}elapse.h ${_l}mpi.h ${_l}mpif.h TYPE INCLUDE)

set(NUMERIC_INC ${_l})
list(APPEND NUMERIC_LIBS mpiseq)
