cmake_minimum_required (VERSION 3.8) 
cmake_policy(SET CMP0069 NEW)
project(wepp)

if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE "RelWithDebInfo")
endif()

configure_file(src/version.hpp.in version.hpp)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -O3 -std=c++17 -Wall -Wno-unused-function  -Wno-deprecated-declarations") 
set(CMAKE_CXX_FLAGS_DEBUG "-fsanitize=address -O0 -ggdb3 -fno-eliminate-unused-debug-symbols")
set(CMAKE_CXX_FLAGS_RELWITHDEBINFO "-DNDEBUG -O3")
set(CMAKE_CXX_FLAGS_RELEASE "-DNDEBUG -O3")
set(CMAKE_INCLUDE_CURRENT_DIR ON) 

find_package(Protobuf REQUIRED)
include(FindProtobuf) 

# Print version messages
if(Protobuf_FOUND)
    message(STATUS "Using Protocol Buffers ${Protobuf_VERSION}")
endif()
find_package(MPI REQUIRED)
include_directories(SYSTEM ${MPI_INCLUDE_PATH})
include_directories(${Protobuf_INCLUDE_DIRS})

set(TBB_ROOT "$ENV{PREFIX}")
if(NOT TBB_ROOT)
  message(FATAL_ERROR "TBB_ROOT or PREFIX environment variable must be set.")
endif()
find_library(TBB_LIB tbb HINTS ${TBB_ROOT}/lib REQUIRED)
find_library(TBB_MALLOC_LIB tbbmalloc HINTS ${TBB_ROOT}/lib REQUIRED)
find_library(TBB_MALLOC_PROXY_LIB tbbmalloc_proxy HINTS ${TBB_ROOT}/lib REQUIRED)

find_package(Boost COMPONENTS program_options iostreams filesystem date_time REQUIRED)

#find_package(OpenMP REQUIRED)

include_directories(${Boost_INCLUDE_DIRS})
file(GLOB WBE_SRCS "src/WEPP/*.cpp" "src/WEPP/*.hpp")

if(DEFINED Protobuf_PATH)
    protobuf_generate(
        LANGUAGE cpp
        TARGET wepp
        PROTOS sam.proto)

    protobuf_generate(
        LANGUAGE cpp
        TARGET wepp
        PROTOS parsimony.proto)

    add_executable(wepp
	    ${WBE_SRCS} ${PANMAT_SRCS}
    )
    
    add_executable(closest_peak_clustering 
        src/closest_peak_clustering.cpp
    )
else()
    protobuf_generate_cpp(
        PROTO_SRCS PROTO_HDRS
        parsimony.proto)

    protobuf_generate_cpp(
        SAM_SRCS SAM_HDRS
        sam.proto)

    add_executable(wepp
	    ${WBE_SRCS}
        src/mutation_annotated_tree.cpp
        src/usher_mapper.cpp
        ${PROTO_SRCS} ${SAM_SRCS}
        ${PROTO_HDRS} ${SAM_HDRS}
        )

    add_executable(closest_peak_clustering 
        src/closest_peak_clustering.cpp
    )
endif()


target_link_libraries(wepp PRIVATE stdc++ ${Boost_LIBRARIES} ${TBB_LIB} ${TBB_MALLOC_LIB} ${TBB_MALLOC_PROXY_LIB} ${Protobuf_LIBRARIES})
target_link_libraries(closest_peak_clustering PRIVATE stdc++ ${TBB_LIB} ${TBB_MALLOC_LIB} ${TBB_MALLOC_PROXY_LIB})
