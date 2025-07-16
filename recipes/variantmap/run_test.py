import variantmap
import variantmap_app


def test_vm():
    assert variantmap.variantmap.test() == "PASS"


def test_vma():
    assert variantmap_app.test() == "PASS"
