#!/usr/bin/env sh

sirius --version
echo "before wget"
wget https://bio.informatik.uni-jena.de/wp/wp-content/uploads/2021/10/Kaempferol.ms
echo "before SIRIUS"
sirius -i Kaempferol.ms -o test-out sirius
echo "before output check"
if [ ! -f "test-out/0_Kaempferol_Kaempferol/trees/C15H10O6_[M+H]+.json" ]; then
  echo Framgentation tree test failed!
  exit 1
fi