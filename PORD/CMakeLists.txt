add_library(pord)
target_include_directories(pord PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/include
  INTERFACE
  $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
  $<INSTALL_INTERFACE:include>)
set_target_properties(pord PROPERTIES
  EXPORT_NAME PORD
  LIBRARY_OUTPUT_DIRECTORY ${PROJECT_BINARY_DIR}
  ARCHIVE_OUTPUT_DIRECTORY ${PROJECT_BINARY_DIR})

install(TARGETS pord EXPORT ${PROJECT_NAME}Targets)

add_subdirectory(lib)

# .h files not needed
# install(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/include/ DESTINATION include)
