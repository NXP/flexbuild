# Copyright 2021-2024 NXP
#
# SPDX-License-Identifier: BSD-3-Clause

# i.MX M4/M7/M33 core Demo images



mcore_demo:
	@[ $(SOCFAMILY) != IMX ] && exit || \
	 [ -d $(BSPDIR)/imx_mcore_demos ] && exit || \
	 mkdir -p $(BSPDIR)/imx_mcore_demos && \
	 cd $(BSPDIR)/imx_mcore_demos && \
	 \
	 for soc in imx8mm imx8mp imx93 imx95 imx8mq imx8mn imx8ulp; do \
		case $$soc in \
			imx8mm) url="$(repo_imx8mm_mdemo_url)" ;; \
			imx8mp) url="$(repo_imx8mp_mdemo_url)" ;; \
			imx8mq) url="$(repo_imx8mq_mdemo_url)" ;; \
			imx8mn) url="$(repo_imx8mn_mdemo_url)" ;; \
			imx8ulp) url="$(repo_imx8ulp_mdemo_url)" ;; \
			imx93) url="$(repo_imx93_mdemo_url)" ;; \
			imx95) url="$(repo_imx95_mdemo_url)" ;; \
			*) echo "Unknown soc: $$soc"; exit 1 ;; \
		esac; \
		\
		_FNAME="$$(basename "$${url}")" && \
		wget -q $${url} -O $${_FNAME} $(LOG_MUTE) && \
		chmod +x $${_FNAME} && ./$${_FNAME} --auto-accept $(LOG_MUTE) && \
		_BNAME="$$(basename "$${_FNAME}" .bin)" && \
		_DNAME="$$(echo "$${_BNAME}" | cut -d'-' -f1-3)" && \
		mv $${_BNAME} $${_DNAME} && \
		rm -f $${_FNAME} ; \
	 \
	 done && \
	 [ ! -L $(FBOUTDIR)/bsp/imx_mcore_demos ] && ln -sf $(BSPDIR)/imx_mcore_demos $(FBOUTDIR)/bsp/imx_mcore_demos || true && \
	 $(call fbprint_d,"imx_mcore_demo")
