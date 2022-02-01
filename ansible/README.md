# Ansible

Run `ansible-playbook site.yml` to deploy OpenVPN server.

By default the playbook doesn't create client config files, so
run `ansible-playbook site.yml -t client -e "clientname=foo"`
to generate them.
