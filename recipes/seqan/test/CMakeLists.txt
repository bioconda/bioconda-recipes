cmake_minimum_required (VERSION 3.12)
project (seqan_package_test CXX)

find_package (SeqAn REQUIRED)

add_executable (seqan_package_test seqan_package_test.cpp)
target_link_libraries (seqan_package_test seqan::seqan2)
