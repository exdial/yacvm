# Ansible

Run `ansible-playbook main.yml` to deploy OpenVPN server.

By default the playbook doesn't create client config files, so
run `ansible-playbook main.yml -t client -e "clientname=foo"`
to generate them.


## Playbook stages
* `ansible-playbook main.yml -t setup`: Only provision the server. Configures
DNS, hostname, sysctl entries, firewall rules and installs required packages.
* `ansible-playbook main.yml -t genca`: Configures PKI, build CA (ca.crt).
* `ansible-playbook main.yml -t genserver`: Builds OpenVPN server
certificates (server.key, server.crt and ta.key).
* ` ansible-playbook main.yml -t configserver`: Configures OpenVPN server.
* `ansible-playbook main.yml -t client`: Configures OpenVPN client
certificates and download OpenVPN config (client.key, client.crt, client.ovpn)