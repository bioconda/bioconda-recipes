Troubleshooting
---------------

.. highlight:: bash

.. contents::
   :local:


.. _reading-logs:

Reading bioconda-utils logs
~~~~~~~~~~~~~~~~~~~~~~~~~~~
For failed recipes, usually the easiest thing to do is find the first ``BIOCONDA
ERROR``, and start reading the output below that line. The stdout and stderr for
that failed build will end with the next ``BIOCONDA`` log line, likely
a ``BIOCONDA BUILD START`` or ``BIOCONDA BUILD SUMMARY`` line.
Note that there are two tests: the tests performed by conda in the main
environment, and if they pass, the mulled-build tests performed in a minimal
docker container. For working with failures in mulled-build tests, see
:ref:`mulled-build-troubleshooting`.



HTTP 500 errors
~~~~~~~~~~~~~~~

Sometimes recipes fail for reasons outside our control. For example,
if anaconda.org returns an HTTP 500 error, that has nothing to do with
the recipe but with anaconda.org's servers. In this case, you can
restart the build by posting a comment with the line::

  @BiocondaBot rebuild

This will retrigger the build for the latest commit made to the PR in
which the comment was made.


HTTP 404 errors
~~~~~~~~~~~~~~~

HTTP 404 errors can happen if a url used for a recipe was not
stable. In this case the solution is to track down a stable URL. For
example this problem happened frequently with Bioconductor recipes
that were up-to-date as of the current Bioconductor release, but when
a new Bioconductor version came out the links would not work.

The solution to this is the `Cargo Port
<https://depot.galaxyproject.org/software/>`_, developed and
maintained by the `Galaxy <https://galaxyproject.org/>`_ team. The
Galaxy Jenkins server performs daily archives of the source code of
packages in ``bioconda``, and makes these tarballs permanently
available in Cargo Port. If you try rebuilding a recipe and the source
seems to have disappeared, do the following:

- search for the package and version at https://depot.galaxyproject.org/software/

- add the URL listed in the "Package Version" column to your ``meta.yaml``
  file as another entry in the ``source: url`` section.

- add the corresponding sha256 checksum displayed upon clicking the Info icon
  in the "Help" column to the ``source:`` section.

For example, if this stopped working:

.. code:: yaml

    source:
      fn: argh-0.26.1.tar.gz
      url: https://pypi.python.org/packages/source/a/argh/argh-0.26.1.tar.gz
      md5: 5a97ce2ae74bbe3b63194906213f1184

then change it to this:

.. code:: yaml

    source:
      fn: argh-0.26.1.tar.gz
      url:
        - https://pypi.python.org/packages/source/a/argh/argh-0.26.1.tar.gz
        - https://depot.galaxyproject.org/software/argh/argh_0.26.1_src_all.tar.gz
      md5: 5a97ce2ae74bbe3b63194906213f1184
      sha256: 06a7442cb9130fb8806fe336000fcf20edf1f2f8ad205e7b62cec118505510db


.. _zlib:

ZLIB errors
~~~~~~~~~~~

When building the package, you may get an error saying that zlib.h
can't be found -- despite having zlib listed in the dependencies. The
reason is that the location of :conda:package:`zlib` often has to be
specified in the ``build.sh`` script, which can be done like this:

.. code:: bash

    export CFLAGS="$CFLAGS -I$PREFIX/include"
    export LDFLAGS="$LDFLAGS -L$PREFIX/lib"

Or sometimes:

.. code:: bash

    export CPATH=${PREFIX}/include

Sometimes Makefiles may specify these locations, in which case they
need to be edited. See the `samtools` recipe for an example of
this. It may take some tinkering to get the recipe to build; if it
doesn't seem to work then please submit an issue or notify
``@bioconda/core`` for advice.


.. _perl-or-python-not-found:

``/usr/bin/perl`` or ``/usr/bin/python`` not found
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Often a tool hard-codes the shebang line as, e.g., ``/usr/bin/perl``
rather than the more portable ``/usr/bin/env perl``. To fix this, use
``sed`` in the build script to edit the lines.

Here is an example that will replace the first line of a file
``$PREFIX/bin/alocal`` with the proper shebang line ::

    sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' $PREFIX/bin/aclocal

(note the ``-i.bak``, which is needed to support both Linux and OSX
versions of ``sed``).

It turns out that the version of `autoconf` that is packaged in the
defaults channel still uses the hard-coded Perl. So if a tool uses
`autoconf` for building, it is likely you will see this error and it
will need some ``sed`` commands. See `recipes/exparna/build.sh`_ for
an example to work from.

