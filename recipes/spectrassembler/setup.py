from setuptools import setup

setup(name='spectrassembler',
      version='0.0.1',
      description='Tool (experimental) to compute layout from overlaps with spectral algorithm',
      url='https://github.com/antrec/spectrassembler',
      author='Antoine Recanati',
      author_email = '',
      license='MIT',
      scripts = ['spectral_layout_from_minimap.py', 'get_position_from_sam.py', 'gen_cons_from_poa.py'],
      data_files=[('poa-score.mat')],
      install_requires=[
        'numpy',
        'scipy',
        'biopython']
      )
