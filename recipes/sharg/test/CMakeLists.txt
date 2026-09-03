cmake_minimum_required(VERSION 3.16)

project(sharg_package_test CXX)

find_package (sharg REQUIRED)
add_executable (sharg_package_test sharg_package_test.cpp)
target_link_libraries (sharg_package_test sharg::sharg)
