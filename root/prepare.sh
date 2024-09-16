#!/usr/bin/env bash
set -Eeuo pipefail
shopt -s inherit_errexit extglob nullglob globstar lastpipe shift_verbose

useradd podman --uid 50000 --home-dir /home/podman --shell /usr/bin/bash --create-home
chown podman:podman /var/lib/containers -R

cat <<-EOF >/etc/containers/containers.conf
	[containers]
	base_hosts_file = "none"
	log_driver = "none"
	no_hosts = false

	[engine]
	cgroup_manager = "cgroupfs"
	events_logger = "none"
	image_default_format = "oci"
	image_volume_mode = "tmpfs"
	network_cmd_options = ["allow_host_loopback=true", "port_handler=rootlesskit"]
EOF

cat <<-EOF >/etc/containers/storage.conf
[storage]
driver = "overlay"
rootless_storage_path="/var/lib/containers/storage"
EOF

cat <<-EOF >/etc/containers/registries.conf
	short-name-mode="enforcing"
EOF

rm -rf /etc/containers/registries.conf.d/
mkdir /etc/containers/registries.conf.d/
cat <<-EOF >/etc/containers/registries.conf.d/ghcr.conf
	[[registry]]
	location = "ghcr.io"
	insecure = false
	blocked = false
EOF

cat <<-EOF >/etc/subuid
podman:1:999
podman:1001:64535
EOF

cat <<-EOF >/etc/subgid
podman:1:999
podman:1001:64535
EOF
