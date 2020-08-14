<!--
creator: autobump
type: {% block type %}{% endblock %}

recipe: {{r.name}}
orig_version: {{r.orig.version}}
orig_build_number: {{r.orig.build_number}}
new_version: {{r.version}}
new_build_bumber: {{r.build_number}}
-->

{% block header %}{% endblock%}

[![install with bioconda](https://img.shields.io/badge/install%20with-bioconda-brightgreen.svg?style=flat)](http://bioconda.github.io/recipes/{{r.name}}/README.html) [![Conda](https://img.shields.io/conda/dn/bioconda/{{r.name}}.svg)](https://anaconda.org/bioconda/{{r.name}}/files)

Info | Link
-----|-----
Recipe | [`{{r.dir}}`](https://github.com/{{recipe_relurl}}) (click to view/edit other files)
{% if r.version_data.values()|unique(attribute='releases_url') -%}
Releases |
{%- for version in r.version_data.values()|unique(attribute='releases_url') -%}
[{{version.releases_url}}]({{version.releases_url}}){{"<br>" if not loop.last}}
{%- endfor %}
{%- endif %}

{% if 'extra' in r.meta and 'recipe-maintainers' in r.meta.extra %}
Recipe Maintainer(s) | @{{ r.meta.extra["recipe-maintainers"] | join(', @') }}
{% endif %}
{% if author -%}
Author | {% if author_is_member %}@{{author}}{% else %}{{"`@%s`"|format(author)}}{% endif %}
{% endif %}

***

{% block message %}{% endblock %}

This pull request was automatically generated (see [docs](https://bioconda.github.io/contributor/updating.html)).
