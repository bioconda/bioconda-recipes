#!/bin/sh

java -version

"$JAVA_HOME/bin/java" -version

sirius --version

sirius -i $RECIPE_DIR/Kaempferol.ms -o test-out sirius

if [ ! -f "test-out/1_Kaempferol_Kaempferol/trees" ]; then
  echo Framgentation tree test failed!
  exit 1
fi
