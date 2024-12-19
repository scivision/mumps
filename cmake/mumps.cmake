set(_mi ${mumps_SOURCE_DIR}/include/)
set(_s ${mumps_SOURCE_DIR}/src/)

# -- generated MUMPS_INTSIZE header
if(MUMPS_UPSTREAM_VERSION VERSION_GREATER_EQUAL 5.5.0)
  if(intsize64)
    set(intsrc ${mumps_SOURCE_DIR}/src/mumps_int_def64_h.in)
  else()
    set(intsrc ${mumps_SOURCE_DIR}/src/mumps_int_def32_h.in)
  endif()
  configure_file(${intsrc} ${_mi}mumps_int_def.h COPYONLY)
else()
  if(intsize64)
    set(MUMPS_INTSIZE MUMPS_INTSIZE64)
  else()
    set(MUMPS_INTSIZE MUMPS_INTSIZE32)
  endif()
  file(WRITE ${_mi}mumps_int_def.h
"
#ifndef MUMPS_INT_H
#define MUMPS_INT_H
#define ${MUMPS_INTSIZE}
#endif
"
  )
endif()

# -- Mumps COMMON
set(COMM_SRC_Fortran ${_s}mumps_ooc_common.F ${_s}mumps_static_mapping.F)

if(MUMPS_UPSTREAM_VERSION VERSION_LESS 5.0)
  list(APPEND COMM_SRC_Fortran ${_s}mumps_part9.F)
endif()
if(MUMPS_UPSTREAM_VERSION VERSION_GREATER_EQUAL 5.0)
  foreach(i IN ITEMS ana_omp_m.F double_linked_list.F fac_asm_build_sort_index_ELT_m.F fac_asm_build_sort_index_m.F fac_descband_data_m.F fac_future_niv2_mod.F fac_ibct_data_m.F fac_maprow_data_m.F front_data_mgt_m.F mumps_comm_ibcast.F mumps_l0_omp_m.F omp_tps_common_m.F)
    list(APPEND COMM_SRC_Fortran ${_s}${i})
  endforeach()
endif()
if(MUMPS_UPSTREAM_VERSION VERSION_GREATER_EQUAL 5.1)
  foreach(i IN ITEMS ana_orderings_wrappers_m.F lr_common.F mumps_memory_mod.F)
    list(APPEND COMM_SRC_Fortran ${_s}${i})
  endforeach()
endif()
if(MUMPS_UPSTREAM_VERSION VERSION_GREATER_EQUAL 5.2)
  list(APPEND COMM_SRC_Fortran  ${_s}mumps_mpitoomp_m.F)
endif()
if(MUMPS_UPSTREAM_VERSION VERSION_GREATER_EQUAL 5.3)
  list(APPEND COMM_SRC_Fortran ${_s}ana_blk_m.F)
endif()
if(MUMPS_UPSTREAM_VERSION VERSION_GREATER_EQUAL 5.6)
  list(APPEND COMM_SRC_Fortran ${_s}mumps_pivnul_mod.F)
endif()
if(MUMPS_UPSTREAM_VERSION VERSION_GREATER_EQUAL 5.7)
  list(APPEND COMM_SRC_Fortran ${_s}sol_ds_common_m.F)
endif()

set(COMM_OTHER_C)
set(COMM_OTHER_Fortran)
foreach(i IN ITEMS mumps_common.c mumps_io_basic.c mumps_io_thread.c mumps_io_err.c mumps_io.c)
  list(APPEND COMM_OTHER_C ${_s}${i})
endforeach()
if(MUMPS_UPSTREAM_VERSION VERSION_GREATER_EQUAL 4.9 AND MUMPS_UPSTREAM_VERSION VERSION_LESS 5.6)
  list(APPEND COMM_OTHER_C ${_s}mumps_size.c)
endif()
if(MUMPS_UPSTREAM_VERSION VERSION_GREATER_EQUAL 4.9 AND MUMPS_UPSTREAM_VERSION VERSION_LESS 5.1)
  list(APPEND COMM_OTHER_Fortran ${_s}tools_common_mod.F)
endif()
if(MUMPS_UPSTREAM_VERSION VERSION_GREATER_EQUAL 4.10 AND MUMPS_UPSTREAM_VERSION VERSION_LESS 5.2)
  list(APPEND COMM_OTHER_Fortran ${_s}mumps_sol_es.F)
endif()
if(MUMPS_UPSTREAM_VERSION VERSION_GREATER_EQUAL 5.6)
  list(APPEND COMM_OTHER_C ${_s}mumps_addr.c)
endif()

if(MUMPS_UPSTREAM_VERSION VERSION_GREATER_EQUAL 5.0)
  foreach(i IN ITEMS ana_orderings.F ana_set_ordering.F ana_AMDMF.F bcast_errors.F estim_flops.F mumps_type2_blocking.F mumps_version.F mumps_print_defined.F tools_common.F)
    list(APPEND COMM_OTHER_Fortran ${_s}${i})
  endforeach()
  list(APPEND COMM_OTHER_C ${_s}mumps_numa.c)
