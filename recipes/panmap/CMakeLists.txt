cmake_minimum_required(VERSION 3.12)
project(panmap VERSION 0.1.0)

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++17 -Wall -pipe -Wno-unused-function -Wno-deprecated-declarations -w")

include(GNUInstallDirs)

# ===== Find all system packages =====
find_package(TBB REQUIRED)
find_package(Protobuf REQUIRED)
find_package(Boost COMPONENTS program_options iostreams filesystem date_time REQUIRED)
find_package(ZLIB REQUIRED)
find_package(absl REQUIRED)
find_package(spdlog REQUIRED)
find_package(jsoncpp REQUIRED)
find_package(zstd REQUIRED)
find_package(PkgConfig)

find_library(PROTOBUF_LIB_PATH NAMES protobuf REQUIRED)
find_library(CAPNP_LIBRARY NAMES capnp REQUIRED)
find_library(KJ_LIBRARY NAMES kj REQUIRED)
find_library(DEFLATE_LIBRARY NAMES deflate REQUIRED)
find_library(ZSTD_LIBRARY NAMES zstd REQUIRED)
find_library(HTS_LIBRARY NAMES hts REQUIRED)
find_path(HTS_INCLUDE_DIR htslib/hts.h REQUIRED)
find_program(CAPNP_EXECUTABLE NAMES capnp REQUIRED)
find_program(CAPNPC_CXX_EXECUTABLE NAMES capnpc-c++ REQUIRED)

# Find capnp schema include directory (contains capnp/c++.capnp)
find_path(CAPNP_SCHEMA_DIR capnp/c++.capnp REQUIRED)

include_directories(SYSTEM ${Protobuf_INCLUDE_DIRS})

# ===== CapnProto code generation =====
add_custom_target(capnp_tools ALL)

set(LITE_CAPNP_SRC_FILE "${CMAKE_CURRENT_SOURCE_DIR}/src/index_lite.capnp")
set(LITE_CAPNP_GEN_DIR "${CMAKE_CURRENT_BINARY_DIR}")
set(LITE_CAPNP_GEN_CPP "${LITE_CAPNP_GEN_DIR}/index_lite.capnp.c++")
set(LITE_CAPNP_GEN_H "${LITE_CAPNP_GEN_DIR}/index_lite.capnp.h")

add_custom_command(
    OUTPUT ${LITE_CAPNP_GEN_CPP} ${LITE_CAPNP_GEN_H}
    COMMAND ${CAPNP_EXECUTABLE} compile -o${CAPNPC_CXX_EXECUTABLE}
        -I${CAPNP_SCHEMA_DIR}
        --src-prefix=${CMAKE_CURRENT_SOURCE_DIR}/src ${LITE_CAPNP_SRC_FILE}
    WORKING_DIRECTORY ${LITE_CAPNP_GEN_DIR}
    DEPENDS ${LITE_CAPNP_SRC_FILE}
    COMMENT "Generating C++ from index_lite.capnp"
    VERBATIM
)

add_custom_target(index_capnp_generator ALL
    DEPENDS ${LITE_CAPNP_GEN_CPP} ${LITE_CAPNP_GEN_H}
)

# capnp_generate_cpp function for panman
function(capnp_generate_cpp SOURCES HEADERS)
    if(NOT ARGN)
        message(SEND_ERROR "capnp_generate_cpp: missing schema files")
        return()
    endif()
    set(output_sources "")
    set(output_headers "")
    foreach(schema_file ${ARGN})
        get_filename_component(file_name ${schema_file} NAME_WE)
        set(schema_cpp "${CMAKE_CURRENT_BINARY_DIR}/${file_name}.capnp.c++")
        set(schema_h "${CMAKE_CURRENT_BINARY_DIR}/${file_name}.capnp.h")
        list(APPEND output_sources "${schema_cpp}")
        list(APPEND output_headers "${schema_h}")
        add_custom_command(
            OUTPUT "${schema_cpp}" "${schema_h}"
            COMMAND ${CAPNP_EXECUTABLE} compile -o${CAPNPC_CXX_EXECUTABLE}
                -I${CAPNP_SCHEMA_DIR}
                --src-prefix=${CMAKE_CURRENT_SOURCE_DIR} ${schema_file}
            DEPENDS "${schema_file}" capnp_tools
            COMMENT "Compiling Cap'n Proto schema ${schema_file}"
            VERBATIM
        )
    endforeach()
    set(${SOURCES} ${output_sources} PARENT_SCOPE)
    set(${HEADERS} ${output_headers} PARENT_SCOPE)
