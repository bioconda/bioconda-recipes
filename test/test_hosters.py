import os.path as op

import pytest
import yaml
import json
import asyncio

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


AVAIL_HOSTERS = {
    hoster.__name__: hoster
    for hoster in HosterMeta.hoster_types
}


@pytest.mark.parametrize('hoster', HosterMeta.hoster_types)
def test_hoster_has_test_case(hoster):
    assert hoster.__name__ in TEST_CASES, f"Missing test cases for {hoster.__name__}"


@pytest.fixture
def event_loop():
    loop = asyncio.get_event_loop()
    yield loop


@pytest.fixture(scope="class")
def setup_params(request):
    request.cls.setup_params(*request.param)


@pytest.mark.usefixtures('setup_params')
@pytest.mark.parametrize('setup_params', TEST_CASE_LIST, ids=TEST_CASE_IDS, indirect=True)
@pytest.mark.successive  # custom, see conftest.py
class TestHoster:
    @classmethod
    def msg(cls, title):
        res = (f"{title} ({cls.hoster}-{cls.caseno})\n"
               f"Expected Version: {cls.case['version']}\n"
               f"test_url: {cls.case['url']}\n"
               f"test_url_pattern: {cls.hoster_cls.url_pattern}")
        for attr in dir(cls.instance):
            if any(attr.endswith(x) for x in ("_pattern", "_pattern_compiled", "_format")):
                res += f"{attr}: {getattr(cls.instance, attr)}\n"
        if hasattr(cls.instance, 'vals'):
            res += f"vals: {cls.instance.vals}\n"
        return res

    @classmethod
    def setup_params(cls, hoster, caseno, case):
        cls.hoster = hoster
        cls.hoster_cls = AVAIL_HOSTERS.get(hoster)
        assert cls.hoster_cls, f"No (complete) hoster class '{hoster}' found. {AVAIL_HOSTERS}"
        cls.case = case
        cls.caseno = caseno
        try:
            cls.instance = Hoster.select_hoster(case['url'], case.get('override',{}))
        except Exception:
            print(cls.msg(""))
            raise

    def test_select(self):
        assert self.instance, \
            self.msg("No Hoster found")
        assert isinstance(self.instance, self.hoster_cls), \
            self.msg("Incorrect Hoster selected")

    def test_version(self):
        assert self.instance.vals['version'] == self.case['version'], \
            self.msg("Incorrect version detected")

    def test_releaseurl(self):
        assert 'release_url' in self.case, \
            self.msg("Missing release_url")
        assert self.instance.releases_urls == self.case['release_url'], \
            self.msg("Wrong release url")

    async def get_text_from_url(self, url):
        if 'release_links' in self.case:
            assert 'release_json' not in self.case, \
                "Test case may not contain both release_links and release_json"
            return "\n".join("<a href={}/>".format(url)
                             for url in self.case['release_links'])
        if 'release_json' in self.case:
            return json.dumps(self.case['release_json'])

    async def get_ftp_listing(self, url):
        return self.case['release_links']

    @pytest.mark.asyncio
    def test_get_version(self, event_loop):
        if not 'release_links' in self.case and not 'release_json' in self.case:
            pytest.xfail("No release_links or release_json in test case")

        versions_data = event_loop.run_until_complete(self.instance.get_versions(self))
        versions = [item['version'] for item in versions_data]
        assert sorted(versions) == sorted(self.case['parsed_versions']), \
            self.msg("Incorrect versions found on page")
