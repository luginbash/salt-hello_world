wsgi-description:
  file.managed:
    - name: /etc/nginx/sites-available/wsgi
    - source: salt://wsgi

{% if not salt['file.exists' ]('/etc/nginx/sites-enabled/wsgi') %}
enable-wsgi-site:
  file.symlink:
    - name: /etc/nginx/sites-enabled/wsgi
    - target: /etc/nginx/sites-available/wsgi
{% endif %}

/var/www:
  file:
    - directory
    - user: www-data
    - group: www-data
    - mode: 0755
    - makedirs: True
    - pkg: nginx

/etc/nginx:
  file.directory:
    - user: root
    - group: root
    - makedirs: True

/etc/nginx/nginx.conf:
  file.managed:
    - template: jinja
    - user: root
    - group: root
    - mode: 644
    - source: salt://nginx/templates/nginx.conf.j2
    - require:
      - file: /etc/nginx

{% for dir in ('sites-enabled', 'sites-available') %}
/etc/nginx/{{ dir }}:
  file.directory:
    - user: root
    - group: root
{% endfor -%}
{% endif %}

nginx:
  pkg.installed: []
  service.running:
    - watch:
      - file: wsgi-description
  service.enabled: []