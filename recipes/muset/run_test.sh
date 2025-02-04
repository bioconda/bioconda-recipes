#!/bin/bash
set -e

# Check binary
echo "Checking muset binary:"
muset_path=$(command -v muset)
if [ -z "$muset_path" ]; then
    echo "muset binary not found"
    exit 1
fi

# Verify binary is executable
if [ ! -x "$muset_path" ]; then
    echo "muset binary is not executable"
    exit 1
fi

# Run version check
echo "Checking version:"
muset_version=$(muset --version)
if [ -z "$muset_version" ]; then
    echo "Could not get version"
    exit 1
fi

# Run help check
echo "Checking help:"
muset_help=$(muset --help)
if [ -z "$muset_help" ]; then
    echo "Could not get help"
    exit 1
fi

echo "All checks passed!"
exit 0