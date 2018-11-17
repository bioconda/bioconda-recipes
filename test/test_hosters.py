import pytest

from bioconda_utils.hosters import (
    GithubRelease,
    GithubTag,
    Bioconductor,
    Bioarchive,
    CargoPort,
    PyPi,
    CPAN,
    CRAN,
    Hoster,
    HosterMeta
)

CASES = {
    GithubRelease: (
        ("https://github.com/epruesse/SINA/releases/download/v1.2.0/sina-1.2.0.tar.gz", "1.2.0"),
    ),
    GithubTag: (
        ("https://github.com/epruesse/SINA/archive/v1.2.0.tar.gz", "1.2.0"),
    ),
    Bioconductor: (
        ("http://bioconductor.org/packages/3.7/bioc/src/contrib/a4base_1.28.0.tar.gz", "1.28.0"),
    ),
    Bioarchive: (
        ("https://bioarchive.galaxyproject.org/a4base_1.28.0.tar.gz", "1.28.0"),
    ),
    CargoPort: (
        ("https://depot.galaxyproject.org/software/"
         "bioconductor-a4base/bioconductor-a4base_1.28.0_src_all.tar.gz", "1.28.0"),
    ),
    PyPi: {
        ("https://files.pythonhosted.org/packages/e0/15/a57179e855d4185e36bb83e982718260acf1334ac892e856cc18950d368a/anvio-5.2.tar.gz", "5.2"),
        ("https://pypi.io/packages/source/a/abeona/abeona-1.2.3.tar.gz", "1.2.3"),
        ("https://pypi.python.org/packages/33/5d/327aed4a90b315f886bcae96ee85149b275e48061b95a51da5f224841fb9/alignlib-lite-0.3.tar.gz", "0.3"),
    },
    CPAN: {
        ("https://cpan.metacpan.org/authors/id/L/LD/LDS/AcePerl-1.92.tar.gz", "1.92"),
        ("http://www.cpan.org/authors/id/L/LD/LDS/Bio-SamTools-1.43.tar.gz", "1.43"),
        ("http://search.cpan.org/CPAN/authors/id/B/BI/BINGOS/Archive-Tar-2.32.tar.gz", "2.32"),
    },
    CRAN: {
        ("https://cran.r-project.org/src/contrib/asics_1.0.1.tar.gz", "1.0.1"),
        ("https://cran.r-project.org/src/contrib/Archive/asics/asics_1.0.1.tar.gz", "1.0.1"),
    },
}

@pytest.fixture()
def test_urls(hoster):
    if hoster not in CASES:
        return None
    return [(n, url, vers) for n, (url, vers) in enumerate(CASES[hoster])]

@pytest.mark.parametrize('hoster', HosterMeta.hoster_types)
def test_hoster_s(hoster, test_urls):
    assert test_urls, f"Missing test cases for {hoster.__name__}"
    for num, url, version in test_urls:
        msg = f"""
        Hoster:           {hoster.__name__}
        Case:             {num}
        Expected Version: {version}
        test_url:\n{url}
        url_pattern:\n{hoster.url_pattern}
        """
        instance = Hoster.select_hoster(url)
        assert type(instance) == hoster, "Incorrect Hoster selected" + msg
        assert instance.vals['version'] == version, "Incorrect version detected" + msg

