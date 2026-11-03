#!/bin/bash
set -eux -o pipefail

# Respect Conda compiler/linker flags and link zlib from the host environment.
sed -i.bak 's/^CC = g++/CXX ?= g++/' Makefile
sed -i.bak 's/^DEBUGFLAGS = -Wno-deprecated -O1 -lz/DEBUGFLAGS ?= -Wno-deprecated -O1/' Makefile
sed -i.bak 's/^	g++ /	$(CXX) $(CXXFLAGS) $(CPPFLAGS) /' Makefile
sed -i.bak 's/ $(DEBUGFLAGS) -o MR-MEGA/ $(DEBUGFLAGS) $(LDFLAGS) -o MR-MEGA -lz/' Makefile

make

mkdir -p "${PREFIX}/bin"
install -m 775 MR-MEGA "${PREFIX}/bin/"
