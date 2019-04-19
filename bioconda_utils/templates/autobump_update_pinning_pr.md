{% extends "autobump_pr.md" %}

{% block type %}update_pinning{% endblock%}

{% block labels %}
autobump
update pinning
{% endblock %}

{% block title %}Rebuild {{r.name}}{% endblock %}


{% block header %}
Rebuild `{{r.name}}` to update pinnings
{% endblock %}


{% block message %}
{% endblock %}
