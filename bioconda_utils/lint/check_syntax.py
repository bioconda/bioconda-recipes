"""Syntax checks

These checks verify syntax (schema), in particular for the ``extra``
section that is otherwise free-form.

"""

from . import LintCheck, ERROR, WARNING, INFO


class extra_identifiers_not_list(LintCheck):
    """The extra/identifiers section must be a list

    Example::

        extra:
           identifiers:
              - doi:123

    """
    def check_recipe(self, recipe):
        identifiers = recipe.get('extra/identifiers', None)
        if identifiers and not isinstance(identifiers, list):
            self.message(section='extra/identifiers')


class extra_identifiers_not_string(LintCheck):
    """Each item in the extra/identifiers section must be a string

    Example::

        extra:
           identifiers:
              - doi:123

    Note that there is no space around the colon

    """
    requires = [extra_identifiers_not_list]

    def check_recipe(self, recipe):
        identifiers = recipe.get('extra/identifiers', [])
        for n, identifier in enumerate(identifiers):
            if not isinstance(identifier, str):
                self.message(section=f'extra/identifiers/{n}')


class extra_identifiers_missing_colon(LintCheck):
    """Each item in the extra/identifiers section must be of form ``type:value``

    Example::

        extra:
           identifiers:
              - doi:123

    """
    requires = [extra_identifiers_not_string]

    def check_recipe(self, recipe):
        identifiers = recipe.get('extra/identifiers', [])
        for n, identifier in enumerate(identifiers):
            if ':' not in identifier:
                self.message(section=f'extra/identifiers/{n}')


class extra_skip_lints_not_list(LintCheck):
    """The extra/skip-lints section must contain a list

    Example::

        extra:
           skip-lints:
              - should_use_compilers

    """
    def check_recipe(self, recipe):
        if not isinstance(recipe.get('extra/skip-lints', []), list):
            self.message(section='extra/skip-lints')

