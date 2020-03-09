from setuptools import setup

setup(name='ldsc',
      version='1.0',
      description='LD Score Regression (LDSC)',
      url='http://github.com/bulik/ldsc',
      author='Brendan Bulik-Sullivan and Hilary Finucane',
      author_email='',
      license='GPLv3',
      packages=['ldscore'],
      scripts=['ldsc.py', 'munge_sumstats.py'],
      install_requires = ['bitarray','nose','pybedtools','scipy','numpy','pandas']
)
