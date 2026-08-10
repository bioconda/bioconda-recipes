set MATURIN_PEP517_ARGS=--features=pyo3/extension-module

maturin build --release --features=pyo3/extension-module --out dist
if errorlevel 1 exit 1

"%PYTHON%" -m pip install dist\iscc_sum-*.whl --no-deps -vv
if errorlevel 1 exit 1
