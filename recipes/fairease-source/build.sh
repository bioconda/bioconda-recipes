#!/bin/bash -e

$PYTHON -m pip install --no-deps --no-build-isolation . -vvv

# Copy/link executables somewhere on the path
python_path=$(find $PREFIX -name SOURCE)
for file in $(find $python_path -name "*.py" | grep -v "__"); do
    echo python3 $PREFIX/lib/python3\*/site-packages/SOURCE/$(echo $file | awk -F 'SOURCE/' '{print $2}') '"$@"' > $PREFIX/bin/$(basename $file)
    chmod +x $PREFIX/bin/$(basename $file)
done

