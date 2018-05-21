{% set app = salt['pillar.get']('app:app_name') %}
{% set http_port = salt['pillar.get']('app:http_port') %}
{% set user = salt['pillar.get']('app:user') %}
{% set group = salt['pillar.get']('app:group') %}
{% set prefix = salt['pillar.get']('app:prefix') %}

nginx:
  pkg.installed: []
  service.running:
    - enabled: true
    - watch:
      - file: flaskApp-sitedef
/etc/nginx/sites-available/{{ app }}:
  file.managed:
    - source: salt://templates/nginx/sites-available/app.j2
    - template: jinja
    - require:
      - pkg: nginx
/etc/nginx/sites-available/{{ app }}:
  file.symlink:
    - target: /etc/nginx/sites-available/{{ app }}

