# -- generated MUMPS_INTSIZE header
if(MUMPS_ACTUAL_VERSION VERSION_GREATER_EQUAL 5.5)
  set(intsrc ${CMAKE_CURRENT_SOURCE_DIR}/mumps_int_def)
  if(MUMPS_intsize64)
    string(APPEND intsrc 64_h.in)
  else()
    string(APPEND intsrc 32_h.in)
  endif()
  configure_file(${intsrc} ${CMAKE_CURRENT_SOURCE_DIR}/../include/mumps_int_def.h COPYONLY)
else()
  if(MUMPS_intsize64)
    set(MUMPS_INTSIZE MUMPS_INTSIZE64)
  else()
    set(MUMPS_INTSIZE MUMPS_INTSIZE32)
  endif()
  file(CONFIGURE OUTPUT ${CMAKE_CURRENT_SOURCE_DIR}/../include/mumps_int_def.h
CONTENT "#ifndef MUMPS_INT_H
#define MUMPS_INT_H
#define ${MUMPS_INTSIZE}
#endif"
@ONLY)
endif()

# -- Mumps COMMON
set(COMM_SRC_Fortran mumps_ooc_common.F mumps_static_mapping.F mumps_mpitoomp_m.F
ana_omp_m.F double_linked_list.F
fac_asm_build_sort_index_ELT_m.F fac_asm_build_sort_index_m.F fac_descband_data_m.F fac_future_niv2_mod.F fac_maprow_data_m.F
front_data_mgt_m.F mumps_l0_omp_m.F omp_tps_common_m.F
ana_orderings_wrappers_m.F lr_common.F mumps_memory_mod.F
)

if(MUMPS_ACTUAL_VERSION VERSION_GREATER_EQUAL 5.3)
  list(APPEND COMM_SRC_Fortran ana_blk_m.F)
endif()
if(MUMPS_ACTUAL_VERSION VERSION_GREATER_EQUAL 5.6)
  list(APPEND COMM_SRC_Fortran mumps_pivnul_mod.F)
endif()
if(MUMPS_ACTUAL_VERSION VERSION_GREATER_EQUAL 5.7)
  list(APPEND COMM_SRC_Fortran sol_ds_common_m.F)
endif()
if(MUMPS_ACTUAL_VERSION VERSION_LESS 5.8)
  list(APPEND COMM_SRC_Fortran fac_ibct_data_m.F mumps_comm_ibcast.F)
else()
  list(APPEND COMM_SRC_Fortran lr_stats.F mumps_comm_buffer_common.F mumps_intr_types_common.F mumps_load.F sol_omp_common_m.F tools_common_m.F)
endif()

set(COMM_OTHER_C mumps_common.c mumps_io_basic.c mumps_io_thread.c mumps_io_err.c mumps_io.c mumps_numa.c mumps_pord.c mumps_thread.c mumps_save_restore_C.c)

set(COMM_OTHER_Fortran ana_orderings.F ana_set_ordering.F ana_AMDMF.F bcast_errors.F estim_flops.F
mumps_type2_blocking.F mumps_version.F mumps_print_defined.F tools_common.F
)

if(MUMPS_ACTUAL_VERSION VERSION_LESS 5.6)
  list(APPEND COMM_OTHER_C mumps_size.c)
else()
  list(APPEND COMM_OTHER_C mumps_addr.c)
endif()

list(APPEND COMM_OTHER_C mumps_config_file_C.c mumps_thread_affinity.c sol_common.F)

if(MUMPS_ACTUAL_VERSION VERSION_GREATER_EQUAL 5.3)
  list(APPEND COMM_OTHER_Fortran ana_blk.F)
endif()
if(MUMPS_ACTUAL_VERSION VERSION_GREATER_EQUAL 5.4)
  list(APPEND COMM_OTHER_C mumps_register_thread.c)
endif()
if(MUMPS_ACTUAL_VERSION VERSION_LESS 5.7)
  list(APPEND COMM_OTHER_Fortran mumps_type_size.F)
endif()
if(MUMPS_ACTUAL_VERSION VERSION_GREATER_EQUAL 5.8)
  list(APPEND COMM_OTHER_C mumps_flytes.c)
