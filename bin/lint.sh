#!/usr/bin/env bash

ansible-lint -p site.yml roles/fail2ban roles/logrotate roles/openvpn
