import pytest

from bioconda_utils.hosters import (
    GithubRelease,
    GithubTag,
    GithubReleaseAttachment,
    GithubRepoStore,
    Bioconductor,
    Bioarchive,
    CargoPort,
    PyPi,
    CPAN,
    CRAN,
    Hoster,
    HosterMeta
)

# Urls in test cases are shortened, so don't expect them to actually point to something real
TEST_CASES = {
    GithubRelease: ({
        'case': "normal",
        'url': "https://github.com/epr/SNA/releases/download/v1.2.0/sna-1.2.0.tar.gz",
        'version': "1.2.0",
        'release_url': "https://github.com/epr/SNA/releases",
    }, {
        'case': "jar-file",
        'url': "https://github.com/bpet/sctrrgns/releases/download/v0.2/ScttrRgns-assm-0.2.jar",
        'version': "0.2",
        'release_url': "https://github.com/bpet/sctrrgns/releases",
    }, {
        'case': "dot-in-project-name",
        'url': "https://github.com/cpb/bcb.va/releases/download/v0.2.6/bcb.va-0.2.6-st.jar",
        'version': "0.2.6",
        'release_url': "https://github.com/cpb/bcb.va/releases",
    }, {
        'case': "no-file-extension",  # e.g. direct linux binary
        'url': "https://github.com/bp/duphold/releases/download/v0.0.9/duphold",
        'version': "0.0.9",
        'release_url': "https://github.com/bp/duphold/releases",
    }, {
        'case': "underscore-in-project-name",
        'url': "https://github.com/ag/fx_tkt/releases/download/0.0.14/fx_tkt-0.0.14.tar.bz2",
        'version': "0.0.14",
        'release_url': "https://github.com/ag/fx_tkt/releases",
    }),
    GithubReleaseAttachment: ({
        'url': "https://github.com/arshajii/ema/files/2241867/ema-v0.6.2.tar.gz",
        'version': "0.6.2",
    },),
    GithubTag: ({
        'case': "normal",
        'url': "https://github.com/epruesse/SINA/archive/v1.2.0.tar.gz",
        'version': "1.2.0",
    }, {
        'case': "with-prefix",
        'url': "https://github.com/abaizan/kodoja/archive/kodoja-v0.0.9.tar.gz",
        'version': "0.0.9",
    }, {
        'case': "version-with-underscore",
        'url': "https://github.com/BenLangmead/bowtie/archive/v1.2.2_p1.zip",
        'version': "1.2.2_p1",
    }, {
        'case': "prefix-without-separator",
        'url': "https://github.com/HRGV/phyloFlash/archive/pf3.0b1.tar.gz",
        'version': "3.0b1",
    }),
    GithubRepoStore: ({
        'case': "normal",
        'url': "https://github.com/dkoboldt/varscan/raw/master/VarScan.v2.4.3.jar",
        'version': "2.4.3",
    }, {
        'case': "with-subdir",
        'url': "https://github.com/bgruening/d_store/raw/master/blkbst/blkbst-0.0.1.1.tar.gz",
        'version': "0.0.1.1",
    }, {
        'case': "on-raw-domain",
        'url': "https://raw.githubusercontent.com/sequana/rsc/master/software/shstr-2.6.tar.gz",
        'version': "2.6",
    }, {
        'case': "using-commit-checksum",
        'url': "https://github.com/es/crt/raw/9a5977ff59bbc6319bd4b0fb06ccea414492d064/crt-3.0.jar",
        'version': "3.0",
    }, {
        'case': "blob-with-parameter-raw",
        'url': "https://github.com/BT-Tek/pkgs/blob/master/swlk2/SWlk-2.91.tar.gz?raw",
        'version': "2.91",
#    }, {
#        'case': "trailing-number",
#        'url': "https://github.com/BT-Tek/pkgs/blob/master/swlk2/SWlk2-2.91.tar.gz?raw",
#        'version': "2.91",
#    },{
#        'case': "with-suffix"
#        'url': "https://github.com/BT-Tek/pkgs/blob/master/swlk2/SWlk2-2.91-lin.tar.gz?raw",
#        'version': "2.91",
    }),
    Bioconductor: ({
        'case': "normal",
        'url': "http://bioconductor.org/packages/3.7/bioc/src/contrib/a4base_1.28.0.tar.gz",
        'version': "1.28.0",
    },),
    Bioarchive: ({
        'case': "normal",
        'url': "https://bioarchive.galaxyproject.org/a4base_1.28.0.tar.gz",
        'version': "1.28.0"
    },),
    CargoPort: ({
        'case': "normal",
        'url': "https://depot.galaxyproject.org/software/bctr-a4b/bctr-a4b_1.28.0_src_all.tar.gz",
        'version': "1.28.0",
    },),
    PyPi: ({
        'case': "pythonhosted-sha",
        'url': "https://files.pythonhosted.org/packages/e0/15/a57179e855d4185e36bb83e982718260acf1334ac892e856cc18950d368a/anvio-5.2.tar.gz",
        'version': "5.2",
    }, {
        'case': "pypi-author",
        'url': "https://pypi.io/packages/source/a/abeona/abeona-1.2.3.tar.gz",
        'version': "1.2.3",
    }, {
        'case': "pypi-sha",
        'url': "https://pypi.python.org/packages/33/5d/327aed4a90b315f886bcae96ee85149b275e48061b95a51da5f224841fb9/alignlib-lite-0.3.tar.gz",
        'version': "0.3",
    }),
    CPAN: ({
        'case': "metacpan",
        'url': "https://cpan.metacpan.org/authors/id/L/LD/LDS/AcePerl-1.92.tar.gz",
        'version': "1.92"
    }, {
        'case': "cpan",
        'url': "http://www.cpan.org/authors/id/L/LD/LDS/Bio-SamTools-1.43.tar.gz",
        'version': "1.43"
    }, {
        'case': "search.cpan",
        'url': "http://search.cpan.org/CPAN/authors/id/B/BI/BINGOS/Archive-Tar-2.32.tar.gz",
        'version': "2.32"
    }),
    CRAN: ({
        'case': "normal",
        'url': "https://cran.r-project.org/src/contrib/asics_1.0.1.tar.gz",
        'version': "1.0.1"
    }, {
        'case': "archived",
        'url': "https://cran.r-project.org/src/contrib/Archive/asics/asics_1.0.1.tar.gz",
        'version': "1.0.1"
    }),
}