endif()
if(MUMPS_ACTUAL_VERSION VERSION_GREATER_EQUAL 5.9)
  list(APPEND COMM_OTHER_C mumps_sol_omp_memory_manager.c)
endif()

if(MUMPS_scotch)
  list(APPEND COMM_OTHER_C mumps_scotch.c mumps_scotch64.c mumps_scotch_int.c)
endif()
if(MUMPS_metis OR MUMPS_parmetis)
  list(APPEND COMM_OTHER_C mumps_metis.c mumps_metis64.c mumps_metis_int.c)
endif()

add_library(mumps_common_C OBJECT ${COMM_OTHER_C})
target_link_libraries(mumps_common_C PRIVATE MPI::MPI_C)
target_compile_definitions(mumps_common_C PRIVATE ${mumps_cdefs})
target_compile_options(mumps_common_C PRIVATE ${mumps_cflags})

add_library(mumps_common_Fortran OBJECT ${COMM_SRC_Fortran} ${COMM_OTHER_Fortran})
target_link_libraries(mumps_common_Fortran PRIVATE
MPI::MPI_Fortran
$<$<BOOL:${MUMPS_openmp}>:OpenMP::OpenMP_Fortran>
)
target_compile_definitions(mumps_common_Fortran PRIVATE ${mumps_fdefs})
target_compile_options(mumps_common_Fortran PRIVATE ${mumps_fflags})

add_library(mumps_common $<TARGET_OBJECTS:mumps_common_Fortran> $<TARGET_OBJECTS:mumps_common_C>)

# use MPI_Fortran_INCLUDE_DIRS directly to avoid MPICH Fortran -fallow flag leakage

foreach(t IN ITEMS mumps_common mumps_common_C mumps_common_Fortran)
  target_include_directories(${t} PUBLIC
  "$<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR};${CMAKE_CURRENT_SOURCE_DIR}/../include>"
  $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
  )

  if(MUMPS_ptscotch)
    target_link_libraries(${t} PUBLIC SCOTCH::ptesmumps SCOTCH::ptscotch SCOTCH::ptscotcherr)
  endif()
  if(MUMPS_scotch)
    target_link_libraries(${t} PUBLIC SCOTCH::esmumps SCOTCH::scotch SCOTCH::scotcherr)
  endif()

  target_link_libraries(${t} PUBLIC
  $<$<BOOL:${MUMPS_parmetis}>:PARMETIS::PARMETIS>
  $<$<BOOL:${MUMPS_metis}>:METIS::METIS>
  pord
  $<$<AND:$<BOOL:${MUMPS_scalapack}>,$<BOOL:${MUMPS_parallel}>>:SCALAPACK::SCALAPACK>
  LAPACK::LAPACK
  "$<$<BOOL:${MUMPS_gpu}>:CUDA::cublas;CUDA::cudart>"
  $<$<BOOL:${IMPI_LIB64}>:${IMPI_LIB64}>
  ${CMAKE_THREAD_LIBS_INIT}
  )

  target_compile_definitions(${t} PRIVATE
  ${ORDERING_DEFS}
  $<$<AND:$<COMPILE_LANGUAGE:Fortran>,$<NOT:$<BOOL:${MUMPS_scalapack}>>>:NOSCALAPACK>
  )

  if(BLAS_HAVE_GEMMT)
    target_compile_definitions(${t} PRIVATE $<$<COMPILE_LANGUAGE:Fortran>:GEMMT_AVAILABLE>)
  endif()
endforeach()

target_link_libraries(mumps_common PRIVATE
MPI::MPI_Fortran MPI::MPI_C
$<$<BOOL:${MUMPS_openmp}>:OpenMP::OpenMP_Fortran>
)
# this is needed for mpiseq, and is best for clarity and consistency

if(BUILD_SHARED_LIBS AND APPLE AND CMAKE_Fortran_COMPILER_ID STREQUAL "LLVMFlang")
  # flang linker can't handle -dynamiclib flag
  set_property(TARGET mumps_common PROPERTY LINKER_LANGUAGE C)
endif()

