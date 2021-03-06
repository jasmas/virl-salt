{% set proxy = salt['grains.get']('proxy', False) %}
{% set cml = salt['grains.get']('cml', False) %}
{% set password = salt['grains.get']('password', 'password') %}
{% set ks_token = salt['grains.get']('keystone_service_token', 'password') %}
{% set stdport = salt['grains.get']('virl_webservices', '19399') %}
{% set uwmport = salt['grains.get']('virl_user_management', '19400') %}
{% set uwmpassword= salt['grains.get']('uwmadmin_password', 'password') %}
{% set virl_type = salt['grains.get']('virl_type', 'stable') %}
{% set ank = salt['grains.get']('ank', '19401') %}
{% set http_proxy = salt['grains.get']('http_proxy', 'https://proxy-wsa.esl.cisco.com:80/') %}

VIRL variable reset:
  cmd.run:
    - names:
      - crudini --set /etc/virl/virl.cfg env virl_openstack_password {{ password }}
      - crudini --set /etc/virl/virl.cfg env virl_openstack_service_token {{ ks_token }}
      - crudini --set /etc/virl/virl.cfg env virl_std_port {{ stdport }}
      - crudini --set /etc/virl/virl.cfg env virl_std_url http://localhost:{{ stdport }}
      - crudini --set /etc/virl/virl.cfg env virl_uwm_port {{ uwmport }}
      - crudini --set /etc/virl/virl.cfg env virl_uwm_url http://localhost:{{ uwmport }}

variable reset std:
  service:
    - name: virl-std
    - running
    - enable: True
    - restart: True
    - watch:
      - cmd: VIRL variable reset

variable reset uwm:
  service:
    - name: virl-uwm
    - running
    - enable: True
    - restart: True
    - watch:
      - cmd: VIRL variable reset
      - file: uwm port replace renum

ank_init rehost:
  file.managed:
    - order: 2
    - name: /etc/init.d/ank-webserver
    - source: "salt://files/ank-webserver.init"
    - mode: 0755

autonetkit_cfg rehost:
  file.managed:
    - name: /root/.autonetkit/autonetkit.cfg
    - order: 3
    - makedirs: True
    - source: "salt://files/autonetkit.cfg"
    - mode: 0755

ank-webserver rehost:
  file.replace:
    - name: /etc/init.d/ank-webserver
    - pattern: portnumber
    - repl: {{ ank }}
    - require:
      - file: ank_init rehost

rootank rehost:
  file.replace:
    - name: /root/.autonetkit/autonetkit.cfg
    - pattern: portnumber
    - repl: {{ ank }}
    - require:
      - file: autonetkit_cfg rehost

ank-webserver service rehost:
  service:
    - running
    - name: ank-webserver
    - enable: True
    - restart: True
    - watch:
      - file: rootank rehost

apache overwrite renum:
  file.recurse:
    - name: /var/www/html
    - source: salt://files/virlweb
    - user: root
    - group: root
    - file_mode: 755

uwm port replace renum:
  file.replace:
    - name: /var/www/html/index.html
    - pattern: '19400'
    - repl: '{{ uwmport }}'
    - require:
      - file: apache overwrite renum
