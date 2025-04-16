cmake_minimum_required(VERSION 3.5)

project(libcarna-test)

include(FindPackageHandleStandardArgs)

find_package( Carna ${REQUIRED_VERSION_CARNA} REQUIRED )
include_directories( ${CARNA_INCLUDE_DIR} )
set(CARNA_VERSION ${FOUND_VERSION})

add_executable(test test.cpp)
target_link_libraries(test -lGLU)
