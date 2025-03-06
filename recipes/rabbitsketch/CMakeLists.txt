cmake_minimum_required(VERSION 2.8)

project(rabbitsketch)

option(CXXAPI "build pure c++ library instead of python bind interface" OFF)
#SET(CMAKE_CXX_COMPILER /usr/bin/g++)
#SET(CMAKE_C_COMPILER /usr/bin/gcc)

include_directories(src)

aux_source_directory(src DIR_SRCS)

#linux only 
#set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -O2 -g -std=c++14 -static-libstdc++ -march=native")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -O2 -g -std=c++14 -fopenmp -march=native -fPIC")

#set flags for specific files
#set_source_files_properties(src/MinHash.cpp PROPERTIES COMPILE_FLAGS -mavx2)


if (CXXAPI)
	add_compile_options(-DNOPYTHON)
	add_library("${PROJECT_NAME}" SHARED ${DIR_SRCS})
	add_library("${PROJECT_NAME}_static" STATIC ${DIR_SRCS})
	
  
	#set_target_properties("${PROJECT_NAME}_dynamic" PROPERTIES OUTPUT_NAME ${PROJECT_NAME})
	#set_target_properties("${PROJECT_NAME}_static" PROPERTIES OUTPUT_NAME ${PROJECT_NAME})

	install(TARGETS "${PROJECT_NAME}" "${PROJECT_NAME}_static" 
		   RUNTIME DESTINATION bin
		   LIBRARY DESTINATION lib
		   ARCHIVE DESTINATION lib
	)

	install(FILES "src/Sketch.h" "src/robin_hood.h" "src/MinHash.h" 
		          "src/hash.h" "src/histoSketch.h"
				  "src/HyperLogLog.h"
		      "src/common.h" "src/common.cpp"    "src/hash.h" "src/OrderMinHash.h" "src/histoSketch.h"
				 "src/kseq.h" "src/robin_hood.h" "src/HyperLogLog.h" "src/Kssd.h"  "src/Kssd.cpp" "src/shuffle.h" "src/shuffle.cpp"
			DESTINATION include
		   )
	
	#install(FILES "src/hll/hyperloglog.h"
	#	   DESTINATION include/hll
	#	   )
else ()
	add_subdirectory(pybind11)
	pybind11_add_module(rabbitsketch ${DIR_SRCS})
endif ()
