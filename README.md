# Ansible - Access BUSY behind NAT

On certain ISPs like Jio, it is impossible to access a server over the internet as the ISP does not provide a public IPv4 address. This means that it is not possible to access [BUSY](https://busy.in/) using the provided [Mobile App](https://www.busywinsoftware.com/products/busy-mobile-app/).

The Ansible playbook in this repository creates a private OpenVPN network which will allow the [BUSY Mobile App](https://www.busywinsoftware.com/products/busy-mobile-app/) to connect to the [BUSY server](https://busy.in/) using the "LAN" profile.

## Solution Overview

The Ansible playbook in this repository creates a private OpenVPN network between a phone and the server. To access the server over the internet, configure the BUSY mobile app to connect to the server using the "LAN" profile and provide the server's IP address on the virtual network.

![Architecture Diagram](https://github.com/k3karthic/ansible__busy-behind-nat/raw/main/resources/solution_overview.png)

Configuration of BUSY application,

![BUSY App Configuration](https://github.com/k3karthic/ansible__busy-behind-nat/raw/main/resources/mobile_config.jpeg)

## Deploy for Free

You can run the OpenVPN server for free by using the [Oracle Cloud Always Free](https://www.oracle.com/cloud/free/#always-free) tier. Terraform script for deploying a server can be found at [terraform__oci-instance-1](https://github.com/k3karthic/terraform__oci-instance-1).

Basic setup (e.g. swap, fail2ban) is assumed to have been performed using the Ansible playbook at [https://github.com/k3karthic/ansible__ubuntu-basic](https://github.com/k3karthic/ansible__ubuntu-basic).

You can configure a free static hostname for the OpenVPN server using the Ansible playbook at [https://github.com/k3karthic/ansible__oci-ydns](https://github.com/k3karthic/ansible__oci-ydns).

### Requirements

Install the following Ansible modules before running the playbook,
```
pip install oci
ansible-galaxy collection install oracle.oci
```

### Dynamic Inventory

This playbook uses the Oracle [Ansible Inventory Plugin](https://docs.oracle.com/en-us/iaas/Content/API/SDKDocs/ansibleinventoryintro.htm) to populate public Ubuntu instances dynamically.

Public instances are assumed to have a freeform tag `openvpn_service: yes`.

## Certificate Authority Setup

To allow the OpenVPN server and clients to communicate securely, we need to create a Certificate Authority (CA). A key signing server is used to generate and sign certificates that the OpenVPN server and client will use for authentication.

For security, the key signing server should be a standalone server, but the OpenVPN server can act as the key signing server for smaller deployments. 

To get started, install [easy-rsa](https://github.com/OpenVPN/easy-rsa) on the system you will be using as the key signing server.

### Initialize easy-rsa

Run the following commands on the key signing server to create a new Public Key Infrastructure (PKI) and CA.
```
./easyrsa init-pki
./easyrsa build-ca
```

### Create files for OpenVPN server

Run the following commands on the key signing server to create and sign a certificate for the OpenVPN server,
```
./easyrsa gen-req Relay
./easyrsa sign-req server Relay
```

Generate the Diffie-Hellman (DH) parameters for the OpenVPN server,
```
./easyrs gen-dh
```

Copy `pki/ca.crt` and `pki/dh.pem` into the `ca` folder of the current repository. Create a file called `ca/Relay.pass` with the passphrase of the Relay private key (Relay.key).

Install OpenVPN on the key signing server and run the following command. This is only required to generate a shared secret for TLS authentication.
```
openvpn --genkey --secret ta.key
```

Copy `ta.key` into the `ca` folder of the current directory.

### Create files for BUSY server

Run the following commands on the key signing server to create and sign a certificate for the BUSY server,
```
./easyrsa gen-req BUSY
./easyrsa sign-req client BUSY
```

Copy `pki/ca.crt`, `pki/ta.key`, `pki/private/BUSY.key`, `pki/issues/BUSY.crt` to the BUSY server. Create a file called `BUSY.pass` with the passphrase of the BUSY private key (BUSY.key).

### Create files for BUSY App

Run the following commands on the key signing server to create and sign a certificate for the BUSY App,
```
./easyrsa gen-req BUSYMobile1
./easyrsa sign-req client BUSYMobile1
```

Copy `pki/ca.crt`, `pki/ta.key`, `pki/private/BUSYMobile1.key`, `pki/issues/BUSYMobile1.crt` to the phone. Remember to enter the passphrase of the private key (BUSYMobile1.key) either during import or by editing the configuration.

## Playbook Configuration

1. Modify `inventory/oracle.oci.yml`
    1. specify the region where you have deployed your server on Oracle Cloud.
    1. Configure the authentication as per the [Oracle Guide](https://docs.oracle.com/en-us/iaas/Content/API/Concepts/sdkconfig.htm#SDK_and_CLI_Configuration_File).
1. Set username and ssh authentication in `inventory/group_vars/all.yml`.
1. Change the CIDR of the virtual network (172.23.0.0/16) to ensure it does not overlap with your local network.

## Deployment

Run the playbook using the following command,
```
./bin/apply.sh
```

## Client Configuration

The following sample configuration files are provided in the `resources` directory,
1. *BUSY.ovpn*: configuration for the BUSY server running [OpenVPN Community](https://openvpn.net/community/).
2. *BUSYMobile1.ovpn*: configuration for the phone running BUSY mobile app and [OpenVPN](https://play.google.com/store/apps/details?id=de.blinkt.openvpn&hl=en&gl=US).

Replace the hostname of the OpenVPN server. Change the virtual IP (172.23.0.X) if required.

On the BUSY server, ensure the firewall allows incoming connections from the OpenVPN virtual network interface.

## Encryption

Sensitive files like the SSH private keys are encrypted before being stored in the repository.

You must add the unencrypted file paths to `.gitignore`.

Use the following command to decrypt the files after cloning the repository,

```
./bin/decrypt.sh
```

Use the following command after running terraform to update the encrypted files,

```
./bin/encrypt.sh <gpg key id>
```
