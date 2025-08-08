function(git_submodule submod_dir)
# get/update Git submodule directory to CMake, assuming the
# Git submodule directory is a CMake project.

if(EXISTS ${submod_dir}/CMakeLists.txt)
  return()
endif()

set(CMAKE_EXECUTE_PROCESS_COMMAND_ECHO STDOUT)

find_package(Git REQUIRED)

# EXISTS, do not use IS_DIRECTORY as in submodule .git is a file not a directory
if(EXISTS ${PROJECT_SOURCE_DIR}/.git)
  message(DEBUG "${PROJECT_SOURCE_DIR} is a Git repository, updating submodule ${submod_dir}")
  execute_process(COMMAND ${GIT_EXECUTABLE} submodule update --init --recursive -- ${submod_dir}
    WORKING_DIRECTORY ${PROJECT_SOURCE_DIR}
    COMMAND_ERROR_IS_FATAL ANY
    )
else()
  message(DEBUG "${PROJECT_SOURCE_DIR} is from an archive or otherwise not a Git repository. Getting .gitmodules info to clone")
  execute_process(COMMAND ${GIT_EXECUTABLE} config --file ${PROJECT_SOURCE_DIR}/.gitmodules --get submodule.scalapack.url
                  WORKING_DIRECTORY ${PROJECT_SOURCE_DIR}
                  OUTPUT_VARIABLE submod_url
                  OUTPUT_STRIP_TRAILING_WHITESPACE
                  COMMAND_ERROR_IS_FATAL ANY
                  )
  # Some platforms like Windows, Git might refuse to clone into a totally empty existing directory
  # this is a known technique, to "git clone" from that empty directory to make it work.
  execute_process(COMMAND ${GIT_EXECUTABLE} clone ${submod_url} ${submod_dir}
                  WORKING_DIRECTORY ${submod_dir}
                  COMMAND_ERROR_IS_FATAL ANY
                  )
endif()

endfunction()
