# Copyright 2023-2024 NXP
#
# SPDX-License-Identifier: BSD-3-Clause

# Tensors and Dynamic neural networks in Python with strong GPU acceleration

# RDEPENDS: python3-core python3-numpy python3-future python3-typing-extensions numactl

PV = "2.0.0"
PYV = "cp311"
PYTHON_SITEPACKAGES_DIR = "/usr/lib/python3.11/site-packages"


pytorch:
	@[ $(DESTARCH) != arm64 -o $(DISTROVARIANT) = tiny -o $(DISTROVARIANT) = base ] && exit || \
	 if ! grep -q Debian /etc/issue; then $(call fbprint_w,"Please build on Debian host") && exit; fi && \
	 $(call fbprint_b,"pytorch") && \
	 $(call repo-mngr,fetch,pytorch,apps/ml) && \
	 cd $(MLDIR)/pytorch && \
	 install -d $(DESTDIR)/$(PYTHON_SITEPACKAGES_DIR) && \
	 install -d $(DESTDIR)/usr/bin/pytorch/examples && \
	 install -m 0555 examples/* $(DESTDIR)/usr/bin/pytorch/examples && \
	 install -m 0555 src/build.sh $(DESTDIR)/usr/bin/pytorch && \
	 pip3 install --ignore-installed --disable-pip-version-check -v --platform linux_aarch64 \
	      -t $(DESTDIR)/$(PYTHON_SITEPACKAGES_DIR) --no-cache-dir --no-deps whl/torch-$(PV)-$(PYV)*.whl && \
	 mv $(DESTDIR)/$(PYTHON_SITEPACKAGES_DIR)/bin/* $(DESTDIR)/usr/bin && \
	 rm -rf $(DESTDIR)/$(PYTHON_SITEPACKAGES_DIR)/bin && \
	 rm -rf $(DESTDIR)/$(PYTHON_SITEPACKAGES_DIR)/torch/bin/test_cpp_rpc &&\
	 $(call fbprint_d,"pytorch")
