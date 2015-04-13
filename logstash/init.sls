logstash_repos_key:
  file.managed:
    - name: {{ repo_key_file }}
    - source: salt://logstash/files/repo.key
  cmd.run:
    - name: cat {{ repo_key_file }} | apt-key add -
    - unless: apt-key list | grep dotdeb.org
    - require:
      - file: logstash_repos_key

logstash_repo:
  file.managed:
    - name: /etc/apt/sources.list.d/logstash.list
    - require:
      - cmd: logstash_repos_key
    - contents: deb {{ logstash_repo_loc }} stable main

logstash_soft:
  pkg.installed:
    - name: logstash
    - refresh: True
    - require:
      - file: logstash_repo

logstash_service:
  service.running:
    - name: logstash
    - enable: True
    - require:
      - pkg: logstash_soft
    - watch:
      - file: /etc/logstash/conf.d/*
