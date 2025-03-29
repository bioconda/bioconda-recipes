#!/bin/bash

# Create temporary files
mkdir -p temp
cat > temp/original.cpp << 'EOF'
#include <algorithm>
#include <cctype>
#include <unordered_set>
#include <fstream>
#include <iostream>
#include <sstream>
EOF

cat > temp/fixed.cpp << 'EOF'
#include <algorithm>
#include <cctype>
#include <unordered_set>
#include <unordered_map>
#include <fstream>
#include <iostream>
#include <sstream>
EOF

# Generate the patch file
diff -u temp/original.cpp temp/fixed.cpp > patches/fix-unordered-map-include.patch

# Clean up
rm -rf temp 