#!/bin/bash
if ! [ -x "$(command -v stack)" ]; then
	curl -sSL https://get.haskellstack.org/ | sh
        export PATH=/root/.local/bin:/usr/local/bin/:$PATH
        chmod 755 /root/.local/bin/stack
else
	echo "Stack available"
fi
stack setup
stack build
