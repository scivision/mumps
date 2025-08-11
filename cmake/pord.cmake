set(_p "${mumps_SOURCE_DIR}/PORD/lib/")

add_library(pord ${_p}graph.c ${_p}gbipart.c ${_p}gbisect.c ${_p}ddcreate.c ${_p}ddbisect.c ${_p}nestdiss.c ${_p}multisector.c ${_p}gelim.c ${_p}bucket.c ${_p}tree.c ${_p}symbfac.c ${_p}interface.c ${_p}sort.c ${_p}minpriority.c)

target_include_directories(pord PUBLIC
$<BUILD_INTERFACE:${mumps_SOURCE_DIR}/PORD/include>
$<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
)

target_compile_definitions(pord PRIVATE ${mumps_cdefs})
target_compile_options(pord PRIVATE ${mumps_cflags})

set_property(TARGET pord PROPERTY EXPORT_NAME PORD)
install(TARGETS pord EXPORT ${PROJECT_NAME}-targets)