endif()
if(MUMPS_UPSTREAM_VERSION VERSION_LESS 5.1)
  list(APPEND COMM_OTHER_C ${_s}mumps_orderings.c)
endif()
if(MUMPS_UPSTREAM_VERSION VERSION_GREATER_EQUAL 5.1)
  foreach(i IN ITEMS mumps_pord.c mumps_thread.c mumps_save_restore_C.c)
    list(APPEND COMM_OTHER_C ${_s}${i})
  endforeach()
endif()
if(MUMPS_UPSTREAM_VERSION VERSION_GREATER_EQUAL 5.2)
  foreach(i IN ITEMS mumps_config_file_C.c mumps_thread_affinity.c)
    list(APPEND COMM_OTHER_C ${_s}${i})
  endforeach()
  list(APPEND COMM_OTHER_Fortran ${_s}sol_common.F)
endif()
if(MUMPS_UPSTREAM_VERSION VERSION_GREATER_EQUAL 5.3)
  list(APPEND COMM_OTHER_Fortran ${_s}ana_blk.F)
endif()
if(MUMPS_UPSTREAM_VERSION VERSION_GREATER_EQUAL 5.3)
  list(APPEND COMM_OTHER_C ${_s}mumps_register_thread.c)
endif()
if(MUMPS_UPSTREAM_VERSION VERSION_GREATER_EQUAL 5.0 AND MUMPS_UPSTREAM_VERSION VERSION_LESS 5.7)
  list(APPEND COMM_OTHER_Fortran ${_s}mumps_type_size.F)
endif()

if(MUMPS_UPSTREAM_VERSION VERSION_GREATER_EQUAL 5.1)
  if(scotch)
    foreach(i IN ITEMS mumps_scotch.c mumps_scotch64.c mumps_scotch_int.c)
      list(APPEND COMM_OTHER_C ${_s}${i})
    endforeach()
  endif()
  if(metis OR parmetis)
    foreach(i IN ITEMS mumps_metis.c mumps_metis64.c mumps_metis_int.c)
      list(APPEND COMM_OTHER_C ${_s}${i})
    endforeach()
  endif()
endif()

add_library(mumps_common_C OBJECT ${COMM_OTHER_C})
add_library(mumps_common_Fortran OBJECT ${COMM_SRC_Fortran} ${COMM_OTHER_Fortran})

add_library(mumps_common $<TARGET_OBJECTS:mumps_common_Fortran> $<TARGET_OBJECTS:mumps_common_C>)

set(BLAS_HAVE_GEMMT FALSE)
if(BLAS_HAVE_sGEMMT OR BLAS_HAVE_dGEMMT OR BLAS_HAVE_cGEMMT OR BLAS_HAVE_zGEMMT)
  set(BLAS_HAVE_GEMMT TRUE)
endif()

foreach(t IN ITEMS mumps_common mumps_common_C mumps_common_Fortran)
  target_include_directories(${t} PUBLIC
  "$<BUILD_INTERFACE:${mumps_SOURCE_DIR}/src;${mumps_SOURCE_DIR}/include;${NUMERIC_INC}>"
  $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
  )

  target_link_libraries(${t} PUBLIC ${ORDERING_LIBS} ${NUMERIC_LIBS})

  target_compile_definitions(${t} PRIVATE
  ${ORDERING_DEFS}
  $<$<AND:$<COMPILE_LANGUAGE:Fortran>,$<NOT:$<BOOL:${MUMPS_scalapack}>>>:NOSCALAPACK>
  )

  if(BLAS_HAVE_GEMMT)
    target_compile_definitions(${t} PRIVATE $<$<COMPILE_LANGUAGE:Fortran>:GEMMT_AVAILABLE>)
  endif()
endforeach()

set_property(TARGET mumps_common PROPERTY EXPORT_NAME COMMON)
set_property(TARGET mumps_common PROPERTY VERSION ${MUMPS_VERSION})

install(TARGETS mumps_common EXPORT ${PROJECT_NAME}-targets)

# --- MUMPS::MUMPS exported target
# MUMPS::MUMPS is the target most users will link to.
add_library(MUMPS INTERFACE)

function(precision_source a)

set(SRC_Fortran)
set(SRC_C)
foreach(i IN ITEMS mumps_comm_buffer.F mumps_load.F mumps_ooc_buffer.F mumps_ooc.F mumps_struc_def.F)
  list(APPEND SRC_Fortran ${_s}${a}${i})
endforeach()
if(MUMPS_UPSTREAM_VERSION VERSION_GREATER_EQUAL 5.0)
  foreach(i IN ITEMS ana_aux.F ana_aux_par.F ana_lr.F fac_asm_master_ELT_m.F fac_asm_master_m.F fac_front_aux.F fac_front_LU_type1.F fac_front_LU_type2.F fac_front_LDLT_type1.F fac_front_LDLT_type2.F fac_front_type2_aux.F fac_lr.F fac_omp_m.F fac_par_m.F lr_core.F mumps_lr_data_m.F omp_tps_m.F static_ptr_m.F)
    list(APPEND SRC_Fortran ${_s}${a}${i})
  endforeach()
