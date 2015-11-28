#!/bin/bash
# vim: noexpandtab softtabstop=4 tabstop=4 shiftwidth=4:

set -e -u

trap 'exit 0' INT

create_key() {
	local file="$1"
	shift

	if [[ ! -f $file ]]; then
		ssh-keygen -q -f "$file" -N '' "$@"
	fi
	if [[ ! -f ${file}.pub ]]; then
		ssh-keygen -l -f "${file}.pub"
	fi
	if which restorecon >/dev/null 2>&1; then
		restorecon "$file" "${file}.pub"
	fi
}

create_keys() {
	mkdir -p /etc/ssh/ssh_host_keys
	create_key /etc/ssh/ssh_host_keys/rsa1_key -t rsa1
	create_key /etc/ssh/ssh_host_keys/rsa_key -t rsa
	create_key /etc/ssh/ssh_host_keys/dsa_key -t dsa
	create_key /etc/ssh/ssh_host_keys/ecdsa_key -t ecdsa
	create_key /etc/ssh/ssh_host_keys/ed25519_key -t ed25519
}

allow_github_user_via_ssh() {
	local ghuser="$1"

	echo "Adding user: ${ghuser}"
	useradd \
		--gid ssh-users \
		--home-dir /tmp \
		--no-user-group \
		--no-create-home \
		--shell /usr/sbin/nologin \
		"${ghuser}"

	mkdir -pv "/etc/ssh/per-user/${ghuser}/"
	curl -fsSL "https://github.com/${ghuser}.keys" > "/etc/ssh/per-user/${ghuser}/authorized_keys"

	echo 'Got the following keys:'
	cat "/etc/ssh/per-user/${ghuser}/authorized_keys" | (
		local i=0
		while read pubkey; do
			echo $pubkey > "${ghuser}_key_${i}.pub"
			ssh-keygen -E md5 -l -f "${ghuser}_key_${i}.pub"
			rm -f "${ghuser}_key_${i}.pub"
			((i++)) || true
		done
	)

	chown -c root:ssh-users "/etc/ssh/per-user/"
	chown -Rc ${ghuser}:ssh-users "/etc/ssh/per-user/${ghuser}/"
	chmod -Rc 0500 "/etc/ssh/per-user/${ghuser}/"
	chmod -c 0400 "/etc/ssh/per-user/${ghuser}/authorized_keys"
}

main() {
	# Regerate SSH Host Keys: n.b. Normally one could use `/usr/sbin/dpkg-reconfigure openssh-server`, but we're putting host keys in their own directory for docker volume mounting purposes
	create_keys

	if (( $# < 1 )); then
		echo 'Must supply a list of Github usernames to fetch keys automatically'
		exit 1
	fi

	for ghuser in $@; do
		allow_github_user_via_ssh "$ghuser"
	done

	echo
	echo '===== Starting SSHD ====='
	# n.b. Not using exec here as sshd doesn't die on SIGINT which is annoying when using docker run (see the trap at the top of the file)
	/usr/sbin/sshd -D -e
}

main "$@"
