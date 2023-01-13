#!/usr/bin/python3

import sys
import json
infile = sys.argv[1]


print("""
---
- hosts: localhost
  become: yes
  gather_facts: no
  tasks:
""")

with open(infile, 'r') as file:
    bindings = json.load(file)
    for binding in bindings.values():
        ec_command = f"adaptive reset --binding {binding['binding'].rsplit('/',1)[-1]} --domain {binding['domain']}"
        host = binding["host"]
        list_command = f"adaptive list --binding {binding['binding'].rsplit('/',1)[-1]} --domain {binding['domain']}"
        print(f'''\
    - name: {host} {binding['binding']} {binding['domain']}
      ansible.builtin.command:
          stdin: |
            {ec_command}
          cmd: /opt/msys/ecelerity/bin/ec_console
      delegate_to: {host}
    - name: {host} {binding['binding']} {binding['domain']} 2nd attempt
      ansible.builtin.command:
          stdin: |
            {ec_command}
          cmd: /opt/msys/ecelerity/bin/ec_console
      delegate_to: {host}
    - name: {host} {binding['binding']} {binding['domain']} list
      ansible.builtin.command:
          stdin: |
            {ec_command}
          cmd: /opt/msys/ecelerity/bin/ec_console
      delegate_to: {host} 
            ''')