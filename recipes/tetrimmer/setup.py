from setuptools import setup, find_packages


setup(
    name='tetrimmer',
    version= '1.2.0',
    description="a tool to replace transposable element manual curation. TEtrimmer won't do TE de novo annotation but use the output from other annotation tools like RepeatModeler, REPET, and EDTA",

    license="GPLv3",
    author="Jiangzhao Qian; Hang Xue",
    author_email='jqian@bio1.rwth-aachen.de;  hang_xue@berkeley.edu',
    url='https://github.com/qjiangzhao/TEtrimmer',
    include_package_data=True,  # this is set to True because there are non .py files (eg. R)
    packages=find_packages(include=('tetrimmer', 'tetrimmer.*')), 
    package_data={'tetrimmer': ['config.json','TEtrimmer_proof_anno_GUI/*', 'TE-Aid-master/*']},
    entry_points={
        'console_scripts': [
            'tetrimmer=tetrimmer.TEtrimmer:main'
        ]
    },
    install_requires=[     # All Requirements
        'numpy>=1.26.0',
        'python',
        'perl>=5.26.2',
        'r-base>=4.2.1',
        'biopython>=1.81',
        'matplotlib>=3.8.1',
        'multiprocess>=0.70.15',
        'pandas>=2.1.2',
        'pypdf2>=2.11.1',
        'scikit-learn>=1.3.2',
        'urllib3>=2.0.7',
        'regex>=2023.10.3',
        'tk>=8.6.13',
        'click>=8.1.7',
        'requests>=2.31.0',
        'bedtools>=2.31.1',
        'blast==2.5.0',
        'cd-hit>=4.8.1',
        'emboss>=6.5.7',
        'hmmer>=3.3.2',
        'mafft>=7.520',
        'pfam_scan>=1.6',
        'repeatmasker',
        'rmblast==2.10.0',
        'samtools>=1.18',
        'dataclasses',
        'repeatmodeler==2.0.1',
        'muscle==3.8',
        'iqtree>=2.2.5',
        'ghostscript'
    ],
    keywords='tetrimmer',
    classifiers=[
        'Programming Language :: Python :: 3.10',
    ]
)
