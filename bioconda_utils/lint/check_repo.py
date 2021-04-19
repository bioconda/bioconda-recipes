"""Repository checks

These checks verify consistency with the repository (blacklisting,
other channels, existing versions).
"""

from .. import utils
from . import LintCheck, ERROR, WARNING, INFO

class in_other_channels(LintCheck):
    """A package of the same name already exists in another channel

    Bioconda and Conda-Forge occupy the same name space and have
    agreed not to add packages if a package of the same name is
    already present in the respective other channel.

    If this is a new package, pease choose a different name
    (e.g. append ``-bio``).

    If you are updating a package, please continue in the package's
    new home at conda-forge.

    """
    def check_recipe(self, recipe):
        channels = utils.RepoData().get_package_data(key="channel", name=recipe.name)
        if set(channels) - set(('bioconda',)):
            self.message(section='package/name')


class build_number_needs_bump(LintCheck):
    """The recipe build number should be incremented

    A package with the same name and version and a build number at
    least as high as specified in the recipe already exists in the
    channel. Please increase the build number.

    """
    def check_recipe(self, recipe):
        bldnos = utils.RepoData().get_package_data(
            key="build_number",
            name=recipe.name, version=recipe.version)
        if bldnos and recipe.build_number <= max(bldnos):
            self.message('build/number', data=max(bldnos))

    def fix(self, _message, data):
        self.recipe.reset_buildnumber(data + 1)
        return True


class build_number_needs_reset(LintCheck):
    """The recipe build number should be reset to 0

    No previous build of a package of this name and this version exists,
    the build number should therefore be 0.
    """
    requires = ['missing_build_number']
    def check_recipe(self, recipe):
        bldnos = utils.RepoData().get_package_data(
            key="build_number",
            name=recipe.name, version=recipe.version)
        if not bldnos and recipe.build_number > 0:
            self.message('build/number', data=0)

    def fix(self, _message, data):
        self.recipe.reset_buildnumber(data)
        return True


class recipe_is_blacklisted(LintCheck):
    """The recipe is currently blacklisted and will not be built.

    If you are intending to repair this recipe, remove it from
    the build fail blacklist.
    """
    def __init__(self, linter):
        super().__init__(linter)
        self.blacklist = linter.get_blacklist()
        self.blacklists = linter.config.get('blacklists')

    def check_recipe(self, recipe):
        if recipe.name in self.blacklist:
            self.message(section='package/name', data=True)

    def fix(self, _message, _data):
        for blacklist in self.blacklists:
            with open(blacklist, 'r') as fdes:
                data = fdes.readlines()
            for num, line in enumerate(data):
                if self.recipe.name in line:
                    break
            else:
                continue
            del data[num]
            with open(blacklist, 'w') as fdes:
                fdes.write(''.join(data))
            break
        else:
            return False
        return True
