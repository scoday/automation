{% for usr in 'sday','mday','kday' %}
{{ usr }}:
  user:
    - present
    - fullname: {{ usr }}
    - home: True
    - shell: /bin/bash
    # group names for sudo very by platform
    - optional_groups:
      - admin
      - ubuntu
      - wheel
  ssh_auth:
    - present
    - user: {{ usr }} 
    - source: salt://users/keys/{{ usr }}_id_rsa.pub
    - require:
      - user: {{ usr }}
{% endfor %} 






{% for host in 'app1.scoday.com','app2.scoday.com','app3.scoday.com'}
{{ host }}:
  host:
    - present
    - 
