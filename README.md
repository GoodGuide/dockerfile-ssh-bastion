# SSH bastion host docker image

This image runs SSH server with locked down permissions so connected clients can only use it as a bastion host to forward ports. Currently, the only means of supplying usernames/pubkeys is tied to Github public keys, so it expects a list of github usernames as runtime arguments:

```
docker run -d \
    --name=ssh-bastion \
    -p 2222:22 \
    -v $PWD/ssh_host_keys:/etc/ssh/ssh_host_keys \
    quay.io/goodguide/ssh-bastion \
    githubuser1 githubuser2
```

Host keys are in their own directory (`/etc/ssh/ssh_host_keys/`) which is a volume, so you can mount a local directory manually, if you want, for persistence of host keys.

The `sshd_config` is at its typical location for Ubuntu: `/etc/ssh/sshd_config`

The base is Ubuntu 15.10, via `quay.io/goodguide/base:ubuntu-15.10`

## Usage

See [contrib/ssh_config.example][ssh_config_example] for a comprehensive example SSH client configuration.

[ssh_config_example]: ./contrib/ssh_config.example.md
