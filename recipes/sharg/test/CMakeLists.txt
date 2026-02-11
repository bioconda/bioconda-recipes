cmake_minimum_required(VERSION 3.16)

project(sharg_test_package CXX)

find_package (sharg REQUIRED)
add_executable (sharg_test_package sharg_test_package.cpp)
target_link_libraries (sharg_test_package sharg::sharg)
