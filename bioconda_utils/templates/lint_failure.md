## Linting

The following problems have been found

{% for recipe, failed in report.failed_tests.iteritems() -%}
| Recipe       | failed checks |
| ------------ | ------------- |
{% for check in failed -%}
| {{ recipe }} | [{{ check }}](https://bioconda.github.io/linting.html#{{ check }}) |
{%- endfor %}
{%- endfor %}
