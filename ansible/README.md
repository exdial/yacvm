# Ansible

Run `ansible-playbook site.yml` to deploy OpenVPN server.

By default the playbook doesn't create client config files, so
run `ansible-playbook site.yml -t client -e "clientname=foo"`
to generate them.


## Playbook stages
* `ansible-playbook site.yml -t setup`: Only provision the server. Configures
DNS, hostname, sysctl entries, firewall rules and installs required packages.
* `ansible-playbook site.yml -t genca`: Configures PKI, build CA (ca.crt).
* `ansible-playbook site.yml -t genserver`: Builds OpenVPN server
certificates (server.key, server.crt and ta.key).
* ` ansible-playbook site.yml -t configserver`: Configures OpenVPN server.
* `ansible-playbook site.yml -t client`: Configures OpenVPN client
certificates and download OpenVPN config (client.key, client.crt, client.ovpn)