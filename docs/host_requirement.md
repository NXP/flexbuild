## Host system requirement
- Ubuntu 20.04 LTS should be installed on the host machine.
  (If this requirement is not fulfilled, see "Emulate Ubuntu 20.04 environment using Docker container" or
   "Install Ubuntu 20.04 LTS via WSL (Windows Subsystem for Linux) on Windows 10" below.

- For root users, there is no limitation for the build.

- For non-root users, obtain sudo permission by executing "sudoedit /etc/sudoers" and adding a line as below
```
     <account-name> ALL=(ALL:ALL) NOPASSWD: ALL
```

- The host machine is able to access to the external Internet in user's network environment.



### Emulate Ubuntu 20.04 environment using Docker container (optional)
If a Linux distribution other than Ubuntu 20.04 is installed on the host machine,
users can follow the steps below to create an Ubuntu 20.04 Docker container to emulate the environment. 
Please refer to [Install Docker on the host machine](https://docs.docker.com/engine/installation) for
information on how to install Docker on the host machine.


Users must have sudo permission for Docker commands or be added to docker group as below,
Change current group to "docker", add account to it and restart docker service:
```
$ sudo newgrp - docker
$ sudo usermod -aG docker <accountname>
$ sudo gpasswd -a <accountname> docker
$ sudo service docker restart
```


### Install Ubuntu 20.04 LTS via WSL (Windows Subsystem for Linux) on Windows 10 (optional)
If users have a Windows 10 machine and have no any available Linux machine, it is feasible to install Ubuntu 20.04
LTS via WSL 2 on Windows 10, refer to [the steps](https://docs.microsoft.com/en-us/windows/wsl/install-win10)

If you work with WSL 2, entering "\\WSL$" in Windows Resource Manager will quickly navigate to the WSL Ubuntu 20.04
workplace folder. You also can connect to WSL Ubuntu 20.04 via ssh to work in multiple windows if needed.


NOTE:
If user's Linux host machine is in a subnet that needs HTTP(s) proxy to access external Internet, it needs to set
environment variable http_proxy and https_proxy according to [this step](proxy.md)