set_target_properties(mumps_common PROPERTIES
EXPORT_NAME COMMON
VERSION ${MUMPS_ACTUAL_VERSION}
LIBRARY_OUTPUT_DIRECTORY ${PROJECT_BINARY_DIR}/lib
ARCHIVE_OUTPUT_DIRECTORY ${PROJECT_BINARY_DIR}/lib
)

install(TARGETS mumps_common EXPORT ${PROJECT_NAME}-targets)

# --- MUMPS::MUMPS exported target
# MUMPS::MUMPS is the target most users will link to.
add_library(MUMPS INTERFACE)

function(precision_source a)

set(SRC_Fortran ${a}sol_distrhs.F)

set(SRC_C ${a}mumps_gpu.c)

foreach(i IN ITEMS mumps_comm_buffer.F mumps_ooc_buffer.F mumps_ooc.F mumps_struc_def.F
                   ana_aux.F ana_aux_par.F ana_lr.F fac_asm_master_ELT_m.F fac_asm_master_m.F fac_front_aux.F fac_front_LU_type1.F fac_front_LU_type2.F fac_front_LDLT_type1.F fac_front_LDLT_type2.F fac_front_type2_aux.F fac_lr.F fac_omp_m.F fac_par_m.F lr_core.F mumps_lr_data_m.F omp_tps_m.F static_ptr_m.F
                   lr_type.F mumps_save_restore.F mumps_save_restore_files.F
                   fac_mem_dynamic.F mumps_config_file.F mumps_sol_es.F sol_lr.F
                   )
  list(APPEND SRC_Fortran ${a}${i})
endforeach()

if(MUMPS_ACTUAL_VERSION VERSION_GREATER_EQUAL 5.3)
  foreach(i IN ITEMS fac_sispointers_m.F fac_sol_l0omp_m.F sol_omp_m.F)
    list(APPEND SRC_Fortran ${a}${i})
  endforeach()
endif()
if(MUMPS_ACTUAL_VERSION VERSION_GREATER_EQUAL 5.6)
  list(APPEND SRC_Fortran ${a}mumps_mpi3_mod.F)
endif()

if(MUMPS_ACTUAL_VERSION VERSION_LESS 5.8)
  list(APPEND SRC_Fortran ${a}lr_stats.F ${a}mumps_load.F)
else()
  list(APPEND SRC_Fortran ${a}fac_compact_factors_m.F ${a}mumps_intr_types.F)
endif()

foreach(i IN ITEMS
  ini_driver.F ana_driver.F fac_driver.F
  sol_driver.F
  end_driver.F ana_aux_ELT.F ana_dist_m.F ana_LDLT_preprocess.F
  ana_reordertree.F arrowheads.F bcast_int.F fac_asm_ELT.F
  fac_asm.F fac_b.F fac_distrib_distentry.F fac_distrib_ELT.F fac_lastrtnelind.F
  fac_mem_alloc_cb.F fac_mem_compress_cb.F fac_mem_free_block_cb.F
  fac_mem_stack_aux.F fac_mem_stack.F
  fac_process_band.F fac_process_blfac_slave.F fac_process_blocfacto_LDLT.F fac_process_blocfacto.F
  fac_process_bf.F fac_process_end_facto_slave.F
  fac_process_contrib_type1.F fac_process_contrib_type2.F fac_process_contrib_type3.F
  fac_process_maprow.F fac_process_master2.F fac_process_message.F
  fac_process_root2slave.F fac_process_root2son.F fac_process_rtnelind.F fac_root_parallel.F
  fac_scalings.F fac_determinant.F fac_scalings_simScaleAbs.F fac_scalings_simScale_util.F
  fac_sol_pool.F fac_type3_symmetrize.F ini_defaults.F
  mumps_driver.F mumps_f77.F mumps_iXamax.F
  ana_mtrans.F ooc_panel_piv.F rank_revealing.F
  sol_aux.F sol_bwd_aux.F sol_bwd.F sol_c.F sol_fwd_aux.F sol_fwd.F sol_matvec.F
  sol_root_parallel.F tools.F type3_root.F
)
  list(APPEND SRC_Fortran ${a}${i})
endforeach()

