#!/bin/bash
set -x  # Enable debug mode to see each command

# Redirect outputs to files for detailed investigation
muset --help > help_output.txt 2> help_error.txt
help_exit_code=$?

# Print detailed diagnostic information
echo "Help command exit code: $help_exit_code"
echo "Standard output:"
cat help_output.txt
echo "Error output:"
cat help_error.txt

# Check file contents and permissions
echo "Binary details:"
which muset
ls -l $(which muset)
file $(which muset)

# Try running with different methods
echo "Version check methods:"
muset --version
/bin/bash -c "muset --version"
/bin/sh -c "muset --version"

# Explicitly exit with the help command's exit code
exit $help_exit_code