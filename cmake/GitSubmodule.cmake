function(git_submodule submod_dir)
# get/update Git submodule directory to CMake, assuming the
# Git submodule directory is a CMake project.
# If the submodule directory is not in the same directory, descend level by level with multiple
# git_submodule() calls.
#
# For example, in the MUMPS project, we have submodule directories
# mumps-superbuild/parmetis/METIS/GKlib
#
# from the mumps-superbuild/ directory to enable METIS but not ParMETIS if the user desires, we do
# git_submodule(${PROJECT_SOURCE_DIR}/parmetis)
# if(MUMPS_parmetis)
#   add_subdirectory(${PROJECT_SOURCE_DIR}/parmetis)
#   # ParMETIS project itself handles METIS submodule, then METIS handles GKlib submodule
# else()
#   git_submodule(${PROJECT_SOURCE_DIR}/parmetis/METIS)
#   add_subdirectory(${PROJECT_SOURCE_DIR}/parmetis/METIS)
#   METIS project itself handles GKlib submodule
# endif()

if(${PROJECT_NAME}_UPDATE_DISCONNECTED AND EXISTS ${submod_dir}/CMakeLists.txt)
  message(DEBUG "Not updating submodule ${submod_dir} because ${PROJECT_NAME}_UPDATE_DISCONNECTED is ON")
  return()
endif()

find_package(Git REQUIRED)

cmake_path(GET submod_dir PARENT_PATH mod_dir)
# we need to descend level by level

if(IS_DIRECTORY ${mod_dir}/.git)

message(STATUS "${mod_dir} is a Git repository, updating submodule ${submod_dir}")

execute_process(COMMAND ${GIT_EXECUTABLE} -C ${mod_dir} submodule
    update --init --recursive -- ${submod_dir}
  COMMAND_ERROR_IS_FATAL ANY
)

else()

cmake_path(GET submod_dir STEM submod_name)
message(STATUS "${PROJECT_SOURCE_DIR} is not a Git repository.")
message(STATUS "Getting ${mod_dir}/.gitmodules info to Git clone ${submod_name} into ${submod_dir}")

execute_process(
  COMMAND ${GIT_EXECUTABLE} -C ${mod_dir} config
    --file ${mod_dir}/.gitmodules
    --get submodule.${submod_name}.url
  OUTPUT_VARIABLE submod_url
  OUTPUT_STRIP_TRAILING_WHITESPACE
  COMMAND_ERROR_IS_FATAL ANY
)
# Some platforms like Windows, Git might refuse to clone into a totally empty existing directory
# this is a known technique, to "git clone" from that empty submod_dir directory to make it work.
execute_process(
  COMMAND ${GIT_EXECUTABLE} -C ${submod_dir} clone ${submod_url} ${submod_dir}
  COMMAND_ERROR_IS_FATAL ANY
)

endif()

endfunction()
