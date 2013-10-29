#
# BOOTSTRAP
#
$(DEPDIR)/bootstrap: \
		build.env \
		libtool \
		$(FILESYSTEM) \
		$(GLIBC) \
		$(CROSS_LIBGCC) \
		$(LIBSTDC)

	@[ "x$*" = "x" ] && touch -r RPMS/sh4/$(STLINUX)-sh4-$(LIBSTDC)-$(GCC_VERSION).sh4.rpm $@ || true

#
# BARE-OS
#
bare-os: \
		bootstrap \
		$(LIBTERMCAP) \
		$(NCURSES_BASE) \
		$(NCURSES) \
		$(BASE_PASSWD) \
		$(MAKEDEV) \
		$(BASE_FILES) \
		busybox \
		libz \
		$(INITSCRIPTS) \
		$(NETBASE) \
		$(BC) \
		$(SYSVINIT) \
		$(DISTRIBUTIONUTILS) \
		\
		e2fsprogs \
		u-boot-utils

net-utils: \
		$(NETKIT_FTP) \
		portmap \
		$(NFSSERVER) \
		vsftpd \
		ethtool \
		opkg \
		$(CIFS)

disk-utils: \
		$(XFSPROGS) \
		util-linux \
		jfsutils \
		$(SG3)
#
# YAUD
#
yaud-stock: yaud-none stock

yaud-vdr: yaud-none \
		stslave \
		lirc \
		openssl \
		openssl-dev \
		boot-elf \
		misc-cp \
		vdr \
		release_vdr

yaud-neutrino-hd-nightly: yaud-none \
		lirc \
		stslave \
		boot-elf \
		neutrino-hd-nightly \
		release_neutrino

yaud-enigma2-nightly: yaud-none \
		host_python \
		lirc \
		stslave \
		boot-elf \
		init-scripts \
		enigma2-nightly \
		release

yaud-enigma2-pli-nightly-base: yaud-none \
		host_python \
		lirc \
		boot-elf \
		init-scripts \
		enigma2-pli-nightly

yaud-enigma2-pli-nightly: yaud-enigma2-pli-nightly-base release

yaud-enigma2-pli-nightly-full: yaud-enigma2-pli-nightly-base min-extras release

yaud-xbmc-nightly: yaud-none host_python boot-elf xbmc-nightly init-scripts-xbmc release_xbmc

yaud-none: \
		bare-os \
		opkg-host \
		libdvdcss \
		libdvdread \
		libdvdnav \
		linux-kernel \
		net-utils \
		disk-utils \
		driver \
		udev \
		udev-rules \
		fp_control \
		evremote2 \
		devinit \
		ustslave \
		stfbcontrol \
		showiframe \
		streamproxy
#
# EXTRAS
#
min-extras: \
	usb_modeswitch \
	pppd \
	modem-scripts \
	ntfs_3g \
	enigma2-plugins \
	wireless_tools \
	enigma2-plugins-sh4
	
all-extras: \
	usb_modeswitch \
	pppd \
	modem-scripts \
	enigma2_plugin_cams_oscam \
	enigma2-plugins \
	xupnpd \
	ntfs_3g \
	enigma2-plugins-sh4 \
	wireless_tools \
	enigma2-skins-sh4 \
	ntpclient \
	udpxy \
	package-index

#
# FLASH IMAGE
#

flash-enigma2-pli-nightly: yaud-enigma2-pli-nightly
	echo "Create image"
	$(if $(SPARK)$(SPARK7162), \
	cd $(prefix)/../flash/spark && \
		echo -e "1\n1" | ./spark.sh \
	)