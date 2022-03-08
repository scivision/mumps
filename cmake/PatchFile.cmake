# use GNU Patch from any platform

find_program(PATCH NAMES patch)

if(WIN32 AND NOT PATCH)
  find_package(Git)
  if(Git_FOUND)
    get_filename_component(GIT_DIR ${GIT_EXECUTABLE} DIRECTORY)
    get_filename_component(GIT_DIR ${GIT_DIR} DIRECTORY)

    find_program(PATCH
    NAMES patch
    HINTS ${GIT_DIR}
    PATH_SUFFIXES usr/bin
    )
  endif()
endif()

if(NOT PATCH)
  message(FATAL_ERROR "Did not find GNU PATCH")
endif()

execute_process(COMMAND ${PATCH} ${in_file} --input=${patch_file} --output=${out_file} --ignore-whitespace
TIMEOUT 15
COMMAND_ECHO STDOUT
RESULT_VARIABLE ret
)

if(NOT ret EQUAL 0)
  message(FATAL_ERROR "Failed to apply patch ${patch_file} to ${in_file} with ${PATCH}")
endif()