endfunction()

# ===== Build panman from vendored source =====
if(NOT PANMAN_SOURCE_DIR)
    set(PANMAN_SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/external/panman")
endif()
set(PANMAN_BINARY_DIR "${CMAKE_CURRENT_BINARY_DIR}/panman-build")

# Remove panman's line 15 (the #include that causes issues) and fix version string
execute_process(
    COMMAND sed -i.bak "15d" "${PANMAN_SOURCE_DIR}/src/panmanUtils.cpp"
)
execute_process(
    COMMAND sed -i.bak "s/PROJECT_VERSION/\"1.0\"/g" "${PANMAN_SOURCE_DIR}/src/panmanUtils.cpp"
)

# Write panman CMakeLists.txt
file(WRITE "${PANMAN_SOURCE_DIR}/CMakeLists.txt" [=[
cmake_minimum_required(VERSION 3.8)
project(panmanUtils)
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++17 -Wall -pipe -Wno-unused-function -Wno-deprecated-declarations -w")
set(CMAKE_INCLUDE_CURRENT_DIR ON)

find_package(Protobuf REQUIRED)
find_library(PANMAN_PROTOBUF_LIB NAMES protobuf REQUIRED)
find_library(PANMAN_CAPNP_LIB NAMES capnp REQUIRED)
find_library(PANMAN_KJ_LIB NAMES kj REQUIRED)
find_path(PANMAN_CAPNP_SCHEMA_DIR capnp/c++.capnp REQUIRED)
include_directories(SYSTEM ${Protobuf_INCLUDE_DIRS})
include_directories(SYSTEM ${PANMAN_CAPNP_SCHEMA_DIR})

set(PROTO_FILES
    "${CMAKE_CURRENT_SOURCE_DIR}/panman.proto"
    "${CMAKE_CURRENT_SOURCE_DIR}/usher.proto"
)
protobuf_generate_cpp(PROTO_SRCS PROTO_HDRS ${PROTO_FILES})
include_directories(${CMAKE_CURRENT_BINARY_DIR})

find_package(Boost COMPONENTS program_options iostreams filesystem date_time REQUIRED)
find_package(TBB REQUIRED)
include_directories(${Boost_INCLUDE_DIRS})

set(PANMAN_SOURCES src/panman.cpp ${PROTO_SRCS})
add_library(panman_lib STATIC ${PANMAN_SOURCES})
set_target_properties(panman_lib PROPERTIES OUTPUT_NAME "panman")
target_compile_options(panman_lib PRIVATE -fPIC)

add_executable(panmanUtils src/panmanUtils.cpp ${PROTO_SRCS})

set(PANMAN_CAPNP_SRC "${CMAKE_CURRENT_SOURCE_DIR}/panman.capnp")
set(PANMAN_CAPNP_H "${CMAKE_CURRENT_BINARY_DIR}/panman.capnp.h")
set(PANMAN_CAPNP_CPP "${CMAKE_CURRENT_BINARY_DIR}/panman.capnp.c++")

add_custom_command(
    OUTPUT "${PANMAN_CAPNP_H}" "${PANMAN_CAPNP_CPP}"
    COMMAND ${CAPNP_EXECUTABLE} compile -o${CAPNPC_CXX_EXECUTABLE}
            -I${PANMAN_CAPNP_SCHEMA_DIR}
            --src-prefix=${CMAKE_CURRENT_SOURCE_DIR}
            ${PANMAN_CAPNP_SRC}
            -I${CMAKE_CURRENT_SOURCE_DIR}
    WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
    DEPENDS "${PANMAN_CAPNP_SRC}"
    COMMENT "Generating C++ from panman.capnp"
)

add_custom_target(generate_panman_capnp_extern ALL
    DEPENDS "${PANMAN_CAPNP_H}" "${PANMAN_CAPNP_CPP}"
)

target_sources(panman_lib PRIVATE "${PANMAN_CAPNP_CPP}")
target_sources(panmanUtils PRIVATE "${PANMAN_CAPNP_CPP}")
add_dependencies(panman_lib generate_panman_capnp_extern)
add_dependencies(panmanUtils generate_panman_capnp_extern)

target_link_libraries(panman_lib
    ${PANMAN_CAPNP_LIB} ${PANMAN_KJ_LIB} jsoncpp_lib
    ${PANMAN_PROTOBUF_LIB} ${Boost_LIBRARIES} TBB::tbb pthread
)
target_link_libraries(panmanUtils
    panman_lib ${PANMAN_CAPNP_LIB} ${PANMAN_KJ_LIB} jsoncpp_lib
    ${PANMAN_PROTOBUF_LIB} ${Boost_LIBRARIES} TBB::tbb pthread
)
]=])

add_subdirectory(${PANMAN_SOURCE_DIR} ${PANMAN_BINARY_DIR})
add_dependencies(generate_panman_capnp_extern capnp_tools)

# Interface target for panmap to depend on
add_library(panman INTERFACE)
target_include_directories(panman INTERFACE
    ${PANMAN_SOURCE_DIR}/src
    ${PANMAN_BINARY_DIR}
)
add_dependencies(panman panman_lib)

# ===== Build bundled 3rdparty tools =====

# Minimap2
if(APPLE AND CMAKE_SYSTEM_PROCESSOR STREQUAL "arm64")
    set(MINIMAP2_MAKE_ARGS "arm_neon=1" "aarch64=1")
elseif(CMAKE_SYSTEM_PROCESSOR STREQUAL "aarch64")
    set(MINIMAP2_MAKE_ARGS "arm_neon=1" "aarch64=1")
else()
    set(MINIMAP2_MAKE_ARGS "")
endif()

add_custom_command(
    OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/lib/libminimap2.a
    COMMAND cd ${CMAKE_CURRENT_SOURCE_DIR}/src/3rdparty/minimap2 && make clean && make -j libminimap2.a "CPPFLAGS=-I${CMAKE_INSTALL_PREFIX}/include" ${MINIMAP2_MAKE_ARGS}
    COMMAND mkdir -p ${CMAKE_CURRENT_BINARY_DIR}/lib ${CMAKE_CURRENT_BINARY_DIR}/bin
    COMMAND cp ${CMAKE_CURRENT_SOURCE_DIR}/src/3rdparty/minimap2/libminimap2.a ${CMAKE_CURRENT_BINARY_DIR}/lib/libminimap2.a
    COMMAND rm -f ${CMAKE_CURRENT_SOURCE_DIR}/src/3rdparty/minimap2/*.o
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
)

add_custom_target(minimap2_target
    DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/lib/libminimap2.a
    COMMENT "Building minimap2 library"
)

# Htslib (system/conda package)
add_library(htslib SHARED IMPORTED GLOBAL)
set_target_properties(htslib PROPERTIES
    IMPORTED_LOCATION "${HTS_LIBRARY}"
    INTERFACE_INCLUDE_DIRECTORIES "${HTS_INCLUDE_DIR}"
)

# BWA
set(BWA_SOURCES
    src/3rdparty/bwa/bwa.c src/3rdparty/bwa/run.c src/3rdparty/bwa/bwase.c
    src/3rdparty/bwa/bwaseqio.c src/3rdparty/bwa/bwt.c src/3rdparty/bwa/bwtaln.c
    src/3rdparty/bwa/bwtindex.c src/3rdparty/bwa/bwt_gen.c
    src/3rdparty/bwa/bwtsw2_core.c src/3rdparty/bwa/bwtsw2_main.c
    src/3rdparty/bwa/bwtsw2_aux.c src/3rdparty/bwa/bwt_lite.c
    src/3rdparty/bwa/bwtsw2_chain.c src/3rdparty/bwa/fastmap.c
    src/3rdparty/bwa/bwtsw2_pair.c src/3rdparty/bwa/utils.c
    src/3rdparty/bwa/bwape.c src/3rdparty/bwa/kopen.c
    src/3rdparty/bwa/pemerge.c src/3rdparty/bwa/maxk.c
    src/3rdparty/bwa/bwashm.c src/3rdparty/bwa/bntseq.c
    src/3rdparty/bwa/is.c src/3rdparty/bwa/bwamem.c
    src/3rdparty/bwa/bwamem_pair.c src/3rdparty/bwa/bwamem_extra.c
    src/3rdparty/bwa/malloc_wrap.c src/3rdparty/bwa/QSufSort.c
    src/3rdparty/bwa/rope.c src/3rdparty/bwa/kstring.c
    src/3rdparty/bwa/ksw.c src/3rdparty/bwa/bamlite.c
    src/3rdparty/bwa/rle.c src/3rdparty/bwa/bwtgap.c
    src/mm_align.c
)

# Bcftools
file(GLOB BCFTOOLS_SOURCES src/3rdparty/bcftools/*.c)

# Build dependency targets
add_custom_target(build-deps DEPENDS minimap2_target capnp_tools)

add_library(minimap2 STATIC IMPORTED)
set_target_properties(minimap2 PROPERTIES IMPORTED_LOCATION "${CMAKE_CURRENT_BINARY_DIR}/lib/libminimap2.a")
add_dependencies(minimap2 minimap2_target)

add_library(bwa STATIC ${BWA_SOURCES})
target_include_directories(bwa PUBLIC src/3rdparty/bwa)
target_compile_options(bwa PRIVATE -fPIC -w)

add_library(bcftools STATIC ${BCFTOOLS_SOURCES})
target_include_directories(bcftools PUBLIC src/3rdparty/bcftools)
target_include_directories(bcftools PRIVATE ${HTS_INCLUDE_DIR})
target_compile_options(bcftools PRIVATE -fPIC -w)

# ===== panmap executable =====
set(PANMAP_SOURCES_MAIN
    src/main.cpp src/conversion.cpp src/panmap_utils.cpp
    src/genotyping.cpp src/index_single_mode.cpp src/placement.cpp
    src/seeding.cpp src/index_utils.cpp src/mgsr.cpp
    src/mm_align.c src/pileup.c src/zstd_compression.cpp
)

add_executable(panmap ${PANMAP_SOURCES_MAIN})
add_dependencies(panmap build-deps index_capnp_generator)

target_sources(panmap PRIVATE ${LITE_CAPNP_GEN_CPP})
target_include_directories(panmap PRIVATE
    ${CMAKE_CURRENT_BINARY_DIR}
    ${CMAKE_CURRENT_SOURCE_DIR}/src/3rdparty
    ${HTS_INCLUDE_DIR}
)

target_link_libraries(panmap PRIVATE
    panman
    panman_lib
    bwa
    bcftools
    minimap2
    htslib
    ${CAPNP_LIBRARY}
    ${KJ_LIBRARY}
    jsoncpp_lib
    ${PROTOBUF_LIB_PATH}
    Boost::program_options
    Boost::iostreams
    Boost::filesystem
    ZLIB::ZLIB
    ${ZSTD_LIBRARY}
    TBB::tbb
    spdlog::spdlog
    ${DEFLATE_LIBRARY}
    absl::flat_hash_map
    m
    pthread
)

target_compile_options(panmap PUBLIC -O3)

# ===== Install =====
set_target_properties(panmap PROPERTIES RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin")
install(TARGETS panmap RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR})
