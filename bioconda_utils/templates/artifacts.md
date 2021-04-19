<!-- BiocondaBot Artifacts Message (this line used to identify post) -->
{% if packages %}
Package(s) built on CircleCI are ready for inspection:

Arch | Package | Repodata
-----|---------|---------
{% for package in packages %}
{{package.arch}} | [{{package.fname}}]({{package.url}}) | {{package.repodata_md}}
{% endfor %}

***
{% endif %}{% if repos %}

You may also use `conda` to install these:

{% for repo in repos.items() %}
 - For packages in {{ repo[1] | join(' and ')}}:
   ```
   conda install -c {{ repo[0] }} <package name>
   ```
{% endfor %}

***
{% endif %}{%if images %}

Docker image(s) built:

Package | Tag | Install with `docker`
--------|-----|----------------------
{% for image in images %}
[{{image.name}}]({{image.url}}) | {{image.tag}} | <details><summary>show</summary>`curl "{{image.url}}" \| gzip -dc \| docker load`
{% endfor %}
{% endif %}

{% if not packages and not repos and not images %}
No artifacts found on recent CircleCI builds.
{% endif %}
