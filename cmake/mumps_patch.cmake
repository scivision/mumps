# patching MUMPS 5.4.0, 5.4.1 mumps_io.h

if(mumps_patched)
  return()
endif()

set(mumps_orig ${mumps_SOURCE_DIR}/src/mumps_io.h)
set(mumps_patch ${CMAKE_CURRENT_LIST_DIR}/mumps_io.540.patch)
# API patch
if(WIN32)
  find_program(WSL NAMES wsl REQUIRED)

  execute_process(COMMAND ${WSL} wslpath ${mumps_orig}
    TIMEOUT 15
    OUTPUT_VARIABLE mumps_orig_path
    COMMAND_ERROR_IS_FATAL ANY
    OUTPUT_STRIP_TRAILING_WHITESPACE
  )

  execute_process(COMMAND ${WSL} wslpath ${mumps_patch}
    TIMEOUT 15
    OUTPUT_VARIABLE mumps_patch_path
    COMMAND_ERROR_IS_FATAL ANY
    OUTPUT_STRIP_TRAILING_WHITESPACE
  )

  execute_process(COMMAND ${WSL} patch ${mumps_orig_path} ${mumps_patch_path}
    TIMEOUT 15
    COMMAND_ERROR_IS_FATAL ANY
  )
else()
  find_program(PATCH NAMES patch REQUIRED)
  execute_process(COMMAND ${PATCH} ${mumps_orig} ${mumps_patch}
    TIMEOUT 15
    COMMAND_ERROR_IS_FATAL ANY
  )
endif()

set(mumps_patched true CACHE BOOL "MUMPS mumps_io.h is patched")
