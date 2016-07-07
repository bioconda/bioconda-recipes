from distutils.core import setup, Extension
import glob

source_pattern = "include/%s.c"


cutils = Extension(
        "kmergenie.cutils",
        glob.glob('include/*.cpp')
)

setup(name='kmergenie',
      version='1.7016',
      py_modules=['third_party'],
      scripts=glob.glob('scripts/*'),
      ext_modules=[cutils],
      )


# -rw-r--r-- 1 jillian jillian 2.2K Jul  6 12:57 cutoff.r
# -rwxr-xr-x 1 jillian jillian 5.7K Jul  6 12:57 decide
# -rw-r--r-- 1 jillian jillian 3.2K Jul  6 12:57 est-genomic-kmers.r
# -rw-r--r-- 1 jillian jillian  669 Jul  6 12:57 est-mean.r
# -rw-r--r-- 1 jillian jillian 4.2K Jul  6 12:57 est-params.r
# -rw-r--r-- 1 jillian jillian 5.6K Jul  6 12:57 fit-histogram.r
# -rw-r--r-- 1 jillian jillian 233K Jul  6 12:57 generate_report.py
# -rw-r--r-- 1 jillian jillian 233K Jul  6 12:57 generate_report.pyc
# -rw-r--r-- 1 jillian jillian 2.5K Jul  6 12:57 model-diploid.r
# -rw-r--r-- 1 jillian jillian 3.8K Jul  6 12:57 model.r
# -rwxr-xr-x 1 jillian jillian  917 Jul  6 12:57 plot_genomic_kmers.r
# -rwxr-xr-x 1 jillian jillian 4.0K Jul  6 12:57 plot_histogram.r
# -rwxr-xr-x 1 jillian jillian 2.1K Jul  6 12:57 test_install
# -rw-r--r-- 1 jillian jillian  497 Jul  6 12:57 zeta.r
