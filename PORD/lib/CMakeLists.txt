add_library(pord
graph.c gbipart.c gbisect.c ddcreate.c ddbisect.c nestdiss.c multisector.c gelim.c bucket.c tree.c symbfac.c interface.c sort.c minpriority.c
)
target_include_directories(pord PUBLIC
$<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/../include>
$<INSTALL_INTERFACE:include>
)
set_target_properties(pord PROPERTIES
EXPORT_NAME PORD
LIBRARY_OUTPUT_DIRECTORY ${PROJECT_BINARY_DIR}
ARCHIVE_OUTPUT_DIRECTORY ${PROJECT_BINARY_DIR}
RUNTIME_OUTPUT_DIRECTORY ${PROJECT_BINARY_DIR}
)

install(TARGETS pord EXPORT ${PROJECT_NAME}-targets)
