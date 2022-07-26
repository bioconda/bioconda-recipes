#!/bin/bash
cdk-inchi-to-svg 'InChI=1S/C28H24O5/c29-24-6-2-4-21-12-9-18-10-13-22(14-11-18)32-26-17-20(16-25(30)27(26)31)8-7-19-3-1-5-23(15-19)33-28(21)24/h1-6,10-11,13-17,29-31H,7-9,12H2' example.svg
head -n 2 example.svg > test && echo "c12d3b254c66094c61b0c79424bb2c6d1ab97db0f8f218792a5a62d742ea250c  test" | sha256sum --check --status