if(MUMPS_ACTUAL_VERSION VERSION_GREATER_EQUAL 5.7)
  list(APPEND SRC_Fortran ${a}sol_distsol.F ${a}fac_diag.F ${a}fac_dist_arrowheads_omp.F)
endif()

set(CINT_SRC mumps_c.c)

add_library(${a}mumps_C OBJECT ${CINT_SRC} ${SRC_C})
target_compile_definitions(${a}mumps_C PRIVATE ${mumps_cdefs})
target_compile_options(${a}mumps_C PRIVATE ${mumps_cflags})

add_library(${a}mumps_Fortran OBJECT ${SRC_Fortran})
target_link_libraries(${a}mumps_Fortran PRIVATE
MPI::MPI_Fortran
$<$<BOOL:${MUMPS_openmp}>:OpenMP::OpenMP_Fortran>
)
target_compile_definitions(${a}mumps_Fortran PRIVATE ${mumps_fdefs})
target_compile_options(${a}mumps_Fortran PRIVATE ${mumps_fflags})

add_library(${a}mumps $<TARGET_OBJECTS:${a}mumps_C> $<TARGET_OBJECTS:${a}mumps_Fortran>)

foreach(t IN ITEMS ${a}mumps ${a}mumps_C ${a}mumps_Fortran)

  target_compile_definitions(${t} PRIVATE
  MUMPS_ARITH=MUMPS_ARITH_${a}
  ${ORDERING_DEFS}
  $<$<AND:$<BOOL:${BLAS_HAVE_${a}GEMMT}>,$<COMPILE_LANGUAGE:Fortran>>:GEMMT_AVAILABLE>
  $<$<AND:$<COMPILE_LANGUAGE:Fortran>,$<NOT:$<BOOL:${MUMPS_scalapack}>>>:NOSCALAPACK>
  )
  target_include_directories(${t} PUBLIC
  "$<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/../include>"
  $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
  )
  target_link_libraries(${t} PUBLIC mumps_common)

endforeach()

target_link_libraries(${a}mumps PRIVATE
MPI::MPI_Fortran
$<$<BOOL:${MUMPS_openmp}>:OpenMP::OpenMP_Fortran>
)
# this is needed for mpiseq, and is best for clarity and consistency


string(TOUPPER ${a} aup)

set_target_properties(${a}mumps PROPERTIES
EXPORT_NAME ${aup}MUMPS
VERSION ${MUMPS_ACTUAL_VERSION}
LIBRARY_OUTPUT_DIRECTORY ${PROJECT_BINARY_DIR}/lib
ARCHIVE_OUTPUT_DIRECTORY ${PROJECT_BINARY_DIR}/lib
)

if(BUILD_SHARED_LIBS AND APPLE AND CMAKE_Fortran_COMPILER_ID STREQUAL "LLVMFlang")
  # flang linker can't handle -dynamiclib flag
  set_property(TARGET ${a}mumps PROPERTY LINKER_LANGUAGE C)
endif()

target_link_libraries(MUMPS INTERFACE ${a}mumps)

install(TARGETS ${a}mumps EXPORT ${PROJECT_NAME}-targets)

install(FILES
${CMAKE_CURRENT_SOURCE_DIR}/../include/${a}mumps_c.h
${CMAKE_CURRENT_SOURCE_DIR}/../include/${a}mumps_struc.h
${CMAKE_CURRENT_SOURCE_DIR}/../include/mumps_int_def.h
TYPE INCLUDE
)

endfunction(precision_source)

if(BUILD_SINGLE)
  precision_source("s")
endif()
if(BUILD_DOUBLE)
  precision_source("d")
endif()
if(BUILD_COMPLEX)
  precision_source("c")
endif()
if(BUILD_COMPLEX16)
  precision_source("z")
endif()


install(FILES
${CMAKE_CURRENT_SOURCE_DIR}/../include/mumps_c_types.h
${CMAKE_CURRENT_SOURCE_DIR}/../include/mumps_compat.h
TYPE INCLUDE
)

install(TARGETS MUMPS EXPORT ${PROJECT_NAME}-targets)

add_library(MUMPS::MUMPS ALIAS MUMPS)
