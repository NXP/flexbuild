## Host system requirement
- Debian 12 host

- Ubuntu LTS host (e.g. 22.04, 20.04) on which Docker Engine is running (Refer to docs/FAQ-docker-setup.md)

- If other distro version is installed on your host machine, you can run 'bld docker' to create a Debian 12 docker and build it in docker.

- For root users, there is no limitation for the build.

- For non-root users, obtain sudo permission by executing "sudoedit /etc/sudoers" and adding a line as below
```
     <account-name> ALL=(ALL:ALL) NOPASSWD: ALL
```

- The host machine must can access to the external Internet in your network environment.



Users must have sudo permission for Docker commands or be added to docker group as below,
Change current group to "docker", add account to it and restart docker service:
```
$ sudo newgrp - docker
$ sudo usermod -aG docker <accountname>
$ sudo gpasswd -a <accountname> docker
$ sudo service docker restart
```

NOTE:
If your Linux host machine is in a subnet that needs HTTP(s) proxy to access external Internet, it needs to set
environment variable http_proxy and https_proxy according to [this step](proxy.md)
