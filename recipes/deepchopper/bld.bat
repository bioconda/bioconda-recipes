@echo on

maturin build --release --strip --interpreter python
if errorlevel 1 exit 1

%PYTHON% -m pip install . --no-deps -vv
if errorlevel 1 exit 1
