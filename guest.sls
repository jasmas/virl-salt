{% set guestaccount = salt['grains.get']('guest_account', 'True') %}
{% set uwmpass = salt['grains.get']('uwmadmin_password', 'password') %}

{% if guestaccount == True %}

create guest account:
  virl_core.project_present:
    - name: guest
    - description: guest project
    - require:
      - cmd: virl-std start
      - cmd: virl-uwm start


fix guest password:
  virl_core.user_present:
    - name: guest
    - password: guest
    - project: guest
    - role: _member_
    - require:
      - virl_core: create guest account
{% else %}
delete guest account:
  virl_core.project_absent:
    - name: guest
    - clear_openstack: True
{% endif %}

virl-std start:
  cmd.run:
    - name: service virl-std start

virl-uwm start:
  cmd.run:
    - name: service virl-uwm start
