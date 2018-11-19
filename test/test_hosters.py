import os.path as op

import pytest
import yaml

from bioconda_utils.hosters import Hoster, HosterMeta

with open(op.join(op.dirname(__file__), "hoster_cases.yaml")) as data:
    TEST_CASES = yaml.load(data)


@pytest.mark.parametrize('hoster', HosterMeta.hoster_types)
def test_hoster_has_test_case(hoster):
    assert hoster.__name__ in TEST_CASES, f"Missing test cases for {hoster.__name__}"


@pytest.mark.parametrize(
    argnames='hoster,case',
    argvalues=[
        (hoster, case) for hoster in TEST_CASES for case in TEST_CASES[hoster]
    ],
    ids=[
        f"{hoster}-{caseno+1}{'-'+case['case'] if 'case' in case else ''}"
        for hoster in TEST_CASES for caseno, case in enumerate(TEST_CASES[hoster])
    ],
    scope="class"  # run methods grouped by argument set
)
@pytest.mark.successive  # custom, see conftest.py
class TestHoster:
    @staticmethod
    def msg(hoster, case, title):
        res = f"""{title}
        Hoster:           {hoster}
        Expected Version: {case['version']}
        test_url:\n{case['url']}
        url_pattern:\n{hoster.url_pattern}
        """
        return res

    def test_select(self, hoster, case):
        try:
            instance = Hoster.select_hoster(case['url'])
        except Exception:
            print(self.msg(hoster, case, ""))
            raise
        assert instance, self.msg(hoster, case, "No Hoster found")
        assert instance.__class__.__name__ == hoster, \
            self.msg("Incorrect Hoster selected")

    def test_version(self, hoster, case):
        instance = Hoster.select_hoster(case['url'])
        assert instance.vals['version'] == case['version'], \
            self.msg(hoster, case, "Incorrect version detected")

    def test_releaseurl(self, hoster, case):
        instance = Hoster.select_hoster(case['url'])
        if 'release_url' not in case:
            pytest.xfail("Missing 'release_url' for test case")
        assert instance.releases_url == case['release_url'], \
            self.msg(hoster, case, "Wrong release url computed")

