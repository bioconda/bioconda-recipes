<!-- BiocondaBot Artifacts Message (this line used to identify post) -->
{% if not recent_builds %}
No recent builds available on CircleCI at this time.
{% elif not current_builds %}
No builds for the latest commit available on CircleCI.
{% elif packages %}
Packages built on CircleCI are ready for inspection:

Arch | Package | Repodata
-----|---------|---------
{% for package in packages %}
{{package[0]}} | [{{package[1]}}]({{package[2]}}) | {{package[3]}}
{% endfor %}

You may alsu use `conda` to install these:

{% for arch in archs.items() %}
 - For packages in {{ arch[1] | join(' and ')}}:
   ```
   conda install -c {{ arch[0] }} <package name>
   ```
{% endfor %}
{% else %}
CirleCI builds completed without yielding any package artifacts.
{% endif %}
