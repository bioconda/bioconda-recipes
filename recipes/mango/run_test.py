# test imports
import modin
import bdgenomics
import bdgenomics.adam
import bdgenomics.mango
import bdgenomics.mango.pileup
# import bdgenomics.mango.io needs modin fix in conda

#####################################################################
# Checks whether pileup widget was correctly
# installed. Requires jupyter to be installed.
#####################################################################
from subprocess import Popen, PIPE
p = Popen(['jupyter','nbextension','list'],stdout=PIPE, stderr=PIPE)
stdout =  p.stdout.read().decode("utf-8").split()
stderr =  p.stderr.read().decode("utf-8").split()

outlines = [k for k in stdout if '\x1b' not in k]
# drop text before widget information
outlines = outlines[outlines.index('section')+1:]

# check if validation passed
assert('pileup/extension' not in stderr)

pileup_idx = outlines.index('pileup/extension')
assert(pileup_idx > 0)

# check if widget is enabled
assert(outlines[pileup_idx+1] == 'enabled')
