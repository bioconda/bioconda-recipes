import contextlib
import datetime

import pandas as pd
import pytest

from bioconda_utils import utils


def pytest_runtest_makereport(item, call):
    if "successive" in item.keywords:
        # if we failed, mark parent with callspec id (name from test args)
        if call.excinfo is not None:
            item.parent.failedcallspec = item.callspec.id


def pytest_runtest_setup(item):
    if "successive" in item.keywords:
        if getattr(item.parent, "failedcallspec", None) == item.callspec.id:
            pytest.xfail("preceding test failed")


@pytest.fixture
def mock_repodata(repodata_yaml):
    """Pepares RepoData singleton to contain mock data"""
    repodata = utils.RepoData()
    orig_data = repodata._df, repodata._df_ts

    df = pd.DataFrame(columns = repodata.columns)
    for channel, packages in repodata_yaml.items():
        for name, versions in packages.items():
            for item in versions:
                data = {
                    'channel': channel,
                    'name': name,
                    'build': '',
                    'build_number': 0,
                    'version': 0,
                    'depends': [],
                    'subdir': '',
                    'platform': 'noarch',
                }
                data.update(item)
                df = df.append(data, ignore_index=True)

    repodata._df_ts = datetime.datetime.now()
    repodata._df = df
    yield
    repodata._df, repodata._df_ts = orig_data

