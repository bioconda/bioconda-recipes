#!/bin/bash
if ! [ -x "$(command -v stack)" ]; then
	wget -qO- https://get.haskellstack.org/ | sh
else
	echo "Stack available"
fi
stack setup
stack build
