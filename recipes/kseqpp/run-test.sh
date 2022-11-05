#!/usr/bin/env bash
echo -e \
    "cmake_minimum_required(VERSION 3.10)\n" \
    "project(kseq++-test)\n" \
    "find_package(kseq++ REQUIRED)" > CMakeLists.txt
cmake .
