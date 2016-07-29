#!/bin/bash
if ! [ -x "$(command -v stack)" ]; then
	echo "Stack not available, attempting install"
	echo "Setting PATH"
        pwd
	cp stack ${PREFIX}
	export PATH=${PREFIX}:$PATH
	chmod 755 $PREFIX/stack
else
	echo "Stack available"
fi
