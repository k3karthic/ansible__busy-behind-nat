# Ansible - Access BUSY behind NAT

On certain ISPs like Jio, it is not possible to access a server over the interenet as the ISP does not provide a public IPv4 address. This means that it is not possible to access [BUSY](https://busy.in/) using the provided [Mobile App](https://www.busywinsoftware.com/products/busy-mobile-app/).

The Ansible playbook in this repository creates a private OpenVPN network which will allow the [BUSY Mobile App](https://www.busywinsoftware.com/products/busy-mobile-app/) to connect to the [BUSY](https://busy.in/) server using the "LAN" profile.

**Assumption:** Basic server setup has been completed using the playbook [https://github.com/k3karthic/ansible__ubuntu-basic](https://github.com/k3karthic/ansible__ubuntu-basic).

## Solution Overview

The Ansible playbook in this repository creates a private OpenVPN network between a phone and the server. To access the server over the internet, configure the BUSY app to connect to the server using the "LAN" profile and provide the server's IP address on the virtual network.

![Architecture Diagram](https://github.com/k3karthic/ansible__busy-behind-nat/raw/main/resources/solution_overview.png)

Configuration of BUSY application,

![BUSY App Configuration](https://github.com/k3karthic/ansible__busy-behind-nat/raw/main/resources/mobile_config.jpeg)

## Deploy for Free

You can run the OpenVPN server for free by using the [Oracle Cloud Always Free](https://www.oracle.com/cloud/free/#always-free) tier. Terraform script for deploying a server can be found at [terraform__oci-instance-1](https://github.com/k3karthic/terraform__oci-instance-1).

Basic setup (swap, fail2ban) is assumbed to have been performed using the Ansible playbook at [https://github.com/k3karthic/ansible__ubuntu-basic](https://github.com/k3karthic/ansible__ubuntu-basic).

One can configure a free static hostname for the OpenVPN server using the Ansible playbook at [https://github.com/k3karthic/ansible__oci-ydns](https://github.com/k3karthic/ansible__oci-ydns).

## PKI Setup

To allow the OpenVPN server and clients to securely communicate with each other we need to establish a Public Key Infrastructure (PKI). A key signing server is used to generate and sign certificates that the OpenVPN server and client will use for authentication.

For security, the key signinig server should be a standalone server, but the OpenVPN server can act as the key signinig server as well for smaller deployments. 

To get started, install [easy-rsa](https://github.com/OpenVPN/easy-rsa) on the system you will be using as the key signing server.

### Key Signinig Server

Run the following commands to create a new PKI and Certificate Authority (CA),
```
./easyrsa init-pki
./easyrsa build-ca
```

### OpenVPN Server

Create and sign a certificate for the OpenVPN server,
```
./easyrsa gen-req Relay
./easyrsa sign-req Relay
```

Generate the Diffie-Hellman (DH) parameters for the OpenVPN server,
```
./easyrs gen-dh
```

Copy `pki/ca.crt` and `pki/dh.pem` into the `ca` folder of the current repository.

Install OpenVPN on the key signinig server and run the following command. This is only required to generate a shared secret for TLS authentication.
```
openvpn --genkey --secret ta.key
```

Copy `ta.key` into the `ca` folder of the current directory.

### BUSY Server

Create and sign a certificate for the BUSY server,
```
./easyrsa gen-req BUSY
./easyrsa sign-req BUSY
```

Copy `pki/ca.crt`, `pki/ta.key`, `pki/private/BUSY.key`, `pki/issues/BUSY.crt` to the BUSY server.

### BUSY App

Create and sign a certificate for the BUSY App,
```
./easyrsa gen-req BUSYMobile1
./easyrsa sign-req BUSYMobile1
```

Copy `pki/ca.crt`, `pki/ta.key`, `pki/private/BUSYMobile1.key`, `pki/issues/BUSYMobile1.crt` to the phone.

## Dynamic Inventory

This playbook uses the Oracle [Ansible Inventory Plugin](https://docs.oracle.com/en-us/iaas/Content/API/SDKDocs/ansibleinventoryintro.htm) to dynamically populate public Ubuntu instances.

Public instances with are assumed to have a freeform tag `openvpn_service: yes`.

## Configuration

1. Modify `inventory/oracle.oci.yml`
    1. specify the region where you have deployed your server on Oracle Cloud.
    1. Configure the authentication as per the [Oracle Guide](https://docs.oracle.com/en-us/iaas/Content/API/Concepts/sdkconfig.htm#SDK_and_CLI_Configuration_File).
1. Set username and ssh authentication in `inventory/group_vars/all.yml`.
2. Set username and password for YDNS in `inventory/group_vars/ydns.yml` using the sample `inventory/group_vars/ydns.yml.sample`.

## Run

```
./bin/apply.sh
```

## Client Configuration

The following sample configuration files are provided in the `resources` directory,
1. *BUSY.ovpn*: configuration for the BUSY server running [OpenVPN Community](https://openvpn.net/community/).
2. *BUSYMobile1.ovpn*: configuration for the phone running BUSY App and [OpenVPN](https://play.google.com/store/apps/details?id=de.blinkt.openvpn&hl=en&gl=US).

Replace the hostname of the OpenVPN server.

On the BUSY server, ensure the firewall allows incoming connections from the OpenVPN virtual network interface.

## Encryption

Sensitive files like the SSH private keys are encrypted before being stored in the repository.

The unencrypted file paths must be added to `.gitignore`.

Use the following command to decrypt the files after cloning the repository,

```
./bin/decrypt.sh
```

Use the following command after running terraform to update the encrypted files,

```
./bin/encrypt.sh <gpg key id>
```
