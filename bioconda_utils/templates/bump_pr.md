Update `{{r.name}}`: **{{r.orig.version}}** &rarr; **{{r.version}}**

***

[Package Info](https://bioconda.github.io/recipes/{{r.name}}/README.html) | [Recipe Folder](https://github.com/{{recipe_relurl}}) | [Upstream Home]({{r.meta.about.home}}) |{{' '}}
{%- set pipe = joiner(" | ") -%}
{%- for version in r.version_data.values()|unique(attribute='releases_url') -%}
{{pipe()}}[Upstream Releases]({{version.releases_url}})
{%- endfor %}


{% if 'extra' in r.meta and 'recipe-maintainers' in r.meta.extra %}
Recipe Maintainer(s): @{{ r.meta.extra["recipe-maintainers"] | join(', @') }}
{% endif %}

{% if author -%}
Upstream Author: {% if author_is_member -%}
@{{author}}
{%- else -%}
{{"`@%s`"|format(author)}}
{% endif %}
{% endif %}

***

{% if dependency_diff %}
**Note:** Upstream dependencies appear to have changed

```diff
{{dependency_diff}}
```

***
{% endif %}

This pull request was automatically generated (see [docs](https://bioconda.github.io/updating.html)).
