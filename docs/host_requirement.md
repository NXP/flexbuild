## Host system requirement
- Ubuntu LTS (e.g. 22.04, 20.04) or any other distro on which Docker is running (Refer to docs/FAQ-docker-setup.md)
- Debian 12 host


For root users, there is no limitation for the build.
For non-root users, obtain sudo permission by executing "sudoedit /etc/sudoers" and adding a line as below
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
