set_property(GLOBAL PROPERTY JOB_POOLS Njobs=3)
cmake_host_system_information(RESULT _memfree QUERY AVAILABLE_PHYSICAL_MEMORY)
# for low memory systems

# -- generated MUMPS_INTSIZE64 header
if(intsize64)
  set(MUMPS_INTSIZE MUMPS_INTSIZE64)
else()
  set(MUMPS_INTSIZE MUMPS_INTSIZE32)
endif()
configure_file(
${PROJECT_SOURCE_DIR}/include/mumps_int_def.h.in
${mumps_SOURCE_DIR}/include/mumps_int_def.h @ONLY)

# -- Mumps COMMON
set(COMM_SRC
"$<$<VERSION_LESS:${MUMPS_UPSTREAM_VERSION},5.0>:mumps_part9.F>"
"$<$<VERSION_GREATER_EQUAL:${MUMPS_UPSTREAM_VERSION},5.0>:ana_omp_m.F;double_linked_list.F;fac_asm_build_sort_index_ELT_m.F;fac_asm_build_sort_index_m.F;fac_descband_data_m.F;fac_future_niv2_mod.F;fac_ibct_data_m.F;fac_maprow_data_m.F;front_data_mgt_m.F;mumps_comm_ibcast.F;mumps_l0_omp_m.F;omp_tps_common_m.F>"
"$<$<VERSION_GREATER_EQUAL:${MUMPS_UPSTREAM_VERSION},5.1>:ana_orderings_wrappers_m.F;lr_common.F;mumps_memory_mod.F>"
$<$<VERSION_GREATER_EQUAL:${MUMPS_UPSTREAM_VERSION},5.2>:mumps_mpitoomp_m.F>
$<$<VERSION_GREATER_EQUAL:${MUMPS_UPSTREAM_VERSION},5.3>:ana_blk_m.F>
mumps_ooc_common.F mumps_static_mapping.F
)

set(COMM_OTHER_SRC
$<$<VERSION_GREATER_EQUAL:${MUMPS_UPSTREAM_VERSION},4.9>:mumps_size.c>
"$<$<AND:$<VERSION_GREATER_EQUAL:${MUMPS_UPSTREAM_VERSION},4.9>,$<VERSION_LESS:${MUMPS_UPSTREAM_VERSION},5.1>>:tools_common_mod.F>"
"$<$<AND:$<VERSION_GREATER_EQUAL:${MUMPS_UPSTREAM_VERSION},4.10>,$<VERSION_LESS:${MUMPS_UPSTREAM_VERSION},5.2>>:mumps_sol_es.F>"
"$<$<VERSION_GREATER_EQUAL:${MUMPS_UPSTREAM_VERSION},5.0>:ana_orderings.F;ana_set_ordering.F;ana_AMDMF.F;bcast_errors.F;estim_flops.F;mumps_type_size.F;mumps_type2_blocking.F;mumps_version.F;mumps_print_defined.F;mumps_numa.c;tools_common.F>"
"$<$<VERSION_LESS:${MUMPS_UPSTREAM_VERSION},5.1>:mumps_orderings.c>"
"$<$<VERSION_GREATER_EQUAL:${MUMPS_UPSTREAM_VERSION},5.1>:mumps_pord.c;mumps_thread.c;mumps_save_restore_C.c>"
"$<$<VERSION_GREATER_EQUAL:${MUMPS_UPSTREAM_VERSION},5.2>:mumps_config_file_C.c;mumps_thread_affinity.c;sol_common.F>"
$<$<VERSION_GREATER_EQUAL:${MUMPS_UPSTREAM_VERSION},5.3>:ana_blk.F>
$<$<VERSION_GREATER_EQUAL:${MUMPS_UPSTREAM_VERSION},5.4>:mumps_register_thread.c>
mumps_common.c mumps_io_basic.c mumps_io_thread.c mumps_io_err.c # mumps_io.c
"$<$<AND:$<BOOL:${scotch}>,$<VERSION_GREATER_EQUAL:${MUMPS_UPSTREAM_VERSION},5.1>>:mumps_scotch.c;mumps_scotch64.c;mumps_scotch_int.c;mumps_metis.c;mumps_metis64.c;mumps_metis_int.c>"
)

# manually create directory to avoid race condition for FetchContent
# else can get INTERFACE_INCLUDE_DIRECTORIES not found error
file(MAKE_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/include)

add_library(mumps_common ${COMM_SRC} ${COMM_OTHER_SRC})
target_link_libraries(mumps_common PRIVATE ${ORDERING_LIBS} ${NUMERIC_LIBS})
target_include_directories(mumps_common PUBLIC
"$<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR};${mumps_SOURCE_DIR}/include>"
$<INSTALL_INTERFACE:include>
)

target_compile_definitions(mumps_common PRIVATE ${ORDERING_FLAGS})
# if(WIN32)
#   target_compile_definitions(mumps_common PRIVATE MUMPS_WIN32)
# endif()
set_target_properties(mumps_common PROPERTIES
Fortran_MODULE_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/include
LIBRARY_OUTPUT_DIRECTORY ${PROJECT_BINARY_DIR}
ARCHIVE_OUTPUT_DIRECTORY ${PROJECT_BINARY_DIR}
EXPORT_NAME COMMON
VERSION ${MUMPS_VERSION}
)

