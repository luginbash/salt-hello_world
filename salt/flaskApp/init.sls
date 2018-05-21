{% set app = salt['pillar.get']('app:app_name') %}
{% set http_port = salt['pillar.get']('app:http_port') %}
{% set user = salt['pillar.get']('app:user') %}
{% set group = salt['pillar.get']('app:group') %}
{% set prefix = salt['pillar.get']('app:prefix') %}
{% set repo = salt['pillar.get']('app:git_repo') %}

virtualenv:
  pkg.installed: []
uwsgi:
  pkg.installed: []
redis:
  pkg.installed: []
uwsgi-plugin-python:
  pkg.installed: []

{{ repo }}:
  git.latest:
    - rev: master
    - target: {{ prefix }}/{{ app }}
    - user: {{ user }}
    - force_reset: True
    - require:
      - pkg: git
{{ prefix }}/{{ app }}:
  virtualenv.managed:
    - system_site_packages: False
    - requirements: {{ prefix }}/{{ app }}/requirements.txt
    - require: 
      - git: {{ repo }}
      - pkg: nginx
  file.directory:
    - user: {{ user }}
    - group: {{ group }}
    - recurse:
      - user
      - group
{{ prefix }}/{{ app }}/uwsgi.conf:
  file.managed:
    - user: {{ user }}
    - group: {{ group }}
    - source: salt://templates/uwsgi.conf.j2
    - template: jinja
    - require:
      - virtualenv: {{ prefix }}/{{ app }}
/lib/systemd/system/{{ app }}.service:
  file.managed:
    - source: salt://templates/app.service.j2
    - template: jinja
    - require:
      - virtualenv: {{ prefix }}/{{ app }}
{{ app }}:
  service.running:
    - enable: True
    - require: 
      - file: /lib/systemd/system/{{ app }}.service