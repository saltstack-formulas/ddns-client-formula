# This state installs the ddns script and the cronjob

{% from "ddns-client/map.jinja" import map with context %}

# install required packages
ddns_client_packages:
  pkg.installed:
    - pkgs:
      {% for pkg in map.pkgs %}
      - {{ pkg }}
      {% endfor %}  

# ddns script
ddns_client_scipt:
  file.managed:
    - source: salt://ddns-client/files/ddns.sh.jinja
    - template: jinja
    - name: {{ map.script_dir }}/ddns.sh
    - mode: {{ map.mode }}
    - user: {{ map.user }}
    - group: {{ map.group }}  
    - context:
      config: {{ pillar.ddns_client }}
      script_dir: {{ map.script_dir }}  

# key file
ddns_client_key_file:
  file.managed:
    - name: {{ map.script_dir }}/tsig.key
    - mode: {{ map.mode }}
    - user: {{ map.user }}
    - group: {{ map.group }}  
    - contents: |
{{ pillar.ddns_client.key |indent(8, True) }}

{% set update_frequency = salt['pillar.get']('ddns_client:update_frequency', '5') %}

{%- if salt['pillar.get']('ddns_client:symlinks', False) %}
{# if symlinks is configured create all given links #}

{%- for symlink in salt['pillar.get']('ddns_client:symlinks', []) %}
ddns_client_symlinks_{{ loop.index }}:
  file.symlink:
    - name: {{ symlink }}
    - target: {{ map.script_dir }}/ddns.sh
      
{%- endfor %}

{%- else %}
{# if symlinks is not configured create cronjob #}

ddns_client_cronjob:
  file.managed:
    - name: {{ map.cronjob_dir }}/ddns
    - contents: |
        */{{ update_frequency }} * * * * {{ map.user }} {{ map.script_dir }}/ddns.sh

{%- endif %}
