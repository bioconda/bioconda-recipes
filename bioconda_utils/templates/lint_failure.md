## Linting

The following problems have been found

| Recipe       | failed checks |
| ------------ | ------------- |
{% for recipe, failed in report.failed_tests.iteritems() %}
{% for check in failed %}
| {{ recipe }} | [{{ check }}](https://bioconda.github.io/linting.html#{{ check|replace("_", "-") }}) |
{% endfor %}
{% endfor %}
