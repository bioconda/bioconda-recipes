#!/bin/bash
set -exuo pipefail

echo "#include <sharg/all.hpp>

int main(int argc, char ** argv)
{
    int val{};

    sharg::parser parser{\"Eat-Me-App\", argc, argv};
    parser.add_subsection(\"Eating Numbers\");
    parser.add_option(val, sharg::config{.short_id = 'i', .long_id = \"int\", .description = \"Desc.\"});
    parser.parse();

    return 0;
}" > hello_world.cpp

echo "cmake_minimum_required(VERSION 3.12)
project(sharg_test CXX)
find_package (sharg 1.0 REQUIRED)
add_executable (hello_world hello_world.cpp)
target_link_libraries (hello_world sharg::sharg)" > CMakeLists.txt

cmake .
make
./hello_world -h
