{% extends "autobump_pr.md" %}

{% block type %}update_pinning{% endblock%}

{% block labels %}
autobump
update pinning
{% endblock %}

{% block title %}
Rebuild {{r.name}}{% if r.data.pinning %} ({{r.data.pinning | join(', ')}}){% endif %}{% endblock %}


{% block header %}
Rebuild [`{{r.name}}`](https://bioconda.github.io/recipes/{{r.name}}/README.html) to update pinnings
{% endblock %}


{% block message %}
{% if r.data.pinning %}
Rebuild is necessary for the following reasons:
{% for msg_list in r.data.pinning.values() %}{% for msg in msg_list -%}
- {{msg}}
{% endfor %}{% endfor %}
{% else %}
(Unable to detect reason for pinning rebuild. Predicted hash has changed, however.)
{% endif %}

***
{% endblock %}