endif()
if(MUMPS_UPSTREAM_VERSION VERSION_GREATER_EQUAL 5.1)
  foreach(i IN ITEMS lr_stats.F lr_type.F mumps_save_restore.F mumps_save_restore_files.F)
    list(APPEND SRC_Fortran ${_s}${a}${i})
  endforeach()
endif()
if(MUMPS_UPSTREAM_VERSION VERSION_GREATER_EQUAL 5.2)
  foreach(i IN ITEMS fac_mem_dynamic.F mumps_config_file.F mumps_sol_es.F sol_lr.F)
    list(APPEND SRC_Fortran ${_s}${a}${i})
  endforeach()
endif()
if(MUMPS_UPSTREAM_VERSION VERSION_GREATER_EQUAL 5.3)
  foreach(i IN ITEMS fac_sispointers_m.F fac_sol_l0omp_m.F sol_omp_m.F)
    list(APPEND SRC_Fortran ${_s}${a}${i})
  endforeach()
endif()
if(MUMPS_UPSTREAM_VERSION VERSION_GREATER_EQUAL 5.6)
  list(APPEND SRC_Fortran ${_s}${a}mumps_mpi3_mod.F)
endif()

if(MUMPS_UPSTREAM_VERSION VERSION_GREATER_EQUAL 5.0)
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
    list(APPEND SRC_Fortran ${_s}${a}${i})
  endforeach()
endif()
if(MUMPS_UPSTREAM_VERSION VERSION_GREATER_EQUAL 5.2)
  list(APPEND SRC_Fortran ${_s}${a}sol_distrhs.F)
  list(APPEND SRC_C ${_s}${a}mumps_gpu.c)
endif()
if(MUMPS_UPSTREAM_VERSION VERSION_GREATER_EQUAL 5.7)
  list(APPEND SRC_Fortran ${_s}${a}sol_distsol.F ${_s}${a}fac_diag.F ${_s}${a}fac_dist_arrowheads_omp.F)
endif()
if(MUMPS_UPSTREAM_VERSION VERSION_LESS 5.0)
  foreach(i IN ITEMS mumps_part1.F mumps_part2.F mumps_part3.F mumps_part4.F mumps_part5.F mumps_part6.F mumps_part7.F mumps_part8.F)
    list(APPEND SRC_Fortran ${_s}${a}${i})
  endforeach()
endif()

set(CINT_SRC ${_s}mumps_c.c)

add_library(${a}mumps_C OBJECT ${CINT_SRC} ${SRC_C})
add_library(${a}mumps_Fortran OBJECT ${SRC_Fortran})

add_library(${a}mumps $<TARGET_OBJECTS:${a}mumps_C> $<TARGET_OBJECTS:${a}mumps_Fortran>)

foreach(t IN ITEMS ${a}mumps ${a}mumps_C ${a}mumps_Fortran)

  target_compile_definitions(${t} PRIVATE
  MUMPS_ARITH=MUMPS_ARITH_${a}
  ${ORDERING_DEFS}
  $<$<AND:$<BOOL:${BLAS_HAVE_${a}GEMMT}>,$<COMPILE_LANGUAGE:Fortran>>:GEMMT_AVAILABLE>
  $<$<AND:$<COMPILE_LANGUAGE:Fortran>,$<NOT:$<BOOL:${MUMPS_scalapack}>>>:NOSCALAPACK>
  )
  target_include_directories(${t} PUBLIC
  "$<BUILD_INTERFACE:${mumps_SOURCE_DIR}/include;${NUMERIC_INC}>"
  $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
  )
  target_link_libraries(${t} PUBLIC mumps_common)

endforeach()


string(TOUPPER ${a} aup)

set_property(TARGET ${a}mumps PROPERTY EXPORT_NAME ${aup}MUMPS)
set_property(TARGET ${a}mumps PROPERTY VERSION ${MUMPS_VERSION})

target_link_libraries(MUMPS INTERFACE ${a}mumps)

install(TARGETS ${a}mumps EXPORT ${PROJECT_NAME}-targets)

install(FILES ${_mi}${a}mumps_c.h ${_mi}${a}mumps_root.h ${_mi}${a}mumps_struc.h ${_mi}mumps_int_def.h TYPE INCLUDE)

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


install(FILES ${_mi}mumps_c_types.h ${_mi}mumps_compat.h TYPE INCLUDE)

install(TARGETS MUMPS EXPORT ${PROJECT_NAME}-targets)

# this must NOT be an ALIAS or linking in other packages breaks.
add_library(MUMPS::MUMPS INTERFACE IMPORTED GLOBAL)
target_link_libraries(MUMPS::MUMPS INTERFACE MUMPS)
