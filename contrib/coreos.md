# Deployment on CoreOS

## Security

1. Disable Docker's enabled-by-default inter-container communication:

    ```
    sed 's:dockerd --daemon:dockerd --icc=false --iptables=true --daemon' < /usr/lib/systemd/usr/lib/systemd/system/docker.service > /etc/systemd/system/docker.service
    ```

    See here for more info: <http://docs.docker.com/engine/userguide/networking/default_network/container-communication/#communication-between-containers>

2. Prohibit traffic to the host from within the container:

    ```
    sudo iptables -C INPUT -i docker0 -j DROP
    ```
