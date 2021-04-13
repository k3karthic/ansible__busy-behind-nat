# Access BUSY behind NAT

On certain ISPs like Jio, it is not possible to access a server over the interenet as Jio does not provide a public IPv4 address. This means that it is not possible to access [BUSY](https://busy.in/) using the provided [Mobile App](https://www.busywinsoftware.com/products/busy-mobile-app/).

## Run for Free

You can run the OpenVPN server for free by using the [Oracle Cloud Always Free](https://www.oracle.com/cloud/free/#always-free) tier. Terraform script for deploying a server can be found at [terraform__oci-instance-1](https://github.com/k3karthic/terraform__oci-instance-1).

## Region

Modify `inventory/oracle.oci.yml` and specify the region where you have deployed your server on Oracle Cloud.

## SSH Private Key

Copy your SSH private key for your server into the `ssh` folder as `oracle`. Alternatively, edit the `inventory/group_vars/all.yml` file and replace the value of `ansible_ssh_private_key_file` with the location of the private key.

## Encryption

Sensitive files like the SSH private keys are encrypted before being stored in the repository.

Use the following command to decrypt the files after cloning the repository,

```
./bin/decrypt.sh
```

Use the following command after running terraform to update the encrypted files,

```
./bin/encrypt.sh <gpg key id>
```
