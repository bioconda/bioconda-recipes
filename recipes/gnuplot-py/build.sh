
sed -i '20s/cStringIO/io/' PlotItems.py
sed -i '22s/StringIO/io/' PlotItems.py
2to3 -w utils.py
2to3 -w test.py
sed -i "40a py_modules=['gp','gp_unix','Errors','PlotItems','utils','_Gnuplot','termdefs']," setup.py
$PYTHON -m pip install . --ignore-installed --no-deps -vv
