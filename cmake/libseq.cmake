set(_l "${mumps_SOURCE_DIR}/libseq/")

add_library(mpiseq ${_l}elapse.c ${_l}mpi.f ${_l}mpic.c)

target_include_directories(mpiseq PUBLIC
"$<BUILD_INTERFACE:${_l}>"
$<INSTALL_INTERFACE:include>
)

set_property(TARGET mpiseq PROPERTY EXPORT_NAME MPISEQ)

install(TARGETS mpiseq EXPORT ${PROJECT_NAME}-targets)

install(FILES ${_l}elapse.h ${_l}mpi.h ${_l}mpif.h TYPE INCLUDE)
