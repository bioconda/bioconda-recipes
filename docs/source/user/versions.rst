
Versions Supported in Bioconda
==============================
Bioconda only supports some versions of conda packages.
Here is an incomplete list of the dependencies that might be relevant to your
conda environment.

Operating Systems
-----------------
Bioconda only supports 64-bit Linux and Mac OS

Python
------
Bioconda only supports python 2.7, 3.6 and 3.7. The community is currently working on adding support for
python 3.8.

(The exception to this is Bioconda packages which declare `noarch: python` and only depend on
such packages - those packages can be installed in an environment with any version of python
they say they can support.
However many python packages in Bioconda depend on other Bioconda packages with architecture specific
builds, such as `pysam`, and so do not meet this criteria.)

Unsupported versions
--------------------
If the version of a package you wish to use is not supported because it is too old, please upgrade to a newer
version so that you can use Bioconda.

If the version you wish to use is not supported because it is too new:

* If it is a small piece of software, please consider
  :doc:`contributing it to Bioconda <../contributor/index>`
* If it is a large piece of software (like the python language) ask about
  feasibility, timelines, and how you can help on the
  `Bioconda gitter <https://gitter.im/bioconda/Lobby>`_

