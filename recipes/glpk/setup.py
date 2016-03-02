from setuptools import setup, Extension
from os import environ

module = Extension("spam",
                   sources=["spam.c"],
                   include_dirs=[environ.get("LIBRARY_INC", "")],
                   library_dirs=[environ.get("LIBRARY_LIB", "")],
                   libraries=["glpk"]
                   )

setup(name="spam",
      test_suite="spam.suite",
      ext_modules=[module])
