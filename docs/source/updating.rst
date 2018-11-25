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

By default, subrecipes (e.g., packagename/meta.yaml is the main recipe, and
packagename/0.5/meta.yaml is a subrecipe) will be ignored for updating unless
they specifically have the following in their `extra` block:

.. code-block:: yaml

    extra:
      watch:
        enable: yes


How it works
------------

This section describes the system in more detail for developers looking to
expand the functionality of the update scanner or anyone interested in the
inner workings.

The components
~~~~~~~~~~~~~~

When you run `bioconda-utils update`, it sets up a `Scanner`, adds filters to
the scanner (which do many wonderful things), and runs the filters in an
asyncio loop to dramatically speed up anything depending on external http
servers.

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

Subclasses of `bioconda_utils.update.Filter` contain logic in their `apply`
method, which at least takes a recipe as the first argument, to either return
a (possibly modified) recipe or raise a custom exception. The remainder of the
`apply` function can do arbitrarily complicated things, and will do so in the
asyncio loop.

Subclasses of `bioconda_utils.hosters.Hoster` use regular expressions to detect
which recipes came from which site and how to find links to new source code
from that site. There are existing hosters for e.g. GitHub, PyPI, CRAN, CPAN,
Bioconductor, and more.

Writing a filter
~~~~~~~~~~~~~~~~
To add additional functionality to the scanner, create a filter and add it to
the scanner in `bioconda_utils.cli.update()`. There are existing filters to
exclude recipes based on blacklist or subrecipe status, update a recipe based on
the latest version found by a `Hoster` (see below), update checksums, figure out
where to load a recipe from (i.e. master branch or an existing PR), create a new
PR, and more.

See the `bioconda_utils.update` source for examples when writing a new filter.


Writing a new hoster
~~~~~~~~~~~~~~~~~~~~
A `Hoster` is a mechanism for scraping links of new releases off of a site and
is the means by which we detect new releases. It works primarily by regular
expressions.

A hoster is a subclass of `bioconda_utils.hosters.Hoster` and is defined by
adding a regex to match the existing source URL, a format string that creates
the URL of the releases page, and a regex to match links from that page and
extract their version.

If you want a recipe to be updated automatically (and existing hosters aren't
cutting it), write a new `Hoster` class in `bioconda_utils.hosters`. Any new
classes will automatically be picked up by the `HosterMeta` metaclass and will
be used to scan against existing recipes.

Adding an attribute to the class with the suffix  ``_pattern`` allows the
regular expression to be subsituted into other regular expressions. Any
placeholders in those patterns can 

Take, for example, the `Bioconductor` hoster which is commented here for
explanation purposes:

.. code-block:: python

    class Bioconductor(HTMLHoster):
        """Matches R packages hosted at Bioconductor"""

        # This will be filled into the `url_pattern` below at the {link}
        # placeholder and will also be used to search for links within the page
        # defined below for `releases_format`.
        #
        # The `version` and `ext` placeholders regexps are defined in the Hoster
        # parent class -- basically, anything that looks reasonably like
        # a version number will match for `version` and any of the extensions
        # supported by conda will match for `ext`. See the source in
        # bioconda_utils.hosters.Hoster for details.
        link_pattern = r"/src/contrib/(?P<package>[^/]+)_{version}{ext}"

        # Bioconductor packages are stored at different locations on the
        # Bioconductor site depending on if they're a code package or a data
        # package (annotation or experiment). This will match any of them, and
        # will be filled in to the `url_pattern` below at the {section}
        # placeholder.
        section_pattern = r"/(bioc|data/annotation|data/experiment)"

        # This is the pattern that will be used to see if a recipe's source
        # URLs match an expected Bioconductor URL. `section` and `link` are
        # filled in from above (and `link` was in turn filled in recursively from
        # `version` and `ext`)
        url_pattern = r"bioconductor.org/packages/(?P<bioc>[\d\.]+){section}{link}"

        # This is the HTML page containing releases. It will be filled in with
        # any other placeholders and then it will be scraped for links that
        # match `link_pattern`
        releases_format = "https://bioconductor.org/packages/{bioc}/bioc/html/{package}.html"

To tie this all together:

- The `UpdateVersion` filter checks a recipe against all available hosters.
- The scanner checks all recipes, and because it has the `UpdateVersion`
  filter added, a Bioconductor recipe will match the above `url_pattern`.
- The hoster will go to the site specified by `releases_format` and look for
  links that match `link_pattern` from that site.
- The `UpdateVersion` filter will inspect those identified links, figure out
  which is the most recent, and see if the existing recipe is up-to-date. If
  a more recent link was found, use that (along with the hoster-identified
  version from the link patterns) and write the new recipe.
- The scanner also has the `UpdateChecksums` filter added, but it is added
  after `UpdateVersion`. This filter will inspect the package, download it, and
  update the checksum in the recipe.

From there, depending on the command-line argument provided, the scanner can
create a new branch and push a new pull request to GitHub for testing.
