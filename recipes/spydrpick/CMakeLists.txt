# Version $Id: $

# SpydrPick src

############################
## Add sources and includes
###

include_directories(
	${SPYDRPICK_INCLUDE_DIR}
	${APEGRUNT_INCLUDE_DIR}
	$(ARACNE_INCLUDE_DIR)
	${CMAKE_CURRENT_BINARY_DIR}
	${Boost_INCLUDE_DIRS}
	${TBB_INCLUDE_DIRS}
)

link_directories( ${Boost_LIBRARY_DIRS} )

set( SPYDRPICK_SOURCES
	SpydrPick.cpp
	SpydrPick_options.cpp
	ARACNE_options.cpp
) # *.cpp *.hpp *.cc


#################################
## Add libraries and executables
###

set( CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin )

### General executable flags
set( SPYDRPICK_EXE_LINKER_FLAGS "-fPIE -static-libstdc++" ) # -static

if("${CMAKE_CXX_COMPILER_ID}" MATCHES "GNU")
	set( CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} ${SPYDRPICK_EXE_LINKER_FLAGS}" )
elseif("${CMAKE_CXX_COMPILER_ID}" MATCHES "Clang")
	set( CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} ${SPYDRPICK_EXE_LINKER_FLAGS}" )
endif()


### General optimization flags	
set( SPYDRPICK_OPTIMIZATION_FLAGS "${SPYDRPICK_OPTIMIZATION_FLAGS} -O3 -msse2" ) #-mpopcnt" ) # -msse3
set( SPYDRPICK_OPTIMIZATION_FLAGS "${SPYDRPICK_OPTIMIZATION_FLAGS} -ftree-vectorize" ) # don't use -fwhole-program in combination with -flto

# GCC-specific optimization flags
set( SPYDRPICK_GCC_OPTIMIZATION_FLAGS "-flto -ffat-lto-objects -fopenmp" ) # -flto-report"

# Clang-specific optimization flags
set( SPYDRPICK_CLANG_OPTIMIZATION_FLAGS "-flto=thin -fopenmp" )


### General release build flags
set( SPYDRPICK_RELEASE_FLAGS "-DNDEBUG -Wall -w -fvisibility=hidden -fvisibility-inlines-hidden" ) # CMake will add '-O2 -DNDEBUG' for Release builds

# GCC-specific release build flags
set( SPYDRPICK_GCC_RELEASE_FLAGS "-Wl,--strip-all" )

# Clang-specific release build flags
set( SPYDRPICK_CLANG_RELEASE_FLAGS "-Wl,-s" )

if("${CMAKE_CXX_COMPILER_ID}" MATCHES "GNU")
	# Bulldoze CMake's default CMAKE_CXX_FLAGS_RELEASE
	set( CMAKE_CXX_FLAGS_RELEASE "${SPYDRPICK_OPTIMIZATION_FLAGS} ${SPYDRPICK_GCC_OPTIMIZATION_FLAGS} ${SPYDRPICK_RELEASE_FLAGS} ${SPYDRPICK_GCC_RELEASE_FLAGS}")
elseif("${CMAKE_CXX_COMPILER_ID}" MATCHES "Clang")
	set( CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} ${SPYDRPICK_OPTIMIZATION_FLAGS} ${SPYDRPICK_CLANG_OPTIMIZATION_FLAGS} ${SPYDRPICK_RELEASE_FLAGS} ${SPYDRPICK_CLANG_RELEASE_FLAGS}")
endif()


### General debug build flags
set( SPYDRPICK_DEBUG_FLAGS "-O3 -g -ftree-vectorizer-verbose=2 -Wall" )

# GCC-specific debug build flags
set( SPYDRPICK_GCC_DEBUG_FLAGS "" )

# Clang-specific debug build flags
set( SPYDRPICK_CLANG_DEBUG_FLAGS "" )

if("${CMAKE_CXX_COMPILER_ID}" MATCHES "GNU")
	set( CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} ${SPYDRPICK_OPTIMIZATION_FLAGS} ${SPYDRPICK_GCC_OPTIMIZATION_FLAGS} ${SPYDRPICK_DEBUG_FLAGS} ${SPYDRPICK_GCC_DEBUG_FLAGS}")
elseif("${CMAKE_CXX_COMPILER_ID}" MATCHES "Clang")
	set( CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} ${SPYDRPICK_OPTIMIZATION_FLAGS} ${SPYDRPICK_CLANG_OPTIMIZATION_FLAGS} ${SPYDRPICK_DEBUG_FLAGS} ${SPYDRPICK_CLANG_DEBUG_FLAGS}")
endif()

### General profiling build flags
set( SPYDRPICK_PROFILE_FLAGS "-DNDEBUG -Wall -w -fno-omit-frame-pointer" ) # add "-pg" to instrument for gprof; perf is happy as long as symbols and frame pointers are present 

if("${CMAKE_CXX_COMPILER_ID}" MATCHES "GNU")
	set( CMAKE_CXX_FLAGS_PROFILE "${CMAKE_CXX_FLAGS_PROFILE} ${SPYDRPICK_OPTIMIZATION_FLAGS} ${SPYDRPICK_GCC_OPTIMIZATION_FLAGS} ${SPYDRPICK_PROFILE_FLAGS}")
elseif("${CMAKE_CXX_COMPILER_ID}" MATCHES "Clang")
	set( CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} ${SPYDRPICK_OPTIMIZATION_FLAGS} ${SPYDRPICK_CLANG_OPTIMIZATION_FLAGS} ${SPYDRPICK_PROFILE_FLAGS}")
endif()


### Set preferred linker
set( CMAKE_LINKER "ld.gold" )


#################################
## Add libraries and executables
###

set( CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib ) # dynamic libraries
set( CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib ) # static libraries
set( CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin )

if( SPYDRPICK_SOURCES )
	add_executable( SpydrPick
		${SPYDRPICK_SOURCES}
	)
	target_link_libraries( SpydrPick libapegrunt )
	#target_link_libraries( SpydrPick ${APEGRUNT_LIBRARIES} )
	#set_target_properties( SpydrPick PROPERTIES COMPILE_FLAGS "--std=c++14" )
endif()


#################################
## Link external libraries
###

# Add Boost libraries
if( NOT SPYDRPICK_NO_BOOST )
	target_link_libraries( SpydrPick ${Boost_LIBRARIES} )
endif()

# Add pthreads library if building in UNIX
if( UNIX )
	target_link_libraries( SpydrPick pthread )
endif()

# Add librt when building in Linux (required by the Bioconda build environment)
if( UNIX AND NOT APPLE )
	target_link_libraries( SpydrPick rt )
endif()

# Add TBB libraries
if( NOT SPYDRPICK_NO_TBB )
	target_link_libraries( SpydrPick "-Wl,-Bdynamic${TBB_LIBRARIES}" )
endif()

# Prevent linking against shared libraries on OS X;
# Apple gcc always links against a shared version of a library if present,
# regardless of -Bstatic or equivalent linker flags.
if(APPLE)
	set_target_properties( SpydrPick PROPERTIES LINK_SEARCH_END_STATIC TRUE )
endif(APPLE)
