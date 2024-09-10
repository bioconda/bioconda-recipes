#!/bin/bash

recipe=recipes/$1/meta.yaml
sed -i -r 's/(.*)number: ([0-9]+)(.*)/echo "\1number: $((\2+1))\3"/ge' $recipe
git diff $recipe
