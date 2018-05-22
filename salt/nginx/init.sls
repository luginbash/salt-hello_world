{% set app = salt['pillar.get']('app:app_name') %}
{% set http_port = salt['pillar.get']('app:http_port') %}
{% set user = salt['pillar.get']('app:user') %}
{% set group = salt['pillar.get']('app:group') %}
{% set prefix = salt['pillar.get']('app:prefix') %}

nginx:
  pkg.installed: []
  service.running:
    - enable: true
    - watch:
      - file: /etc/nginx/sites-enabled/{{ app }}
  file.managed:
    - name: /etc/nginx/sites-available/{{ app }}
    - source: salt://templates/nginx/sites-available/app.j2
    - template: jinja
    - require:
      - pkg: nginx:
  file.symlink:
    - name: /etc/nginx/sites-enabled/{{ app }}
    - target: /etc/nginx/sites-available/{{ app }}

