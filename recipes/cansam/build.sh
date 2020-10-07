#!/bin/bash

make -e CXXFLAGS+=-I. install prefix="${PREFIX}"
