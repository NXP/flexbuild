FROM debian:trixie

ARG http_proxy
ARG https_proxy
ARG no_proxy

ENV http_proxy=${http_proxy} \
    https_proxy=${https_proxy} \
    no_proxy=${no_proxy} \
    HTTP_PROXY=${http_proxy} \
    HTTPS_PROXY=${https_proxy} \
    NO_PROXY=${no_proxy} \
    DEBIAN_FRONTEND=noninteractive \
    DEBCONF_NONINTERACTIVE_SEEN=true


RUN set -eux; \
    mkdir -p /etc/apt/apt.conf.d && \
    { \
      if [ -n "${http_proxy:-}" ]; then \
        echo "Acquire::http::proxy \"${http_proxy}\";"; \
        echo "Acquire::https::proxy \"${https_proxy:-$http_proxy}\";"; \
      fi; \
      echo "Acquire::Retries \"5\";"; \
      echo "Acquire::http::Timeout \"20\";"; \
      echo "Acquire::https::Timeout \"20\";"; \
    } > /etc/apt/apt.conf.d/01proxy && \
    echo 'PS1="[\u@\h \W]\$ "' >> /root/.bashrc && \
    echo "syntax on" > /root/.vimrc

RUN set -eux; \
    apt-get update && \
    apt-get install -y --no-install-recommends \
      locales \
      sudo arch-test gpg vim rename xxd autopoint valac hwdata cpio debhelper-compat \
      build-essential git wget curl rsync ccache pkg-config lsb-release \
      autoconf automake libtool cmake meson ninja-build \
      gawk gettext zip unzip xz-utils zstd ruby efitools \
      crossbuild-essential-arm64 gcc-aarch64-linux-gnu g++-aarch64-linux-gnu binutils-aarch64-linux-gnu \
      device-tree-compiler u-boot-tools bc flex bison lzop && \
    localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8 && \
    rm -rf /var/lib/apt/lists/*


RUN set -eux; \
    apt-get update && \
    apt-get install -y --no-install-recommends \
      qemu-user-static binfmt-support kmod \
      mmdebstrap debian-archive-keyring \
      qt6-base-dev qt6-base-dev-tools qt6-declarative-dev qtchooser \
      libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev \
      libwayland-dev libwayland-bin xutils-dev \
      libssl-dev openssl libusb-1.0-0-dev \
      libzstd-dev libbz2-dev libzip-dev libglib2.0-dev \
      libgnutls28-dev libcanberra-dev \
      python3 python3-dev python3-pip python3-wheel python3-pybind11 \
      python3-yaml python3-pyelftools python3-requests python3-tqdm \
      python3-jinja2 python3-ply python3-numpy \
      protobuf-compiler libgdk-pixbuf-2.0-dev libxml2-utils libprotobuf-dev \
      gtk-doc-tools pandoc && \
    rm -rf /var/lib/apt/lists/*

RUN git config --global user.email  "debian@nxp.com"
RUN git config --global user.name "NXP debian"