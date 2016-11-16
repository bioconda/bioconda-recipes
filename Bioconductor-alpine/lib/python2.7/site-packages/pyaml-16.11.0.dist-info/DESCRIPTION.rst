pretty-yaml (or pyaml)
======================

PyYAML-based python module to produce pretty and readable YAML-serialized data.

.. contents::
  :backlinks: none


What this module does and why
-----------------------------

YAML is generally nice and easy format to read *if* it was written by humans.

PyYAML can a do fairly decent job of making stuff readable, and the best
combination of parameters for such output that I've seen so far is probably this one::

  >>> m = [123, 45.67, {1: None, 2: False}, u'some text']
  >>> data = dict(a=u'asldnsa\nasldpáknsa\n', b=u'whatever text', ma=m, mb=m)
  >>> yaml.safe_dump(data, sys.stdout, allow_unicode=True, default_flow_style=False)
  a: 'asldnsa

    asldpáknsa

    '
  b: whatever text
  ma: &id001
  - 123
  - 45.67
  - 1: null
    2: false
  - some text
  mb: *id001

pyaml tries to improve on that a bit, with the following tweaks:

* Most human-friendly representation options in PyYAML (that I know of) get
  picked as defaults.

* Does not dump "null" values, if possible, replacing these with just empty
  strings, which have the same meaning but reduce visual clutter and are easier
  to edit.

* Dicts, sets, OrderedDicts, defaultdicts, namedtuples, etc are representable
  and get sorted on output (OrderedDicts and namedtuples keep their ordering),
  so that output would be as diff-friendly as possible, and not arbitrarily
  depend on python internals.

  It appears that at least recent PyYAML versions also do such sorting for
  python dicts.

* List items get indented, as they should be.

* bytestrings that can't be auto-converted to unicode raise error, as yaml has
  no "binary bytes" (i.e. unix strings) type.

* Attempt is made to pick more readable string representation styles, depending
  on the value, e.g.::

    >>> yaml.safe_dump(cert, sys.stdout)
    cert: '-----BEGIN CERTIFICATE-----

      MIIH3jCCBcagAwIBAgIJAJi7AjQ4Z87OMA0GCSqGSIb3DQEBCwUAMIHBMRcwFQYD

      VQQKFA52YWxlcm9uLm5vX2lzcDEeMBwGA1UECxMVQ2VydGlmaWNhdGUgQXV0aG9y
    ...

    >>> pyaml.p(cert):
    cert: |
      -----BEGIN CERTIFICATE-----
      MIIH3jCCBcagAwIBAgIJAJi7AjQ4Z87OMA0GCSqGSIb3DQEBCwUAMIHBMRcwFQYD
      VQQKFA52YWxlcm9uLm5vX2lzcDEeMBwGA1UECxMVQ2VydGlmaWNhdGUgQXV0aG9y
    ...

* "force_embed" option to avoid having &id stuff scattered all over the output
  (which might be beneficial in some cases, hence the option).

* "&id" anchors, if used, get labels from the keys they get attached to,
  not just use meaningless enumerators.

* "string_val_style" option to only apply to strings that are values, not keys,
  i.e::

    >>> pyaml.p(data, string_val_style='"')
    key: "value\nasldpáknsa\n"
    >>> yaml.safe_dump(data, sys.stdout, allow_unicode=True, default_style='"')
    "key": "value\nasldpáknsa\n"

* Has an option to add vertical spacing (empty lines) between keys on different
  depths, to make output much more seekable.

Result for the (rather meaningless) example above (without any additional
tweaks)::

  >>> pyaml.p(data)
  a: |
    asldnsa
    asldpáknsa
  b: 'whatever text'
  ma: &ma
    - 123
    - 45.67
    - 1:
      2: false
    - 'some text'
  mb: *ma

----------

