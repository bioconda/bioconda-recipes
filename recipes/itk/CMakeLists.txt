cmake_minimum_required(VERSION 2.8)
 
project(CreateVector)
 
find_package(ITK REQUIRED)
include(${ITK_USE_FILE})
if (ITKVtkGlue_LOADED)
  find_package(VTK REQUIRED)
  include(${VTK_USE_FILE})
endif()
 
add_executable(CreateVector MACOSX_BUNDLE CreateVector.cxx)
 
if( "${ITK_VERSION_MAJOR}" LESS 4 )
  target_link_libraries(CreateVector ITKReview ${ITK_LIBRARIES})
else( "${ITK_VERSION_MAJOR}" LESS 4 )
  target_link_libraries(CreateVector ${ITK_LIBRARIES})
endif( "${ITK_VERSION_MAJOR}" LESS 4 )
