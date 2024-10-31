#!/bin/bash

# Set the main working directory
SRC_DIR="$(pwd)"

# Check if the src folder exists
if [ -d "$SRC_DIR/src" ]; then
    BUILD_DIR="$SRC_DIR/src"
else
    # If no src folder, look for a directory starting with 'AmpliCI'
    AMPLICI_DIR=$(find "$SRC_DIR" -type d -name "amplici*" | head -n 1)
    
    if [ -z "$AMPLICI_DIR" ]; then
        echo "Error: Could not find a directory starting with 'amplici'"
        exit 1
    else
        BUILD_DIR="$AMPLICI_DIR/src"
        if [ ! -d "$BUILD_DIR" ]; then
            echo "Error: 'src' directory not found in $AMPLICI_DIR"
            exit 1
        fi
    fi
fi

# Navigate to the build directory and execute the build commands
cd "$BUILD_DIR" || exit 1
cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=$PREFIX .
make
make install

