# define minimum cmake version
cmake_minimum_required(VERSION 3.5 FATAL_ERROR)

# project name and supported language
project(oligomap LANGUAGES CXX)

# require C++11
set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_EXTENSIONS OFF)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# name of the executable
add_executable(oligomap "")

# its sources
target_sources(oligomap
  PRIVATE
    oligomap.cpp
  )

# install the binary
install(
  TARGETS
    oligomap
  DESTINATION
    bin
  )
