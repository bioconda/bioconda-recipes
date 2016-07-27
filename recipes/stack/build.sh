#!/bin/bash
if ! [ -x "$(command -v stack)" ]; then
        echo "Stack not available, attempting install"
	echo "Setting PATH"
	cp stack/stack ${PREFIX}/bin
        export PATH=${PREFIX}/bin:$PATH
        chmod 755 $PREFIX/stack.
else
	echo "Stack available"
fi
