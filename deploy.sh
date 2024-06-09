DOMAIN="k8s.lan"
DNS_INTERNAL_IP=$(openstack server show dns.${DOMAIN} -f json -c addresses | jq -r '.["addresses"]["kubernetes-the-hard-way"]|first')
openstack subnet set --dns-nameserver ${DNS_INTERNAL_IP} kubernetes