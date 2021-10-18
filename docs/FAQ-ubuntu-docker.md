
Q1: Unable to connnect to registry-1.docker.io as below while creating an Ubuntu-20.04 docker by command 'bld docker'?
```
    Step 1/15 : FROM ubuntu:20.04
    Get https://registry-1.docker.io/v2/: net/http: request canceled while waiting for connection (Client.Timeout exceeded while awaiting headers)
```

A1: This problem may be caused in various cases, users can try the methods below to fix it.
```
    Method 1: In case it needs a proxy to access external network, please set HTTP proxy for docker as below:
              a. add the following content in /etc/systemd/system/docker.service.d/http-proxy.conf
                 [Service]
                 Environment="HTTP_PROXY=http://127.0.0.1:3128"
                 Environment="HTTPS_PROXY=http://127.0.0.1:3128"
                 Environment="NO_PROXY=localhost,127.0.0.1,10.*,*.swis.us-cdc01.nxp.com"

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
