#!jinja|yaml
{% set settings = {'paths': ['/srv/example', '/srv/other']} %}
{% import_yaml 'defaults.yaml' as defaults %}
{% load_yaml as data %}
message: hello
{% endload %}
include:
  - example.common
{% for path in settings.paths -%}
{{ path }}:
  file.managed:
    - name: "{{ pillar['example:name'] }}"
    - source: {{ salt['pillar.get']('example:source', 'salt://example') }}
    - require_any:
      - pkg: example
    - onchanges_any:
      - file: example-config
    - retry:
        attempts: 3
    - content: |
        {{ grains['id'] }}
        requires is ordinary text here
    - unless: echo requires
    - requires:
      - pkg: typo
{% endfor %}
{# require_any: is a comment, not a requisite #}
raw: |
  {% raw %}
  {{ pillar }}
  {% endraw %}
{%+ if opts %}
extra: '{{ config }}'
{% endif +%}
trimmed_raw: |
  {%- raw -%}
  {{ grains['literal'] }}
  {%- endraw -%}
left_trimmed_raw: |
  {%- raw %}
  {{ pillar }}
  {% endraw -%}
right_trimmed_raw: |
  {% raw -%}
  {{ salt }}
  {%+ endraw %}
tight_raw: '{%-raw-%}{{ opts }}{%-endraw-%}'
raw_tag_body: |
  {%- raw -%}
  {%- if pillar -%}
  {%- endraw -%}
after_raw: {{ config }}
{# {%- raw -%} #}
after_comment: {{ grains }}
quoted: {{ "{%- raw -%}" }}
after_string: {{ sls }}
