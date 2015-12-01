# Example Client Config

For the sake of this example, let's assume this container is deployed as in the following `docker run` command, on a server resolvable under the domain name `bastion-1.domain.com`, and that your github username is `myGithubUser`

```shell
$ docker run --name bastion -d -p 2222:22 quay.io/goodguide/ssh-bastion myGithubUser ...
```

Here's an example snippet to be used in your `~/.ssh/config`, which will automatically connect _via_ the bastion, when both the `USE_SSH_BASTION` variable is set in your shell as well as your connecting to a host on EC2. Your use case may be different, in which case I'd encourage you to customize the `Match` block to your needs [(see `Match` in `man ssh_config(5)`)][ssh_config_manpage].

```apache
# ~/.ssh/config
Host bastion
  # Set the real hostname; this can also be an IP address if you don't have a
  # DNS record for this server
  HostName bastion-1.domain.com

  Port         2222
  User         myGithubUser
  IdentityFile {{your github key}}
  StrictHostKeyChecking yes

  # explicitly disable ProxyCommand to prevent infinite recursion
  ProxyCommand none

  # these settings are not strictly necessary, but help make it explicit that
  # you're never going to open a shell on this host
  ForwardAgent no
  ForwardX11 no
  RequestTTY no
  ExitOnForwardFailure yes

  ControlMaster  auto
  ControlPath    ~/.ssh/control_sockets/%h_%p_%r
  ControlPersist no

# only use the bastion host for EC2 remotes and only when the USE_SSH_BASTION
# variable is set in the shell invoking `ssh`
Match Exec "bash -c '[[ $USE_SSH_BASTION ]]'" Host *.amazonaws.com
  ProxyCommand ssh -W %h:%p bastion
```

Also of note, here, the `ControlMaster`, `ControlPath`, and `ControlPersist` options are optional, but recommended for this use-case, as they enable automatic connection sharing for the bastion connection, which you may want if you're using it to connect to multiple hosts simultaneously. **Note: if you do use these options, you must ensure the `~/.ssh/control_sockets` directory exists.**

The `USE_SSH_BASTION` variable name is arbitrary, for this example.

[ssh_config_manpage]: http://manpages.ubuntu.com/manpages/trusty/man5/ssh_config.5.html
