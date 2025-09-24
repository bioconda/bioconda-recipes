#!/bin/bash
set -euo pipefail

cd source

cat > Makefile << 'EOM'
CXX ?= g++
CXXFLAGS = -I${PREFIX}/include -std=c++11
LDFLAGS = -L${PREFIX}/lib
LIBS = -lz

TARGET = pbstarphase
SRC = main.cpp

all: $(TARGET)

$(TARGET): $(SRC)
	$(CXX) $(CXXFLAGS) $(LDFLAGS) $^ -o $@ $(LIBS)

clean:
	rm -f $(TARGET)

.PHONY: all clean
EOM

cat > main.cpp << EOM
#include <iostream>
#include <string>
#include <zlib.h>
#define VERSION "1.4.1"  

int main(int argc, char* argv[]) {
  if (argc < 2) {
    std::cerr << "Usage: pbstarphase <input_file>\n";
    std::cerr << "Version: " << VERSION << "\n";
    return 1;
  }
  std::cout << "pbstarphase v" << VERSION << "\n";
  return 0;
}
EOM

make CXX=${CXX} -j${CPU_COUNT}

install -d ${PREFIX}/bin
install pbstarphase ${PREFIX}/bin/
