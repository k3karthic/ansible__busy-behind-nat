# Access BUSY behind NAT

On certain ISPs like Jio, it is not possible to access a server over the interenet as Jio does not provide a public IPv4 address. This means that it is not possible to access [BUSY](https://busy.in/) using the provided [Mobile App](https://www.busywinsoftware.com/products/busy-mobile-app/).

The Ansible playbook in this repository creates a private OpenVPN network which will allow the [BUSY Mobile App](https://www.busywinsoftware.com/products/busy-mobile-app/) to connect to the [BUSY](https://busy.in/) server using the "LAN" profile.

**Assumption:** Basic server setup has been completed using the playbook [https://github.com/k3karthic/ansible__ubuntu-basic](https://github.com/k3karthic/ansible__ubuntu-basic).

## Solution Overview

The Ansible playbook in this repository creates a private OpenVPN network between a phone and the server. To access the server over the internet, configure the BUSY app to connect to the server using the "LAN" profile and provide the server's IP address on the virtual network.

![Architecture Diagram](https://github.com/k3karthic/ansible__busy-behind-nat/raw/main/resources/solution_overview.png)

## Deploy for Free

You can run the OpenVPN server for free by using the [Oracle Cloud Always Free](https://www.oracle.com/cloud/free/#always-free) tier. Terraform script for deploying a server can be found at [terraform__oci-instance-1](https://github.com/k3karthic/terraform__oci-instance-1).

## Configuration

1. Modify `inventory/oracle.oci.yml`
    1. specify the region where you have deployed your server on Oracle Cloud.
    1. Configure the authentication as per the [Oracle Guide](https://docs.oracle.com/en-us/iaas/Content/API/Concepts/sdkconfig.htm#SDK_and_CLI_Configuration_File).
1. Set username in `inventory/group_vars/all.yml`

## SSH Private Key

Copy your SSH private key for your server into the `ssh` folder as `oracle`. Alternatively, edit the `inventory/group_vars/all.yml` file and replace the value of `ansible_ssh_private_key_file` with the location of the private key.

## Run

Before running the playbook, install the following modules from Ansible Galaxy,

```
ansible-galaxy collection install community.general
```

Run the playbook using the following command,

```
./bin/apply.sh
```

## Encryption

Sensitive files like the SSH private keys are encrypted before being stored in the repository. The unencrypted file paths must be added to `.gitignore`.

Use the following command to decrypt the files after cloning the repository,

```
./bin/decrypt.sh
```

Use the following command after running terraform to update the encrypted files,

```
./bin/encrypt.sh <gpg key id>
```
