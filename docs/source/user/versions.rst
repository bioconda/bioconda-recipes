
Versions Supported in Bioconda
==============================
The Bioconda build system only supports some versions of common software dependencies.
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
If there is a version of a dependency you wish to build against that Bioconda does not currently support,
please reach out to the `Bioconda Gitter <https://gitter.im/bioconda/Lobby>`_ for more information
about if supporting that version is feasible, if work on that is already being done, and how you
can help.
