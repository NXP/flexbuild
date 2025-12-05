# Copyright 2021-2025 NXP
#
# SPDX-License-Identifier: BSD-3-Clause

# i.MX M4/M7/M33 core Demo images



mcore_demo:
	@[ $(SOCFAMILY) != IMX -a $${MACHINE:0:5} = imx91 ] && exit || \
	echo -e "\nInstalling mcore demos for $(MACHINE)" && \
	mkdir -p $(UTILSDIR)/mcore_demo && \
	cd $(UTILSDIR)/mcore_demo && \
	case $(MACHINE) in \
		imx8mm*) \
			$(call dl_by_wget,imx8mm_mdemo,imx8mm-m4-demo.bin); \
			_SOC=imx8mm && _NAME=imx8mm-m4-demo; \
			;; \
		imx8mp*) \
			$(call dl_by_wget,imx8mp_mdemo,imx8mp-m7-demo.bin); \
			_SOC=imx8mp && _NAME=imx8mp-m7-demo; \
			;; \
		imx8mq*) \
			$(call dl_by_wget,imx8mq_mdemo,imx8mq-m4-demo.bin); \
			_SOC=imx8mq && _NAME=imx8mq-m4-demo; \
			;; \
		imx8mn*) \
			$(call dl_by_wget,imx8mn_mdemo,imx8mn-m7-demo.bin); \
			_SOC=imx8mn && _NAME=imx8mn-m7-demo; \
			;; \
		imx8ulp*) \
			$(call dl_by_wget,imx8ulp_mdemo,imx8ulp-m33-demo.bin); \
			_SOC=imx8ulp && _NAME=imx8ulp-m33-demo; \
			;; \
		imx8qm*) \
			$(call dl_by_wget,imx8qm_mdemo,imx8qm-m4-demo.bin); \
			_SOC=imx8qm && _NAME=imx8qm-m4-demo; \
			;; \
		imx93*) \
			$(call dl_by_wget,imx93_mdemo,imx93-m33-demo.bin); \
			_SOC=imx93 && _NAME=imx93-m33-demo; \
			;; \
		imx95*) \
			$(call dl_by_wget,imx95_mdemo,imx95-m7-demo.bin); \
			_SOC=imx95 && _NAME=imx95-m7-demo; \
			;; \
		*) \
			exit; \
			;; \
	esac && \
	if [ ! -d $${_NAME} ]; then \
		chmod +x $(FBDIR)/dl/$${_NAME}.bin; \
		$(FBDIR)/dl/$${_NAME}.bin --auto-accept --force $(LOG_MUTE); \
		mv $${_NAME}-* $${_NAME}; \
	fi && \
	mkdir -p $(DESTDIR)/lib/firmware && \
	cp -Prf ./$${_NAME}/$${_SOC}* $(DESTDIR)/lib/firmware && \
	$(call fbprint_d,"mcore_demo")
