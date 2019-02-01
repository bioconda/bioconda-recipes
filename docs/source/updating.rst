.. _updating:

Updating recipes
================
`bioconda-utils` now has the ability to automatically update packages and
submit a PR on your behalf. Note that the auto-updater does not yet know how to
monitor changed dependencies, so it is important to verify that the updated
recipe reflects all the changes. This tool is most useful when scanning
packages to know when something has been updated.

.. code-block:: bash

    bioconda-utils update recipes/ config.yml --packages <my-package-name>

will update the package's recipe which you can then inspect. If you have
a `GitHub personal access token
<https://help.github.com/articles/creating-a-personal-access-token-for-the-command-line/>`_
set as the environment variable ``GITHUB_TOKEN``, the following command will
additionally submit a pull request on your behalf:

.. code-block:: bash

    bioconda-utils update recipes/ config.yml \
      --packages <my-package-name> \
      --create-pr

By default, subrecipes  will be ignored for updating unless
they specifically have the following in their `extra` block:

.. code-block:: yaml

    extra:
      watch:
        enable: yes

E.g., `packagename/meta.yaml` is the main recipe, and
`packagename/0.5/meta.yaml` is a subrecipe. So `packagename/0.5/meta.yaml`
needs the above `extra` block if it should ever be automatically updated.


How it works
------------

This section describes the system in more detail for developers looking to
expand the functionality of the update scanner or anyone interested in the
inner workings.

The components
~~~~~~~~~~~~~~

The `bioconda_utils.update.Recipe` object contains logic for finding and
replacing text that may contain version information (such as within ``package:``
and ``source:`` sections or Jinja set statements), for resetting build numbers,
and for reading and writing recipes. Notably, reading and writing recipes here
does not rely on conda-build as we need to do things conda-build was not
designed for.

The `bioconda_utils.update.Scanner` class reads recipes and applies various
filters (described below) in an asyncio loop to dramatically speed up the many
http calls that are performed over the course of scanning for updates. It also
handles other things like retrying after increasingly longer wait times when it
encounters non-permanent HTTP errors.

Subclasses of `bioconda_utils.update.Filter` are added to the scanner. They
contain logic in their `apply` method. This method at least takes a recipe as
the first argument, and either returns a (possibly modified) recipe or raises
a custom exception. The remainder of the `apply` function can do arbitrarily
complicated things, and will do so in the asyncio loop.

Subclasses of `bioconda_utils.hosters.Hoster` use regular expressions to detect
which recipes came from which site and how to find links to new source code
from that site. There are existing hosters for e.g. GitHub, PyPI, CRAN, CPAN,
Bioconductor, and more. These are primarily used by the `UpdateVersion` filter.

Writing a filter
~~~~~~~~~~~~~~~~
To add additional functionality to the scanner, create a filter in
`bioconda_utils.update` and add it to the scanner in
`bioconda_utils.cli.update()`. There are existing filters to exclude recipes
based on blacklist or subrecipe status, update a recipe based on the latest
version found by a `Hoster` (see below), update checksums, figure out where to
load a recipe from (i.e. master branch or an existing PR), create a new PR, and
more.

Filters can be arbitrarily complex, like any Python function. See the
`bioconda_utils.update` source for examples when writing a new filter --
`ExcludeSubrecipe` is a relatively simple one; `UpdateVersion` is more complex.


Writing a new hoster
~~~~~~~~~~~~~~~~~~~~
A `Hoster` is a mechanism for scraping links of new releases off of a site and
is the means by which we detect new releases. It works primarily by regular
expressions.

A hoster is a subclass of `bioconda_utils.hosters.Hoster` and is configured by

- a regex used to try matching with the existing source URL in the recipe
- a format string that will create the URL of the releases website on which
  possibly many versions may be listed
- a regex to match links from that page and extract their version

If you want a recipe to be updated automatically (and existing hosters aren't
cutting it), write a new `Hoster` class in `bioconda_utils.hosters`. Any new
classes will automatically be picked up by the `HosterMeta` metaclass and will
be used to scan against existing recipes.

Adding an attribute to the class with the suffix  ``_pattern`` allows the
regular expression stored in that attribute to be subsituted into other regular
expressions using `{placeholder}` format placeholders.

Take, for example, the `Bioconductor` hoster which is commented here for
explanation purposes:

.. code-block:: python

    class Bioconductor(HTMLHoster):
        """Matches R packages hosted at Bioconductor"""

        # This link pattern will be filled into the `url_pattern` below at the
        # {link} placeholder. It will also be used to search for links within
        # the HTML page defined below for `releases_format`.
        #
        # The `version` and `ext` placeholders here are regexps defined in the Hoster
        # parent class -- basically, anything that looks reasonably like
        # a version number will match for `version` and any of the extensions
        # supported by conda will match for `ext`. See the source in
        # bioconda_utils.hosters.Hoster for details. Those (quite complex)
        # regexps will be filled in at these placeholders.
        link_pattern = r"/src/contrib/(?P<package>[^/]+)_{version}{ext}"

        # Bioconductor packages are stored at different locations on the
        # Bioconductor site depending on if they're a code package or a data
        # package (annotation or experiment). This will match any of them, and
        # will be filled in to the `url_pattern` below at the {section}
        # placeholder.
        section_pattern = r"/(bioc|data/annotation|data/experiment)"

        # This is the pattern that will be checked against a recipe's source
        # URLs to figure out if the recipe is a Bioconductor package. `section`
        # and `link` are filled in from above (and `link` was in turn filled in
        # recursively from `version` and `ext`)
        url_pattern = r"bioconductor.org/packages/(?P<bioc>[\d\.]+){section}{link}"

        # This is the HTML page containing releases for this package. It will
        # be filled in with # any other placeholders and then it will be
        # scraped for links that match `link_pattern` defined above.
        releases_format = "https://bioconductor.org/packages/{bioc}/bioc/html/{package}.html"

To tie this all together:

- A `Scanner` is set up, the `UpdateVersion` filter is added and the asyncio
  loop starts.
- The scanner checks all recipes. Because it has the `UpdateVersion`
  filter added, and because an `UpdateVersion` filter will check a recipe
  against all configured hosters, a Bioconductor recipe will match the above
  `url_pattern` for the `Bioconductor` hoster.
- The hoster object will go to the site specified by `releases_format` and
  scrape links that match `link_pattern`.
- The `UpdateVersion` filter will inspect those links found by the hoster,
  figure out which is the most recent, and see if the existing recipe is
  up-to-date. If a more recent link was found, use that and write the new
  recipe with the updated version and URL.
- The scanner also has the `UpdateChecksums` filter added, but it is added
  after `UpdateVersion`. This filter will inspect the package, download it, and
  update the checksum in the recipe.

In practice, depending on the command-line argument provided (and therefore
which filters were conditionally added) the scanner will do other things like
exclude recipes, create a new branch or push a new pull request to GitHub for
testing.
