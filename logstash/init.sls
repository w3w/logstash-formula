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
    - require:
      - cmd: logstash_repos_key
    - contents: deb {{ pillar.logstash.repo_loc }} stable main

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
