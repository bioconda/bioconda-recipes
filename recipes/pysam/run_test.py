import errno

# check simply importing works
import pysam

# check remote access capabilities are present
# EPROTONOSUPPORT (Protocol not supported) indicates no plugin capabilities
url = "https://raw.githubusercontent.com/pysam-developers/pysam/refs/heads/master/tests/pysam_data/ex4.sam"
fp = pysam.AlignmentFile(url)
assert fp.is_open()
