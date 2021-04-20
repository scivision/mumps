add_library(mpiseq elapse.c mpi.f mpic.c)
target_include_directories(mpiseq
  PRIVATE ${CMAKE_CURRENT_SOURCE_DIR} ${CMAKE_CURRENT_BINARY_DIR}/include
  INTERFACE
  $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>
  $<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}/include>
  $<INSTALL_INTERFACE:include>
  )
set_target_properties(mpiseq PROPERTIES
  Fortran_MODULE_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/include
  EXPORT_NAME MPISEQ)

# target for FetchContent
# this must NOT be an ALIAS or linking in other packages breaks.
add_library(MUMPS::MPISEQ INTERFACE IMPORTED GLOBAL)
target_link_libraries(MUMPS::MPISEQ INTERFACE mpiseq)

install(TARGETS mpiseq
  EXPORT ${PROJECT_NAME}Targets
  ARCHIVE DESTINATION lib
  LIBRARY DESTINATION lib
  RUNTIME DESTINATION bin
  INCLUDES DESTINATION include)

install(FILES
  ${CMAKE_CURRENT_SOURCE_DIR}/elapse.h
  ${CMAKE_CURRENT_SOURCE_DIR}/mpi.h
  ${CMAKE_CURRENT_SOURCE_DIR}/mpif.h
  DESTINATION include)
