#!/bin/bash
set -vxeu -o pipefail

chmod a+rx bin/falconc
#bin/falconc version
cp -r bin/falconc ${PREFIX}/bin/