@pytest.mark.parametrize('hoster', HosterMeta.hoster_types)
def test_hoster_has_test_case(hoster):
    assert hoster in TEST_CASES, f"Missing test cases for {hoster.__name__}"


@pytest.mark.parametrize(
    argnames='hoster,case',
    argvalues=[
        (hoster, case) for hoster in TEST_CASES for case in TEST_CASES[hoster]
    ],
    ids=[
        f"{hoster.__name__}-{caseno+1}{'-'+case['case'] if 'case' in case else ''}"
        for hoster in TEST_CASES for caseno, case in enumerate(TEST_CASES[hoster])
    ],
    scope="class"  # run methods grouped by argument set
)
@pytest.mark.successive  # custom, see conftest.py
class TestHoster:
    @staticmethod
    def msg(hoster, case, title):
        res = f"""{title}
        Hoster:           {hoster.__name__}
        Expected Version: {case['version']}
        test_url:\n{case['url']}
        url_pattern:\n{hoster.url_pattern}
        """
        return res

    def test_select(self, hoster, case):
        try:
            self.instance = Hoster.select_hoster(case['url'])
        except Exception:
            print(self.msg(hoster, case, ""))
            raise
        assert self.instance, self.msg(hoster, case, "No Hoster found")
        assert isinstance(self.instance, hoster), self.msg("Incorrect Hoster selected")

    def test_version(self, hoster, case):
        self.instance = Hoster.select_hoster(case['url'])
        assert self.instance.vals['version'] == case['version'], \
            self.msg(hoster, case, "Incorrect version detected")

    def test_releaseurl(self, hoster, case):
        self.instance = Hoster.select_hoster(case['url'])
        if 'release_url' not in case:
            pytest.xfail("Missing 'release_url' for test case")
        assert self.instance.releases_url == case['release_url'], \
            self.msg(hoster, case, "Wrong release url computed")

