include $(FBDIR)/configs/$(CONFIGLIST)

build:
	@if [ -n "$(http_proxy)" -o -n "$(https_proxy)" ]; then \
	     if [ -z "$(http_proxy)" -o -z "$(https_proxy)" ]; then \
		 echo Please set http_proxy and https_proxy ! && exit 1; \
	     fi; \
	     docker build -t fbdebian:$(DEBIAN_VERSION) --network host \
			  --build-arg http_proxy=$(http_proxy) \
	                  --build-arg https_proxy=$(https_proxy) . ; \
	 else \
	     docker build -t fbdebian:$(DEBIAN_VERSION) --network host . ; \
	 fi
