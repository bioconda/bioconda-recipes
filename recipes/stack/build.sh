#!/bin/bash
if ! [ -x "$(command -v stack)" ]; then
	echo "Stack not available, attempting install"
	mv stack ${PREFIX}/bin
	chmod 755 $PREFIX/bin/stack
else
	echo "Stack available"
fi
