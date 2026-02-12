# LayerScape Platform Specific Configuration

if PLATFORM_LS

config SOC_LS1028ARDB
	bool "ls1028ardb board"
	select ARCH_ARM64
	help
	  ls1028ardb dual core processor board with tsn

config SOC_LS1043ARDB
	bool "ls1043ardb board"
	select ARCH_ARM64
	help
	  ls1043ardb quad core processor board

config SOC_LS1046ARDB
	bool "ls1046ardb board"
	select ARCH_ARM64
	help
	  ls1046ardb quad core processor board


config SOC_LX2160ARDB
	bool "lx2160ardb board"
	select ARCH_ARM64
	help
	  lx2160ardb sixteen core processor board


endif # PLATFORM_LS

