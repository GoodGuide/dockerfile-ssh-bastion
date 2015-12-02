# Deployment on CoreOS

## Security

1. Set up some settings on the new CoreOS box:

    ```shell
    # Run all this on the CoreOS host

    # Disable Docker's enabled-by-default inter-container communication:
    #   See here for more info: http://docs.docker.com/engine/userguide/networking/default_network/container-communication/#communication-between-containers
    sed 's:dockerd --daemon:dockerd --icc=false --iptables=true --daemon' < /usr/lib/systemd/usr/lib/systemd/system/docker.service > /etc/systemd/system/docker.service
    sudo systemctl daemon-reload
    sudo systemctl reload-or-try-restart docker.service

    # Prohibit traffic to the host from within the container:
    sudo iptables -C INPUT -i docker0 -j DROP

    # Add the github usernames you want to allow to connect to etcd
    etcdctl set /ssh-bastion/usernames 'user1 user2 ...'
    ```

4. Use fleetctl to start the service (from your local workstation):

    ```
    cd contrib/systemd/
    ssh -L 2379:localhost:2379 core@bastion.host.name -N &
    FLEETCTL_ENDPOINT='http://localhost:2379' FLEETCTL_DRIVER=etc fleetctl start ssh-bastion.service
    kill %1
    ```
