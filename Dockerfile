FROM quay.io/goodguide/base:ubuntu-15.10-0

RUN apt-get update \
 && apt-get install \
      openssh-server \

 # Delete the host keys it just generated. At runtime, we'll regenerate those
 && rm -vf /etc/ssh/ssh_host_*

# Set up ssh server
RUN mkdir -pv /var/run/sshd \
 && groupadd ssh-users

COPY etc/ssh/* /etc/ssh/
COPY etc/pam.d/* /etc/pam.d/
COPY entrypoint.sh /usr/local/bin/start_sshd

VOLUME ["/etc/ssh/ssh_host_keys"]
EXPOSE 22
ENTRYPOINT ["/usr/local/bin/start_sshd"]
