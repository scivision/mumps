set(_l "${mumps_SOURCE_DIR}/libseq/")

add_library(mpiseq_C OBJECT ${_l}elapse.c ${_l}mpic.c)

add_library(mpiseq_FORTRAN OBJECT ${_l}mpi.f)

add_library(mpiseq $<TARGET_OBJECTS:mpiseq_C> $<TARGET_OBJECTS:mpiseq_FORTRAN>)


foreach(t mpiseq_C mpiseq_FORTRAN mpiseq)

  target_include_directories(${t} PUBLIC
  "$<BUILD_INTERFACE:${_l}>"
  $<INSTALL_INTERFACE:include>
  )

endforeach()

set_property(TARGET mpiseq PROPERTY EXPORT_NAME MPISEQ)

install(TARGETS mpiseq EXPORT ${PROJECT_NAME}-targets)

install(FILES ${_l}elapse.h ${_l}mpi.h ${_l}mpif.h TYPE INCLUDE)

set(NUMERIC_INC ${_l})
list(APPEND NUMERIC_LIBS mpiseq)
