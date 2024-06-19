Q1: How to install Docker Engine on Ubuntu host?

A1: To install Docker Engine on Ubuntu, you need the 64-bit version of one of these Ubuntu versions:
    Ubuntu Noble 24.04 (LTS), Ubuntu Jammy 22.04 (LTS), Ubuntu Focal 20.04 (LTS)

1. Run the following command to uninstall all unofficial/conflicting packages
```
   $ for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do sudo apt-get remove -y $pkg; done
```

2. Set up Docker's apt repository
```
   sudo apt-get update
   sudo apt-get install ca-certificates curl
   sudo install -m 0755 -d /etc/apt/keyrings
   sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
   sudo chmod a+r /etc/apt/keyrings/docker.asc
```
   # Add the repository to Apt sources:
```
   echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
        $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
   sudo apt-get update
```

3. Install the Docker packages
```
   sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
   sudo service docker start
```

4. Verify that the Docker Engine installation is successful by running the hello-world image.
```
   $ sudo docker run hello-world
```



Q2: Unable to connnect to registry-1.docker.io as below when creating a docker container?
```
    Step 1/15 : FROM debian:bookworm
    Get https://registry-1.docker.io/v2/: net/http: request canceled while waiting for connection (Client.Timeout exceeded while awaiting headers)
```

A2: This problem may be caused in various cases, users can try the methods below to fix it.
```
    Method 1: In case it needs a proxy to access external network, please set HTTP proxy for docker as below:
              a. add the following content in /etc/systemd/system/docker.service.d/http-proxy.conf
                 [Service]
                 Environment="HTTP_PROXY=http://127.0.0.1:3128"
                 Environment="HTTPS_PROXY=http://127.0.0.1:3128"
                 Environment="NO_PROXY=localhost,127.0.0.1,10.*"

              b. validate the settings above
                 sudo systemctl daemon-reload
                 sudo systemctl restart docker

    Method 2: modify the mirror source, e.g.
              a. sudo vi /etc/docker/daemon.json
                 {
                     "registry-mirrors":["https://docker.mirrors.ustc.edu.cn"]
                 }

              b. validate the settings above
                 sudo systemctl daemon-reload
                 sudo systemctl restart docker

    Method 3: add dns 8.8.8.8
              a. add "nameserver 8.8.8.8" in /etc/resolvconf/resolv.conf.d/head
	      b. update DNS as below
                 sudo resolvconf -u

    Method 4: search IP address for registry-1.docker.io
              a. install dig tool
                 sudo apt-get install -y dnsutils

              b. find the IP address
                 $ dig 8.8.8.8 registry-1.docker.io
                   ;; ANSWER SECTION:
                   registry-1.docker.io.   17      IN      A       18.214.230.110
                   registry-1.docker.io.   17      IN      A       34.238.187.50
                   registry-1.docker.io.   17      IN      A       3.209.182.229
                   registry-1.docker.io.   17      IN      A       54.85.56.253
              c. add IP address to hosts, e.g. add " 54.85.56.253 registry-1.docker.io" in /etc/hosts
```
