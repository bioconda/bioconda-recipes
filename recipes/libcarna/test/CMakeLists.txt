cmake_minimum_required( VERSION 3.5 )
project( libcarna-test )
include( FindPackageHandleStandardArgs )

# Find dependency required to build the test
find_package( Eigen3 REQUIRED )
include_directories( ${EIGEN3_INCLUDE_DIR} )

# Verify that the Find*.cmake file is properly installed
find_package( LibCarna ${REQUIRED_VERSION_LIBCARNA} REQUIRED COMPONENTS release )
include_directories( ${LibCarna_INCLUDE_DIR} )
set( LIBCARNA_VERSION ${FOUND_VERSION} )

# Verify that headers are found and libraries can be linked
add_executable( test test.cpp )
target_link_libraries( test -lGLU ${LibCarna_LIBRARIES} )

# Verify that all LICENSE files are shipped
foreach( LICENSE_NAME Carna LibCarna Eigen GLEW )
    if( NOT EXISTS "${LibCarna_LICENSE_DIR}/LICENSE-${LICENSE_NAME}" )
        message( FATAL_ERROR "LICENSE file missing: ${LICENSE_NAME}" )
    endif()
endforeach()
