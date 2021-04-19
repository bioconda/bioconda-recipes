{% extends "autobump_pr.md" %}

{% block type %}bump_version{% endblock%}

{% block labels %}
autobump
new version
{% endblock %}

{% block title %}Update {{r.name}} to {{r.version}}{% endblock %}


{% block header %}
Update [`{{r.name}}`](https://bioconda.github.io/recipes/{{r.name}}/README.html): **{{r.orig.version}}** &rarr; **{{r.version}}**
{% endblock %}


{% block message %}
{% if dependency_diff %}

**Note:** Upstream dependencies appear to have changed

```diff
{{dependency_diff}}
```
***
{% endif %}
{% endblock %}