install(TARGETS mumps_common EXPORT ${PROJECT_NAME}-targets)

# -- Mumps
set(_ifc_libs)

foreach(a ${arith})

list(APPEND _ifc_libs ${a}mumps)

set(SRC
"$<$<VERSION_GREATER_EQUAL:${MUMPS_UPSTREAM_VERSION},5.0>:${a}ana_aux.F;${a}ana_aux_par.F;${a}ana_lr.F;${a}fac_asm_master_ELT_m.F;${a}fac_asm_master_m.F;${a}fac_front_aux.F;${a}fac_front_LU_type1.F;${a}fac_front_LU_type2.F;${a}fac_front_LDLT_type1.F;${a}fac_front_LDLT_type2.F;${a}fac_front_type2_aux.F;${a}fac_lr.F;${a}fac_omp_m.F;${a}fac_par_m.F;${a}lr_core.F;${a}mumps_lr_data_m.F;${a}omp_tps_m.F;${a}static_ptr_m.F>"
"$<$<VERSION_GREATER_EQUAL:${MUMPS_UPSTREAM_VERSION},5.1>:${a}lr_stats.F;${a}lr_type.F;${a}mumps_save_restore.F;${a}mumps_save_restore_files.F>"
"$<$<VERSION_GREATER_EQUAL:${MUMPS_UPSTREAM_VERSION},5.2>:${a}fac_mem_dynamic.F;${a}mumps_config_file.F;${a}mumps_sol_es.F;${a}sol_lr.F>"
"$<$<VERSION_GREATER_EQUAL:${MUMPS_UPSTREAM_VERSION},5.3>:${a}fac_sispointers_m.F;${a}fac_sol_l0omp_m.F;${a}sol_omp_m.F>"
${a}mumps_comm_buffer.F  ${a}mumps_load.F
${a}mumps_ooc_buffer.F ${a}mumps_ooc.F
${a}mumps_struc_def.F
)

if(MUMPS_UPSTREAM_VERSION VERSION_GREATER_EQUAL 5.0)
set(SRC_OTHER
${a}ini_driver.F ${a}ana_driver.F ${a}fac_driver.F
"$<$<VERSION_GREATER_EQUAL:${MUMPS_UPSTREAM_VERSION},5.2>:${a}sol_distrhs.F;${a}mumps_gpu.c>"
${a}sol_driver.F
${a}end_driver.F ${a}ana_aux_ELT.F ${a}ana_dist_m.F ${a}ana_LDLT_preprocess.F
${a}ana_reordertree.F ${a}arrowheads.F ${a}bcast_int.F ${a}fac_asm_ELT.F
${a}fac_asm.F ${a}fac_b.F ${a}fac_distrib_distentry.F ${a}fac_distrib_ELT.F ${a}fac_lastrtnelind.F
${a}fac_mem_alloc_cb.F ${a}fac_mem_compress_cb.F ${a}fac_mem_free_block_cb.F
${a}fac_mem_stack_aux.F ${a}fac_mem_stack.F
${a}fac_process_band.F ${a}fac_process_blfac_slave.F ${a}fac_process_blocfacto_LDLT.F ${a}fac_process_blocfacto.F
${a}fac_process_bf.F ${a}fac_process_end_facto_slave.F
${a}fac_process_contrib_type1.F ${a}fac_process_contrib_type2.F ${a}fac_process_contrib_type3.F
${a}fac_process_maprow.F ${a}fac_process_master2.F ${a}fac_process_message.F
${a}fac_process_root2slave.F ${a}fac_process_root2son.F ${a}fac_process_rtnelind.F ${a}fac_root_parallel.F
${a}fac_scalings.F ${a}fac_determinant.F ${a}fac_scalings_simScaleAbs.F ${a}fac_scalings_simScale_util.F
${a}fac_sol_pool.F ${a}fac_type3_symmetrize.F ${a}ini_defaults.F
${a}mumps_driver.F ${a}mumps_f77.F ${a}mumps_iXamax.F
${a}ana_mtrans.F ${a}ooc_panel_piv.F ${a}rank_revealing.F
${a}sol_aux.F ${a}sol_bwd_aux.F ${a}sol_bwd.F ${a}sol_c.F ${a}sol_fwd_aux.F ${a}sol_fwd.F ${a}sol_matvec.F
${a}sol_root_parallel.F ${a}tools.F ${a}type3_root.F
)
else()
set(SRC_OTHER
${a}mumps_part1.F ${a}mumps_part2.F ${a}mumps_part3.F ${a}mumps_part4.F ${a}mumps_part5.F ${a}mumps_part6.F ${a}mumps_part7.F ${a}mumps_part8.F
)
endif()

set(CINT_SRC mumps_c.c)

