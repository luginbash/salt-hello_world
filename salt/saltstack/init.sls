saltstack.repo:
    pkgrepo.managed:
        - name: deb http://mirrors.tuna.tsinghua.edu.cn/saltstack/apt/ubuntu/16.04/amd64/latest xenial main
        - keyid: 0E08A149DE57BFBE
        - file: /etc/apt/sources.list.d/saltstack.list
        - refresh_db: true
salt-minion:
    pkg.installed: 
        - force_conf_old: True
    service.running:
        - enable: True
        - full_restart: True