.. _`recipes/exparna/build.sh`: https://github.com/bioconda/bioconda-recipes/blob/4bc02d7b4d784c923481d8808ed83e048c01d3bb/recipes/exparna/build.sh


.. _mulled-build-troubleshooting:

Troubleshooting failed ``mulled-build`` tests
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

After conda sucessfully builds and tests a package, we then perform a
more stringent test in a minimal Docker container using
``mulled-build``. Notably, this container does not have conda and has
very few libraries. So this test can catch issues that the default
conda test cannot. However the extra layer of abstraction makes it
difficult to troubleshoot problems with the recipe. If the conda-build
test works but the mulled-build test fails try these steps:

- Run the test using the ``bootstrap.py`` method described in
  :doc:`building-locally`.
- Look carefully at the output from ``mulled-build`` to look for
  Docker hashes, and cross-reference with the output of ``docker
  images | head`` to figure out the hash of the container used.
- Start up an interactive docker container, ``docker run -it
  $hash``. You can now try running the tests in the recipe that
  failed, or otherwise poke around in the running container to see
  what the problem was.


Using the extended image
~~~~~~~~~~~~~~~~~~~~~~~~

For the vast majority of recipes, we use a minimal BusyBox container
for testing and to upload to quay.io. This allows us to greatly reduce
the size of images, but there are some packages that are not
compatible with the minimal container. To support these cases, we
offer the ability to in special cases use an "extended base"
container. This container is maintained at
https://github.com/bioconda/bioconda-extended-base-image and is
automatically built by DockerHub when Dockerfile is updated in the
GitHub repo.

Please note that **this is not a general solution to packaging
issues**, and should only be used as a last resort. Cases where the
extended base has been needed are:

- Unicode support is required (especially if a package uses the
  ``click`` Python package under Python 3; see for example comments in
  `PR #5541`_ and `PR #6094`_).
- ``libGL.so.1`` dependency
- ``openssl`` dependency, e.g., through ``openmpi``

.. _`PR #5541`: https://github.com/bioconda/bioconda-recipes/pull/5541#issuecomment-323755800
.. _`PR #6094`: https://github.com/bioconda/bioconda-recipes/pull/6094#issuecomment-332272936

To use the extended container, add the following to a recipe's ``meta.yaml``:

.. code:: yaml

    extra:
      container:
        extended-base: True


``g++`` or ``gcc`` not found
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The new conda build system brings its own compilers and system
libraries. The specific compiler may vary between the target
platforms, e.g. we use ``clang`` on MacOS and ``gcc`` on Linux. The name
and path to the right compiler is therefore exported via environment
variables. Just use ``$CC`` or ``$CXX`` instead of ``gcc`` or ``g++``.

While some software, e.g. those built with ``autotools``, will pick up
on this automatically, a lot of software has hard-coded compiler names
in its ``Makefile``\s.

Instead of using patches or ``sed`` to modify those Makefiles, you can
often simply override Make variables from the command line::

  make CC=$CC

Briefly, Makefile variables can be specified inside the Makefile with
the following operators:

.. code:: Make

  VAR1 = content   # assign with late recursive expand
  VAR2 := content  # assign fixed
  VAR3 ?= content  # assign default
  VAR4 += content  # append

All of these variables can be "overridden" from the command line as
shown above. The final value no matter how many ``+=`` or similar
operations are given inside the Makefile will be exactly what you
stated on the command line. Only if the variable assignment is
prefixed with the ``override`` keyword will Make ignore what you add
to the command line.

Variables that are never "set", so those only modified with ``?=``
(set if not already set) or ``+=`` (append) most likely will work just
as expected.

Example:

.. code:: Make

  CC = g++
  CFLAGS = -O2 -g -DVERSION=1.2.3
  LDFLAGS += -lz

- This Makefile sets ``CC`` to ``g++`` which you can simply
  override::

    make CC=$CC
 
- Since it *adds* ``-lz`` to ``LDFLAGS`` to enable linking against
  ``libz``, you do not need to do anything here.

- The ``CFLAGS`` are more complicated. You can patch the
  Makefile to append to ``CFLAGS`` instead of overwriting::

    sed -i.bak 's/CFLAGS =/CFLAGS +=/' Makefile

  Or you could override::

    make CC=$CC CFLAGS="$CFLAGS -DVERSION=1.2.3"

  In this case, the latter is not recommended as we would expect the
  version number to change with every new release of the upstream
  software.



