import errno

# check simply importing works
import pysam

# check remote access capabilities are present
try:
    pysam.AlignmentFile('s3:expect_invalid_argument')
except EnvironmentError as e:
    # EPROTONOSUPPORT (Protocol not supported) would indicate no S3 capabilities
    assert e.errno == errno.EINVAL