Extended example::

  >>> pyaml.dump(conf, sys.stdout, vspacing=[2, 1]):
  destination:

    encoding:
      xz:
        enabled: true
        min_size: 5120
        options:
        path_filter:
          - \.(gz|bz2|t[gb]z2?|xz|lzma|7z|zip|rar)$
          - \.(rpm|deb|iso)$
          - \.(jpe?g|gif|png|mov|avi|ogg|mkv|webm|mp[34g]|flv|flac|ape|pdf|djvu)$
          - \.(sqlite3?|fossil|fsl)$
          - \.git/objects/[0-9a-f]+/[0-9a-f]+$

    result:
      append_to_file:
      append_to_lafs_dir:
      print_to_stdout: true

    url: http://localhost:3456/uri


  filter:
    - /(CVS|RCS|SCCS|_darcs|\{arch\})/$
    - /\.(git|hg|bzr|svn|cvs)(/|ignore|attributes|tags)?$
    - /=(RELEASE-ID|meta-update|update)$


  http:

    ca_certs_files: /etc/ssl/certs/ca-certificates.crt

    debug_requests: false

    request_pool_options:
      cachedConnectionTimeout: 600
      maxPersistentPerHost: 10
      retryAutomatically: true


  logging:

    formatters:
      basic:
        datefmt: '%Y-%m-%d %H:%M:%S'
        format: '%(asctime)s :: %(name)s :: %(levelname)s: %(message)s'

    handlers:
      console:
        class: logging.StreamHandler
        formatter: basic
        level: custom
        stream: ext://sys.stderr

    loggers:
      twisted:
        handlers:
          - console
        level: 0

    root:
      handlers:
        - console
      level: custom

Note that unless there are many moderately wide and deep trees of data, which
are expected to be read and edited by people, it might be preferrable to
directly use PyYAML regardless, as it won't introduce another (rather pointless
in that case) dependency and a point of failure.


Obligatory warning
------------------

Prime concern for this module is to chew *simple* types/values gracefully, and
internally there are some nasty hacks (that I'm not too proud of) used to do
that, which may not work with more complex serialization cases, possibly even
producing non-deserializable (but still easily fixable) output.

Again, prime goal is **not** to serialize, say, gigabytes of complex
document-storage db contents, but rather individual simple human-parseable
documents, please keep that in mind (and of course, patches for hacks are
welcome!).


Some Tricks
-----------

* Pretty-print any yaml or json (yaml subset) file from the shell::

    python -m pyaml /path/to/some/file.yaml
    curl -s https://status.github.com/api.json | python -m pyaml

* Easier "debug printf" for more complex data (all funcs below are aliases to
  same thing)::

    pyaml.p(stuff)
    pyaml.pprint(my_data)
    pyaml.pprint('----- HOW DOES THAT BREAKS!?!?', input_data, some_var, more_stuff)
    pyaml.print(data, file=sys.stderr) # needs "from __future__ import print_function"

* Force all string values to a certain style (see info on these in
  `PyYAML docs`_)::

    pyaml.dump(many_weird_strings, string_val_style='|')
    pyaml.dump(multiline_words, string_val_style='>')
    pyaml.dump(no_want_quotes, string_val_style='plain')

  Using ``pyaml.add_representer()`` (note \*p\*yaml) as suggested in
  `this SO thread`_ (or `github-issue-7`_) should also work.

* Control indent and width of the results::

    pyaml.dump(wide_and_deep, indent=4, width=120)

  These are actually keywords for PyYAML Emitter (passed to it from Dumper),
  see more info on these in `PyYAML docs`_.

.. _PyYAML docs: http://pyyaml.org/wiki/PyYAMLDocumentation#Scalars
.. _this SO thread: http://stackoverflow.com/a/7445560
.. _github-issue-7: https://github.com/mk-fg/pretty-yaml/issues/7


Installation
------------

It's a regular package for Python 2.7 (not 3.X).

Using pip_ is the best way::

  % pip install pyaml

If you don't have it, use::

  % easy_install pip
  % pip install pyaml

Alternatively (see also `pip docs "installing" section`_)::

  % curl https://raw.github.com/pypa/pip/master/contrib/get-pip.py | python
  % pip install pyaml

Or, if you absolutely must::

  % easy_install pyaml

But, you really shouldn't do that.

Current-git version can be installed like this::

  % pip install 'git+https://github.com/mk-fg/pretty-yaml.git#egg=pyaml'

Module uses PyYAML_ for processing of the actual YAML files and should pull it
in as a dependency.

Dependency on unidecode_ module is optional and should only be necessary if
same-id objects or recursion is used within serialized data.

.. _pip: http://pip-installer.org/
.. _pip docs "installing" section: http://www.pip-installer.org/en/latest/installing.html
.. _PyYAML: http://pyyaml.org/
.. _unidecode: http://pypi.python.org/pypi/Unidecode


