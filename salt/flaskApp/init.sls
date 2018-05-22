{% set app = salt['pillar.get']('app:app_name') %}
{% set http_port = salt['pillar.get']('app:http_port') %}
{% set user = salt['pillar.get']('app:user') %}
{% set group = salt['pillar.get']('app:group') %}
{% set prefix = salt['pillar.get']('app:prefix') %}
{% set hash = salt['pillar.get']('app:archive_hash') %}
{% set archive_name = salt['pillar.get']('app:archive_name') %}

app_prerequisites:
  pkg.installed:
    - pkgs:
      - virtualenv
      - redis
      - uwsgi
      - uwsgi-plugin-python
      - python-dev
      - build-essential
      - nginx

{{ prefix }}/{{ app }}:
  virtualenv.managed:
    - system_site_packages: False
    - requirements: {{ prefix }}/{{ app }}/requirements.txt
    - cwd: {{ prefix }}/{{ app }}/bin
    - require: 
      - archive: app_payload
      - pkg: nginx
app_payload:
  archive.extracted:
    - name: {{ prefix }}/{{ app }}
    - source: salt://files/src/{{ archive_name }}
    - archive_format: tar
    - source_hash: {{ hash }}
    - user: {{ user }}
    - group: {{ group }}
/etc/uwsgi:
  file.directory:
    - managed: []
    - user: {{ user }}
    - group: {{ group }}
    - mode: 750
    - makedirs: True
/etc/uwsgi/{{ app }}.ini:
  file.managed:
    - user: {{ user }}
    - group: {{ group }}
    - source: salt://templates/uwsgi-app.ini.j2
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
    - watch:
      - file: /etc/uwsgi/{{ app }}.ini

/etc/nginx/sites-available/{{ app }}:
  file.managed:
    - source: salt://templates/nginx/sites-available/app.j2
    - template: jinja
    - require:
      - pkg: nginx
/etc/nginx/sites-enabled/{{ app }}:
  file.symlink:
    - target: /etc/nginx/sites-available/{{ app }}
    - require: /etc/nginx/sites-available/{{ app }}
reload-nginx:
  service.running:
    - name: nginx
    - enable: True
    - reload: True
    - watch:
      - module: nginx-config-test
nginx-config-test:
  module.wait:
    - name: nginx.configtest
    - watch:
      - file: /etc/nginx/sites-available/*