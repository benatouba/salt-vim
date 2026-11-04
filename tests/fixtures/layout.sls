{% if grains['os'] %}
first:
  pkg.installed: []
{%- for name in names -%}
{{ name }}:
  file.managed:
    - contents: |
        literal text
        {% endif %}
    - mode: '0644'
{%- else -%}
fallback:
  test.nop: []
{%- endfor -%}
{% else %}
other:
  service.running: []
{% endif %}
{%- load_yaml as settings -%}
settings:
  nested:
    value: true
{%- endload -%}
{%- raw -%}
literal:
  {% if not_a_block %}
{%- endraw -%}
plain:
  test.nop: []
