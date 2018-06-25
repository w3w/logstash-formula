logstash_repos_key:
  file.managed:
    - name: {{ pillar.logstash.repo_key_file }}
    - source: salt://logstash/files/repo.key
  cmd.run:
    - name: cat {{ pillar.logstash.repo_key_file }} | apt-key add -
    - unless: apt-key list | grep 2048R/D88E42B4
    - require:
      - file: logstash_repos_key

logstash_repo:
  file.managed:
    - name: /etc/apt/sources.list.d/logstash.list
    - contents: deb {{ pillar.logstash.repo_loc }} stable main
    - require:
      - cmd: logstash_repos_key

logstash_soft:
  pkg.installed:
    - name: logstash
    - require:
      - file: logstash_repo

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
