{% set app = salt['pillar.get']('app:app_name') %}
{% set http_port = salt['pillar.get']('app:http_port') %}
{% set user = salt['pillar.get']('app:user') %}
{% set group = salt['pillar.get']('app:group') %}
{% set prefix = salt['pillar.get']('app:prefix') %}

nginx:
  pkg.installed: []

flaskApp-sitedef:
  file.managed:
    - name: /etc/nginx/sites-available/{{ app }}
    - source: salt://templates/nginx/sites-available/app.j2
    - template: jinja

{% if not salt['file.exists' ]('/etc/nginx/sites-enabled/{{ app }}') %}
enable-wsgi-site:
  file.symlink:
    - name: /etc/nginx/sites-enabled/{{ app }}
    - target: /etc/nginx/sites-available/{{ app }}
{% endif %}

/var/www:
  file:
    - directory
    - user: www-data
    - group: www-data
    - mode: 0755
    - makedirs: True
    - pkg: nginx

nginx:
  pkg.installed: []
  service.running:
    - enabled: true
    - watch:
      - file: flaskApp-sitedef