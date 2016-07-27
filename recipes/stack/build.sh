#!/bin/bash
if ! [ -x "$(command -v stack)" ]; then
        echo "Stack not available, attempting install"
	curl -sSL https://get.haskellstack.org/ | sh
	echo "Setting PATH for $USER"
        export PATH=/$USER/.local/bin:/usr/local/bin/:$PATH
        chmod 755 /$USER/.local/bin/stack
else
	echo "Stack available"
fi
