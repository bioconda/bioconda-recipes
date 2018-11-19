import os.path as op

import pytest
import yaml

from bioconda_utils.hosters import Hoster, HosterMeta


with open(op.join(op.dirname(__file__), "hoster_cases.yaml")) as data:
    TEST_CASES = yaml.load(data)


TEST_CASE_LIST = [
    (hoster, num, case)
    for hoster in TEST_CASES
    for num, case in enumerate(TEST_CASES[hoster])
]


TEST_CASE_IDS = [
    f"{x[0]}-{x[1]+1}{'-'+x[2]['case'] if 'case' in x[2] else ''}"
    for x in TEST_CASE_LIST
]


@pytest.mark.parametrize('hoster', HosterMeta.hoster_types)
def test_hoster_has_test_case(hoster):
    assert hoster.__name__ in TEST_CASES, f"Missing test cases for {hoster.__name__}"


@pytest.fixture(scope="class")
def setup_params(request):
    request.cls.setup_params(*request.param)


@pytest.mark.usefixtures('setup_params')
@pytest.mark.parametrize('setup_params', TEST_CASE_LIST, ids=TEST_CASE_IDS, indirect=True)
@pytest.mark.successive  # custom, see conftest.py
class TestHoster:
    @classmethod
    def msg(cls, title):
        res = f"""{title} ({cls.hoster}-{cls.caseno})
        Expected Version: {cls.case['version']}
        test_url:\n{cls.case['url']}
        url_pattern:\n{getattr(cls.instance, 'url_pattern','N/A')}
        """
        return res

    @classmethod
    def setup_params(cls, hoster, caseno, case):
        cls.hoster = hoster
        cls.case = case
        cls.caseno = caseno
        try:
            cls.instance = Hoster.select_hoster(case['url'])
        except Exception:
            print(cls.msg(""))
            raise

    def test_select(self):
        assert self.instance, \
            self.msg("No Hoster found")
        assert self.instance.__class__.__name__ == self.hoster, \
            self.msg("Incorrect Hoster selected")

    def test_version(self):
        assert self.instance.vals['version'] == self.case['version'], \
            self.msg("Incorrect version detected")

    def test_releaseurl(self):
        assert 'release_url' in self.case, \
            self.msg("Missing release_url")
        assert self.instance.releases_url == self.case['release_url'], \
            self.msg("Wrong release url")

