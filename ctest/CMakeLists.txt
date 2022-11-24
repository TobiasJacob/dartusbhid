# The Flutter tooling requires that developers have CMake 3.10 or later
# installed. You should not increase this version, as doing so will cause
# the plugin to fail to compile for some customers of the plugin.
cmake_minimum_required(VERSION 3.10)

project(testexec_library VERSION 0.0.1 LANGUAGES C)

set (CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR})
set (CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR})

add_subdirectory("${CMAKE_CURRENT_SOURCE_DIR}/../hidapi" "${CMAKE_CURRENT_BINARY_DIR}/shared")

get_cmake_property(_variableNames VARIABLES)
list (SORT _variableNames)
foreach (_variableName ${_variableNames})
    message(STATUS "${_variableName}=${${_variableName}}")
endforeach()

include_directories("../hidapi")
add_executable(testexec
  "test.c"
)
add_dependencies(testexec hidapi)
target_link_libraries(testexec PRIVATE hidapi)
