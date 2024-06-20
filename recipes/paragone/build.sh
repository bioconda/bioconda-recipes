# Install ParaGone
$PYTHON -m pip install --no-deps --ignore-installed .

# Install TAPER:
git clone https://github.com/chaoszhang/TAPER.git
cp TAPER/correction_multi.jl ${PREFIX}/bin
