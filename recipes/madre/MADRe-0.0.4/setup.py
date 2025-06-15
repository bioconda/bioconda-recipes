from setuptools import setup

setup(
    name="madre",
    version="0.0.4",
    package_dir={"": "src"},
    py_modules=[
        "MADRe",
        "ReadClassification",
        "DatabaseReduction",
        "CalculateAbundances"
    ],
    entry_points={
        "console_scripts": [
            "madre = MADRe:main",
            "read-classification = ReadClassification:main",
            "database-reduction = DatabaseReduction:main",
            "calculate-abundances = CalculateAbundances:main"
        ]
    },
    install_requires=[
        "scikit-learn"
    ],
    author="Josipa Lipovac",
    author_email="josipa.lipovac@fer.unizg.hr",
    description="Strain-level metagenomic classification with Metagenome Assembly driven Database Reduction approach.",
    url="https://github.com/lbcb-sci/MADRe",
)
