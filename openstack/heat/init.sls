{% set public_ip = salt['pillar.get']('virl:static_ip', salt['grains.get']('static_ip', '127.0.0.1' )) %}
{% set heatpassword = salt['pillar.get']('virl:heatpassword', salt['grains.get']('password', 'password')) %}
{% set ospassword = salt['pillar.get']('virl:password', salt['grains.get']('password', 'password')) %}
{% set mypassword = salt['pillar.get']('virl:mysql_password', salt['grains.get']('mysql_password', 'password')) %}
{% set hostname = salt['pillar.get']('virl:hostname', salt['grains.get']('hostname', 'virl')) %}
{% set controllerip = salt['pillar.get']('virl:internalnet_controller_IP',salt['grains.get']('internalnet_controller_ip', '172.16.10.250')) %}

heat-pkgs:
  pkg.installed:
    - order: 1
    - refresh: false
    - names:
      - heat-api
      - heat-api-cfn
      - heat-engine

/etc/heat:
  file.directory:
    - dir_mode: 755


heat-conn:
  openstack_config.present:
    - filename: /etc/heat/heat.conf
    - section: 'database'
    - parameter: 'connection'
    - value: 'mysql://heat:{{ mypassword }}@{{ controllerip }}/heat'

heat-rabbitpass:
  openstack_config.present:
    - filename: /etc/heat/heat.conf
    - section: 'DEFAULT'
    - parameter: 'rabbit_password'
    - value: '{{ ospassword }}'


heat-hostname:
  file.replace:
    - name: /etc/heat/heat.conf
    - pattern: 'controller'
    - repl: '{{ hostname }}'

heat-publicip:
  file.replace:
    - name: /etc/heat/heat.conf
    - pattern: 'PUBLICIP'
    - repl: '{{ public_ip }}'

heat-verbose:
  file.replace:
    - name: /etc/heat/heat.conf
    - pattern: 'verbose=True'
    - repl: 'verbose=False'

heat-password:
  file.replace:
    - name: /etc/heat/heat.conf
    - pattern: 'HEAT_PASS'
    - repl: '{{ heatpassword }}'

/var/lib/heat/heat.sqlite:
  file.absent:
    - name: /var/lib/heat/heat.sqlite

heat-restart:
  cmd.run:
    - name: |
        heat-manage db_sync
        service heat-api restart
        service heat-api-cfn restart
        service heat-engine restart
