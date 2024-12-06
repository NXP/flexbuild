# Copyright 2024 NXP
#
# SPDX-License-Identifier: BSD-3-Clause

# NXP Demo Experience Launcher
# GoPoint on i.MX Application Processors

# https://github.com/nxp-imx-support/nxp-demo-experience

# Depend:
# qt6-base-dev qt6-wayland qt6-declarative-dev
# qml6-module-qtquick qml6-module-qtquick-controls qml6-module-qtquick-window qml6-module-qtquick-templates
# qml6-module-qtquick-layouts qml6-module-qtqml-workerscript qml6-module-qt5compat-graphicaleffects

imx_demo_experience:
	@[ $(SOCFAMILY) != IMX -o $(DISTROVARIANT) != desktop ] && exit || \
	 $(call fbprint_b,"imx_demo_experience") && \
	 $(call repo-mngr,fetch,imx_demo_experience,apps/gopoint) && \
	 export INSTALL_ROOT=$(DESTDIR) && \
	 export QT_SELECT=qt6 && \
	 if qtchooser -install qt6 /usr/bin/qmake6 | grep 'already exists'; then \
	     echo qtchooser: qt6 already exists; \
	 fi && \
	 cd $(GPDIR)/imx_demo_experience && \
	 qmake -makefile -o Makefile demoexperience.pro -spec linux-aarch64-gnu-g++ && \
	 sed -e "s|aarch64-linux-gnu-g++|aarch64-linux-gnu-g++ --sysroot=$(RFSDIR)|g" \
	     -e "s|/usr/lib/x86_64-linux-gnu|$(RFSDIR)/usr/lib/aarch64-linux-gnu|g" \
	     -e "s|/usr/include/x86_64-linux-gnu|$(RFSDIR)/usr/include/aarch64-linux-gnu|g" \
	     -e '/-spec linux-aarch64-gnu-g++/d' -i Makefile && \
	 $(MAKE) -j$(JOBS) && \
	 $(MAKE) -j$(JOBS) install && \
	 mv $(DESTDIR)/opt/demoexperience/bin/demoexperience $(DESTDIR)/usr/bin/ && \
	 rm -rf $(DESTDIR)/opt/demoexperience && \
	 ln -sf demoexperience $(DESTDIR)/usr/bin/gopoint && \
	 $(call fbprint_d,"imx_demo_experience")
