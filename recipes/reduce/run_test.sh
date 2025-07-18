#!/bin/bash

set -exo pipefail

reduce -NOFLIP -Quiet 3QUG.pdb > 3QUG_H.pdb
grep -q "24.632 -16.277 -11.360  1.00 25.56           H   new" 3QUG_H.pdb
