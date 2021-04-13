#!/usr/bin/env bash

ansible all -i inventory/oracle.oci.yml -a "/bin/echo hello"
