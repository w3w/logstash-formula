{%- set config = salt['pillar.get']('logstash', {}) -%}
#key file is not used anymore
{% if config.get('repo_key_file', false) %}
logstash_repos_key:
  file.absent:
    - name: {{ config.repo_key_file }}
{% endif %}

logstash_repo:
  pkgrepo.managed:
    - file: /etc/apt/sources.list.d/logstash.list
    - name: 'deb {{ config.repo_loc }} stable main'
    - clean_file: True
    - key_url: {{ config.get('repo_key_url', 'https://artifacts.elastic.co/GPG-KEY-elasticsearch') }}

logstash_soft:
  pkg.installed:
    - name: logstash
    - require:
      - pkgrepo: logstash_repo

logstash_service:
  service.running:
    - name: logstash
    - enable: True
    - require:
      - pkg: logstash_soft
      - service: elasticsearch

# custom patterns
{% for pattern in pillar.logstash.patterns %}
logstash_pattern_{{ pattern.name }}:
  file.managed:
    - name: /opt/logstash/patterns/{{ pattern.name }}
    - source: {{ pattern.source }}
    - template: jinja
    - user: logstash
    - group: logstash
    - watch_in:
      - service: logstash_service
{% endfor %}

{% for item in pillar.logstash_inputs %}
logstash_pattern_{{ item.name }}:
  file.managed:
    - name: /etc/logstash/conf.d/{{ item.name }}
    - source: {{ item.source }}
    - template: jinja
    - user: logstash
    - group: logstash
    - watch_in:
      - service: logstash_service
{% endfor %}

{% for item in pillar.logstash_filters %}
logstash_pattern_{{ item.name }}:
  file.managed:
    - name: /etc/logstash/conf.d/{{ item.name }}
    - source: {{ item.source }}
    - template: jinja
    - user: logstash
    - group: logstash
    - watch_in:
      - service: logstash_service
{% endfor %}

{% for item in pillar.logstash_outputs %}
logstash_pattern_{{ item.name }}:
  file.managed:
    - name: /etc/logstash/conf.d/{{ item.name }}
    - source: {{ item.source }}
    - template: jinja
    - user: logstash
    - group: logstash
    - watch_in:
      - service: logstash_service
{% endfor %}
