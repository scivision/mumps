# --- BOILERPLATE: install / packaging

include(CMakePackageConfigHelpers)

configure_package_config_file(${CMAKE_CURRENT_LIST_DIR}/config.cmake.in
${CMAKE_CURRENT_BINARY_DIR}/CMakeFiles/${PROJECT_NAME}-config.cmake
INSTALL_DESTINATION cmake
)

write_basic_package_version_file(
${CMAKE_CURRENT_BINARY_DIR}/CMakeFiles/${PROJECT_NAME}-config-version.cmake
COMPATIBILITY SameMinorVersion
)

install(EXPORT ${PROJECT_NAME}-targets
NAMESPACE ${PROJECT_NAME}::
DESTINATION cmake
)

install(FILES
${CMAKE_CURRENT_BINARY_DIR}/CMakeFiles/${PROJECT_NAME}-config.cmake
${CMAKE_CURRENT_BINARY_DIR}/CMakeFiles/${PROJECT_NAME}-config-version.cmake
DESTINATION cmake
)

# --- CPack

set(CPACK_GENERATOR TZST)
set(CPACK_SOURCE_GENERATOR TZST)
set(CPACK_PACKAGE_VENDOR "NPT(ENSEEIHT)-IRIT")
set(CPACK_PACKAGE_CONTACT "NPT(ENSEEIHT)-IRIT")
set(CPACK_DEBIAN_PACKAGE_DEPENDS "liblapack-dev")
set(CPACK_RESOURCE_FILE_LICENSE "${CMAKE_CURRENT_SOURCE_DIR}/LICENSE")
set(CPACK_RESOURCE_FILE_README "${CMAKE_CURRENT_SOURCE_DIR}/README.md")
set(CPACK_OUTPUT_FILE_PREFIX "${CMAKE_CURRENT_BINARY_DIR}/package")
set(CPACK_PACKAGE_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR})

# not .gitignore as its regex syntax is more advanced than CMake
file(READ ${CMAKE_CURRENT_LIST_DIR}/.cpack_ignore _cpack_ignore)
string(REGEX REPLACE "\n" ";" _cpack_ignore ${_cpack_ignore})
set(CPACK_SOURCE_IGNORE_FILES "${_cpack_ignore}")

install(FILES ${CPACK_RESOURCE_FILE_README} ${CPACK_RESOURCE_FILE_LICENSE}
DESTINATION share/docs/${PROJECT_NAME}
)

include(CPack)
