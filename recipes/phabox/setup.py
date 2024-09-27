from setuptools import setup, find_packages

setup(
    name='phabox',
    version='1.0',
    packages=["phabox"],
    package_dir={'phabox': '.'},
    package_data={
        '': ['scripts/*.py', 'models/*.py', 'GTDB/*.py']
    },
    entry_points={
        'console_scripts': [
            'phabox=phabox.main:main',  # Allows running the script with `phabox` command
            'Cherry_single=phabox.Cherry_single:main',
            'PhaGCN_single=phabox.PhaGCN_single:main',
            'PhaMer_single=phabox.PhaMer_single:main',
            'PhaTYP_single=phabox.PhaTYP_single:main',
        ]
    },
    install_requires=[
        'numpy==1.21.2',
        'pandas==1.3.4',
        'scipy==1.7.1',
        'attrs==21.4.0',
        'aiohttp==3.8.1',
        'torch',
        'networkx',
        'transformers[torch]',
        'pyarrow',
        'accelerate',
        'datasets',
        'psutil',
    ],
    author='SHANG JIAYU',
    author_email='jiayushang@cuhk.edu.hk',
    description='Local version of the phage identification and analysis web server',
    long_description=open('README.md').read(),
    long_description_content_type='text/markdown',
    url='https://github.com/KennthShang/PhaBOX',
    classifiers=[
        'Programming Language :: Python :: 3',
        'License :: OSI Approved :: MIT License',
        'Operating System :: OS Independent',
    ],
    python_requires='>=3.9',
)
