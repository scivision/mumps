option(autobuild "auto-build Lapack and/or Scalapack if missing or broken" true)
option(lapack_external "build Lapack instead of finding")
option(scalapack_external "build ScaLapack instead of finding")
option(mumps_external "build MUMPS instead of finding")

option(dev "developer mode")
option(parallel "parallel or sequential (non-MPI, non-Scalapack)" ON)
option(intsize64 "use 64-bit integers in C and Fortran" OFF)
option(metis "use METIS" OFF)
option(scotch "use Scotch" OFF)
option(openmp "use OpenMP" OFF)
option(mumps_matlab "build optional Matlab interface" OFF)
option(use_default_install_prefix "don't override install path" OFF)

set(CMAKE_EXPORT_COMPILE_COMMANDS true)

set(CMAKE_TLS_VERIFY true)

if(CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT AND (NOT
                                                    use_default_install_prefix))
  set(CMAKE_INSTALL_PREFIX ${PROJECT_BINARY_DIR} CACHE PATH
      "top-level install path" FORCE)
endif()

# --- other options

# default build all
if(NOT DEFINED arith)
  set(arith "s;d;c;z")
endif()

if(intsize64)
  add_compile_definitions(INTSIZE64)
endif()

set(FETCHCONTENT_UPDATES_DISCONNECTED_MUMPS true)

if(dev)

else()
  set_directory_properties(PROPERTIES EP_UPDATE_DISCONNECTED true)
endif()

# --- auto-ignore build directory
if(NOT EXISTS ${PROJECT_BINARY_DIR}/.gitignore)
  file(WRITE ${PROJECT_BINARY_DIR}/.gitignore "*")
endif()
