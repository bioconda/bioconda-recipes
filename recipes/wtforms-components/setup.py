"""
WTForms-Components
------------------

Additional fields, validators and widgets for WTForms.
"""

from setuptools import setup
import os
import re
import sys


HERE = os.path.dirname(os.path.abspath(__file__))
PY3 = sys.version_info[0] == 3


def get_version():
    filename = os.path.join(HERE, 'wtforms_components', '__init__.py')
    with open(filename) as f:
        contents = f.read()
    pattern = r"^__version__ = '(.*?)'$"
    return re.search(pattern, contents, re.MULTILINE).group(1)

extras_require = {
    'test': [
        'pytest>=2.2.3',
        'flexmock>=0.9.7',
        'WTForms-Test>=0.1.1',
        'flake8>=2.4.0',
        'isort>=4.2.2',
    ],
    'color': ['colour>=0.0.4'],
    'ipaddress': ['ipaddr'] if not PY3 else [],
    'timezone': ['python-dateutil'],
}


# Add all optional dependencies to testing requirements.
for name, requirements in extras_require.items():
    if name != 'test':
        extras_require['test'] += requirements


setup(
    name='WTForms-Components',
    version=get_version(),
    url='https://github.com/kvesteri/wtforms-components',
    license='BSD',
    author='Konsta Vesterinen',
    author_email='konsta@fastmonkeys.com',
    description='Additional fields, validators and widgets for WTForms.',
    long_description=__doc__,
    packages=[
        'wtforms_components',
        'wtforms_components.fields'
    ],
    zip_safe=False,
    include_package_data=True,
    platforms='any',
    dependency_links=[
        # 5.6b1 only supports python 3.x / pending release
        'git+git://github.com/daviddrysdale/python-phonenumbers.git@python3'
        '#egg=phonenumbers3k-5.6b1',
    ],
    install_requires=[
        'WTForms>=1.0.4',
        'six>=1.4.1',
        'validators>=0.5.0',
        'intervals>=0.6.0'
    ],
    extras_require=extras_require,
    classifiers=[
        'Environment :: Web Environment',
        'Intended Audience :: Developers',
        'License :: OSI Approved :: BSD License',
        'Operating System :: OS Independent',
        'Programming Language :: Python',
        'Programming Language :: Python :: 2',
        'Programming Language :: Python :: 2.7',
        'Programming Language :: Python :: 3',
        'Programming Language :: Python :: 3.3',
        'Programming Language :: Python :: 3.4',
        'Programming Language :: Python :: 3.5',
        'Programming Language :: Python :: Implementation :: CPython',
        'Programming Language :: Python :: Implementation :: PyPy',
        'Topic :: Internet :: WWW/HTTP :: Dynamic Content',
        'Topic :: Software Development :: Libraries :: Python Modules'
    ]
)
