from setuptools import setup

setup(
   name='helixer',
   version='0.3.1',
   description='Deep Learning fun on gene structure data',
   packages=['helixer', 'helixer.core', 'helixer.prediction', 'helixer.evaluation', 'helixer.tests', 'helixer.export'],
   package_data={'helixer': ['testdata/*.fa', 'testdata/*.gff']},
   install_requires=["geenuff @ https://github.com/weberlab-hhu/GeenuFF/archive/refs/heads/main.zip"],
   dependency_links=["https://github.com/weberlab-hhu/GeenuFF/archive/refs/heads/main.zip#egg=geenuff"],
   scripts=["Helixer.py", "fasta2h5.py", "geenuff2h5.py", "helixer/prediction/HybridModel.py", "scripts/fetch_helixer_models.py"],
   zip_safe=False,
)
