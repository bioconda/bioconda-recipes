cmake_minimum_required(VERSION 3.10)

project(msa LANGUAGES CXX)
set(CMAKE_PREFIX_PATH "$ENV{PREFIX}")

set(twilight_VERSION "?.?.?")
execute_process(COMMAND head -n1 ${CMAKE_SOURCE_DIR}/version.txt OUTPUT_VARIABLE VERSION)
string(REGEX REPLACE "^v([0-9]+)\\..*" "\\1" VERSION_MAJOR "${VERSION}")
string(REGEX REPLACE "^v[0-9]+\\.([0-9]+).*" "\\1" VERSION_MINOR "${VERSION}")
string(REGEX REPLACE "^v[0-9]+\\.[0-9]+\\.([0-9]+).*" "\\1" VERSION_PATCH "${VERSION}")
if ("${VERSION_PATCH}" MATCHES "[0-9]+")
    set(twilight_VERSION "${VERSION_MAJOR}.${VERSION_MINOR}.${VERSION_PATCH}")
endif()
configure_file(src/version.hpp.in ${CMAKE_SOURCE_DIR}/src/version.hpp)

include(CheckLanguage)
check_language(CUDA)
if(CMAKE_CUDA_COMPILER)
	message(STATUS "CUDA detected.")
	# For CUDA
	enable_language(CUDA)
	set(CMAKE_CUDA_COMPILER "/usr/local/cuda/bin/nvcc")
	find_package(CUDA 10.0 REQUIRED)
	TRY_RUN(
    	FIND_GPU_RESULT
		FIND_GPU_COMPILE_RESULT
		${CMAKE_CURRENT_BINARY_DIR}/
		${CMAKE_CURRENT_BINARY_DIR}/../src/findgpu.cu
	)
	if("${FIND_GPU_COMPILE_RESULT}" AND ("${FIND_GPU_RESULT}" EQUAL 0))
		message(STATUS "CUDA-capable GPU detected.")
		set(CMAKE_CUDA_FLAGS "${CMAKE_CUDA_FLAGS} -arch=native -lineinfo")
		set(SRC_FILES src/twilight-main.cu
				  src/align.cu	
				  src/msa-gpu.cu
				  src/tree.cpp
				  src/setting.cpp
				  src/treePartition.cpp
				  src/TALCO-XDrop.cpp
				  src/util.cpp
				  src/msa-cpu.cpp
				  )
	else()
	    message(WARNING "No CUDA-capable GPU found.")
		set(SRC_FILES src/twilight-main.cpp
				  src/tree.cpp
				  src/setting.cpp
				  src/treePartition.cpp
				  src/TALCO-XDrop.cpp
				  src/util.cpp
				  src/msa-cpu.cpp
	              )	
	endif()
else()
  	message(WARNING "No CUDA found.")
	set(SRC_FILES src/twilight-main.cpp
				  src/tree.cpp
				  src/setting.cpp
				  src/treePartition.cpp
				  src/TALCO-XDrop.cpp
				  src/util.cpp
				  src/msa-cpu.cpp
	              )	
endif()

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -O4 -std=c++17 -Wall -g -Wno-sign-compare -Wno-unused-variable")

# find_package(Boost COMPONENTS program_options REQUIRED)
# find_package(ZLIB REQUIRED)
# find_path(ZLIB_INCLUDE_DIR zlib.h)
# include_directories(${ZLIB_INCLUDE_DIR})
# # include(${TBB_DIR}/cmake/TBBBuild.cmake)
# # tbb_build(TBB_ROOT ${TBB_DIR} CONFIG_DIR TBB_DIR MAKE_ARGS tbb_cpf=1)
# # find_package(TBB REQUIRED tbbmalloc tbbmalloc_proxy tbb_preview)

# ---- Boost ----
find_package(Boost REQUIRED COMPONENTS program_options filesystem system)
include_directories(${Boost_INCLUDE_DIRS})
link_directories(${Boost_LIBRARY_DIRS})

# ---- Zlib ----
find_package(ZLIB REQUIRED)
include_directories(${ZLIB_INCLUDE_DIRS})
link_directories(${ZLIB_LIBRARY_DIRS})

# ---- TBB ----
# Ensure TBB is found in Conda's directory
set(TBB_ROOT "$ENV{PREFIX}")

# Find TBB libraries manually
find_library(TBB_LIB tbb HINTS ${TBB_ROOT}/lib REQUIRED)
find_library(TBB_MALLOC_LIB tbbmalloc HINTS ${TBB_ROOT}/lib REQUIRED)
find_library(TBB_MALLOC_PROXY_LIB tbbmalloc_proxy HINTS ${TBB_ROOT}/lib REQUIRED)

# Include TBB headers
include_directories(${TBB_ROOT}/include)

# find_package(TBB REQUIRED)
add_executable (twilight ${SRC_FILES})
# target_link_libraries(twilight PRIVATE ${Boost_LIBRARIES} ${ZLIB_LIBRARIES} ${TBB_IMPORTED_TARGETS} -lboost_filesystem)
# target_link_libraries(twilight PRIVATE ${Boost_LIBRARIES} ${ZLIB_LIBRARIES} -lboost_filesystem)
target_link_libraries(twilight PRIVATE ${Boost_LIBRARIES} ${ZLIB_LIBRARIES} ${TBB_LIB}  ${TBB_MALLOC_LIB} -lboost_filesystem)