add_library(${a}mumps ${CINT_SRC} ${SRC} ${SRC_OTHER})
if(_memfree LESS 1000)  # < 1GB RAM free
  set_target_properties(${a}mumps PROPERTIES JOB_POOL_COMPILE Njobs)
endif()
target_compile_definitions(${a}mumps PRIVATE MUMPS_ARITH=MUMPS_ARITH_${a} ${ORDERING_FLAGS})
# if(WIN32)
#   target_compile_definitions(${a}mumps PRIVATE MUMPS_WIN32)
# endif()
target_include_directories(${a}mumps PUBLIC
$<BUILD_INTERFACE:${mumps_SOURCE_DIR}/include>
$<INSTALL_INTERFACE:include>
)
target_link_libraries(${a}mumps PRIVATE mumps_common ${ORDERING_LIBS} ${NUMERIC_LIBS})

string(TOUPPER ${a} aup)

set_target_properties(${a}mumps PROPERTIES
Fortran_MODULE_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/include
LIBRARY_OUTPUT_DIRECTORY ${PROJECT_BINARY_DIR}
ARCHIVE_OUTPUT_DIRECTORY ${PROJECT_BINARY_DIR}
EXPORT_NAME ${aup}MUMPS
VERSION ${MUMPS_VERSION}
)

install(TARGETS ${a}mumps EXPORT ${PROJECT_NAME}-targets)

install(FILES
${mumps_SOURCE_DIR}/include/${a}mumps_c.h
${mumps_SOURCE_DIR}/include/${a}mumps_root.h
${mumps_SOURCE_DIR}/include/${a}mumps_struc.h
${mumps_SOURCE_DIR}/include/mumps_int_def.h
TYPE INCLUDE
)

endforeach()

install(FILES
${mumps_SOURCE_DIR}/include/mumps_c_types.h
${mumps_SOURCE_DIR}/include/mumps_compat.h
TYPE INCLUDE
)

# We do not need the .mod files due to the way MUMPS is interfaced
# install(DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/include/ TYPE INCLUDE)

# --- MUMPS::MUMPS exported target
# MUMPS::MUMPS is the target most users will link to.
# It knows all the include directories.

add_library(MUMPS INTERFACE)
target_link_libraries(MUMPS INTERFACE ${_ifc_libs} mumps_common pord
$<$<NOT:$<BOOL:${parallel}>>:mpiseq>
)

install(TARGETS MUMPS EXPORT ${PROJECT_NAME}-targets)

# target for FetchContent
# this must NOT be an ALIAS or linking in other packages breaks.
add_library(MUMPS::MUMPS INTERFACE IMPORTED GLOBAL)
target_link_libraries(MUMPS::MUMPS INTERFACE MUMPS)


# --- PATCH 5.4.1
if(MUMPS_UPSTREAM_VERSION VERSION_EQUAL 5.4.0 OR MUMPS_UPSTREAM_VERSION VERSION_EQUAL 5.4.1)
  file(MAKE_DIRECTORY ${mumps_BINARY_DIR}/include)

  add_custom_command(
  OUTPUT ${mumps_BINARY_DIR}/include/mumps_io_patched.h
  COMMAND ${CMAKE_COMMAND}
    -Din_file:FILEPATH=${mumps_SOURCE_DIR}/src/mumps_io.h
    -Dpatch_file:FILEPATH=${PROJECT_SOURCE_DIR}/cmake/mumps_io.h.patch
    -Dout_file:FILEPATH=${mumps_BINARY_DIR}/include/mumps_io_patched.h
    -P ${PROJECT_SOURCE_DIR}/cmake/PatchFile.cmake
  DEPENDS ${mumps_SOURCE_DIR}/src/mumps_io.h
  )
  add_custom_command(
    OUTPUT ${mumps_BINARY_DIR}/mumps_io.c
    COMMAND ${CMAKE_COMMAND}
      -Din_file:FILEPATH=${mumps_SOURCE_DIR}/src/mumps_io.c
      -Dpatch_file:FILEPATH=${PROJECT_SOURCE_DIR}/cmake/mumps_io.c.patch
      -Dout_file:FILEPATH=${mumps_BINARY_DIR}/mumps_io.c
      -P ${PROJECT_SOURCE_DIR}/cmake/PatchFile.cmake
    DEPENDS ${mumps_SOURCE_DIR}/src/mumps_io.c
    )
else()
  configure_file(${mumps_SOURCE_DIR}/src/mumps_io.h ${mumps_BINARY_DIR}/include/mumps_io_patched.h COPYONLY)
  configure_file(${mumps_SOURCE_DIR}/src/mumps_io.c ${mumps_BINARY_DIR}/mumps_io.c COPYONLY)
endif()
target_sources(mumps_common PRIVATE ${mumps_BINARY_DIR}/mumps_io.c ${mumps_BINARY_DIR}/include/mumps_io_patched.h)
target_include_directories(mumps_common BEFORE PUBLIC
$<BUILD_INTERFACE:${mumps_BINARY_DIR}/include>
$<INSTALL_INTERFACE:include>
)
# --- END PATCH 5.4.1
