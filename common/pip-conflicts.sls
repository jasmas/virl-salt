{% set http_proxy = salt['pillar.get']('virl:http_proxy', salt['grains.get']('http_proxy', 'https://proxy.esl.cisco.com:80/')) %}
{% set proxy = salt['pillar.get']('virl:proxy', salt['grains.get']('proxy', False)) %}

include:
  - common.pip

good six:
  pip.installed:
    - name: six >= 1.9.0
    {% if proxy == true %}
    - proxy: {{ http_proxy }}
    {% endif %}
    - upgrade: True
    - onlyif:
      - 'test -e /usr/local/bin/pip'

{% for each in ['six.py','six.pyc','six-1.5.2.egg-info'] %}
remove old {{each}}:
  file.absent:
    - name: /usr/lib/python2.7/dist-packages/{{ each }}
    - require: 
      - pip: good six
{% endfor %}

