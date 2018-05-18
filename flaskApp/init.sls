{% set app = salt['pillar.get']('flaskApp:app_name') %}
{% set http_port = salt['pillar.get']('flaskApp:http_port') %}
{% set user = salt['pillar.get']('flaskApp:user') %}
{% set group = salt['pillar.get']('flaskApp:group') %}
{% set prefix = salt['pillar.get']('flaskApp:prefix') %}
{% set repo = salt['pillar.get']('flaskApp:git_repo') %}

{{ prefix }}/{{ app }}:
  virtualenv.managed:
    - system_site_packages: False
    - requirements: {{ prefix }}/{{ app }}/requirements.txt
    - user: {{ user }}
    - group: {{ group }}
    - require: {{ repo }}
{{ repo }}:
  git.latest:
    - rev: prod
    - target: {{ prefix }}/{{ app }}:
    - require:
      - pkg: git
{{ prefix }}/{{ app }}/uwsgi.conf:
  file.managed:
    - source: salt://templates/uwsgi.conf.j2
    - template: jinja


/lib/systemd/system/{{ app }}.service:
  service.enabled: []
  service.running: []
  - context:
      service: {{ app }}
      user: www-data
      group: www-data
  - source: salt://templates/app.service.j2
  - template: jinja
  - require:
    - virtualenv: {{ prefix }}/{{ app }}