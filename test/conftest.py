import pytest

def pytest_runtest_makereport(item, call):
    if "successive" in item.keywords:
        # if we failed, mark parent with callspec id (name from test args)
        if call.excinfo is not None:
            item.parent.failedcallspec = item.callspec.id

def pytest_runtest_setup(item):
    if "successive" in item.keywords:
        if getattr(item.parent, "failedcallspec", None) == item.callspec.id:
            pytest.xfail("preceding test failed")
