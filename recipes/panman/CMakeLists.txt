cmake_minimum_required(VERSION 3.10)
project(panmanUtils LANGUAGES CXX)

# ---- Version ----

# set version
set(panmanUtils_VERSION "?.?.?")
execute_process(COMMAND head -n1 ${CMAKE_SOURCE_DIR}/version.txt OUTPUT_VARIABLE VERSION)
string(REGEX REPLACE "^v([0-9]+)\\..*" "\\1" VERSION_MAJOR "${VERSION}")
string(REGEX REPLACE "^v[0-9]+\\.([0-9]+).*" "\\1" VERSION_MINOR "${VERSION}")
string(REGEX REPLACE "^v[0-9]+\\.[0-9]+\\.([0-9]+).*" "\\1" VERSION_PATCH "${VERSION}")
if ("${VERSION_PATCH}" MATCHES "[0-9]+")
    set(panmanUtils_VERSION "${VERSION_MAJOR}.${VERSION_MINOR}.${VERSION_PATCH}")
endif()
configure_file(src/version.hpp.in ${CMAKE_SOURCE_DIR}/src/version.hpp)

set(CMAKE_PREFIX_PATH "$ENV{PREFIX}")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -O4 -std=c++17 -Wall -g -Wno-sign-compare -Wno-unused-variable -w")

# ---- Boost ----
find_package(Boost REQUIRED COMPONENTS program_options iostreams filesystem date_time)

# ---- Protobuf ----
find_package(Protobuf REQUIRED)

# ---- Cap’n Proto ----
find_program(CAPNP_EXECUTABLE capnp REQUIRED)
find_program(CAPNPC_CXX_EXECUTABLE capnpc-c++ REQUIRED)
find_package(CapnProto REQUIRED)
add_definitions(${CAPNP_DEFINITIONS})

# ---- TBB ----
set(TBB_ROOT "$ENV{PREFIX}")
if(NOT TBB_ROOT)
  message(FATAL_ERROR "TBB_ROOT or PREFIX environment variable must be set.")
endif()
find_library(TBB_LIB tbb HINTS ${TBB_ROOT}/lib REQUIRED)
find_library(TBB_MALLOC_LIB tbbmalloc HINTS ${TBB_ROOT}/lib REQUIRED)
find_library(TBB_MALLOC_PROXY_LIB tbbmalloc_proxy HINTS ${TBB_ROOT}/lib REQUIRED)

# ---- JsonCpp ----
find_package(jsoncpp CONFIG REQUIRED)

# ---- Source Files ----
file(GLOB PANMAT_SRCS "src/panmanUtils.cpp" "src/panman.cpp" "src/panmanUtils.hpp" "src/panman.hpp")

# ---- Cap’n Proto and Protobuf files ----
capnp_generate_cpp(CAPNP_SRCS CAPNP_HDRS panman.capnp)
protobuf_generate_cpp(PROTO_SRCS PROTO_HDRS usher.proto panman.proto)

# ---- Build executable ----
add_executable(panmanUtils
    ${PANMAT_SRCS}
    ${CAPNP_SRCS}
    ${CAPNP_HDRS}
    ${PROTO_SRCS}
    ${PROTO_HDRS}
)

target_compile_options(panmanUtils PRIVATE -DTBB_SUPPRESS_DEPRECATED_MESSAGES)

target_link_libraries(panmanUtils
    PRIVATE
    stdc++
    JsonCpp::JsonCpp
    ${Boost_LIBRARIES}
    ${TBB_LIB}
    ${TBB_MALLOC_LIB}
    ${TBB_MALLOC_PROXY_LIB}
    ${CAPNP_LIBRARIES}
    ${Protobuf_LIBRARIES}
)

target_include_directories(panmanUtils
    PRIVATE
        ${Boost_INCLUDE_DIRS}
        ${Protobuf_INCLUDE_DIRS}
        ${CAPNP_INCLUDE_DIRS}
        ${TBB_ROOT}/include
        "${PROJECT_BINARY_DIR}"
)

install(TARGETS panmanUtils DESTINATION bin)
