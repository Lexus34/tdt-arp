#
# NFS-UTILS
#
DESCRIPTION_nfs_utils = "nfs_utils"
FILES_nfs_utils = \
/usr/bin/*

$(DEPDIR)/nfs_utils.do_prepare: @DEPENDS_nfs_utils@
	@PREPARE_nfs_utils@
	chmod +x @DIR_nfs_utils@/autogen.sh
	cd @DIR_nfs_utils@ && \
		gunzip -cd ../$(lastword $^) | cat > debian.patch && \
		patch -p1 <debian.patch && \
		sed -e 's/### BEGIN INIT INFO/# chkconfig: 2345 19 81\n### BEGIN INIT INFO/g' -i debian/nfs-common.init && \
		sed -e 's/### BEGIN INIT INFO/# chkconfig: 2345 20 80\n### BEGIN INIT INFO/g' -i debian/nfs-kernel-server.init && \
		sed -e 's/do_modprobe nfsd/# do_modprobe nfsd/g' -i debian/nfs-kernel-server.init && \
		sed -e 's/RPCNFSDCOUNT=8/RPCNFSDCOUNT=3/g' -i debian/nfs-kernel-server.default
	touch $@

$(DEPDIR)/nfs_utils.do_compile: bootstrap e2fsprogs $(DEPDIR)/nfs_utils.do_prepare
	cd @DIR_nfs_utils@ && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--target=$(target) \
			CC_FOR_BUILD=$(target)-gcc \
			--disable-gss \
			--disable-nfsv4 \
			--without-tcp-wrappers && \
		$(MAKE)
	touch $@

$(DEPDIR)/min-nfs_utils $(DEPDIR)/std-nfs_utils $(DEPDIR)/max-nfs_utils \
$(DEPDIR)/nfs_utils: \
$(DEPDIR)/%nfs_utils: $(NFS_UTILS_ADAPTED_ETC_FILES:%=root/etc/%) \
		$(DEPDIR)/nfs_utils.do_compile
	$(INSTALL) -d $(prefix)/$*cdkroot/etc/{default,init.d} && \
	$(start_build)
	cd @DIR_nfs_utils@ && \
		@INSTALL_nfs_utils@
	( cd root/etc && for i in $(NFS_UTILS_ADAPTED_ETC_FILES); do \
		[ -f $$i ] && $(INSTALL) -m644 $$i $(prefix)/$*cdkroot/etc/$$i || true; \
		[ "$${i%%/*}" = "init.d" ] && chmod 755 $(prefix)/$*cdkroot/etc/$$i || true; done )
	$(tocdk_build)
	$(toflash_build)
#	@DISTCLEANUP_nfs_utils@
	@[ "x$*" = "x" ] && touch $@ || true

#
# vsftpd
#
DESCRIPTION_vsftpd = "vsftpd"
FILES_vsftpd = \
/etc/smb.conf

$(DEPDIR)/vsftpd.do_prepare: @DEPENDS_vsftpd@
	@PREPARE_vsftpd@
	touch $@

$(DEPDIR)/vsftpd.do_compile: bootstrap $(DEPDIR)/vsftpd.do_prepare
	cd @DIR_vsftpd@ && \
		$(MAKE) clean && \
		$(MAKE) $(MAKE_OPTS)
	touch $@

$(DEPDIR)/min-vsftpd $(DEPDIR)/std-vsftpd $(DEPDIR)/max-vsftpd \
$(DEPDIR)/vsftpd: \
$(DEPDIR)/%vsftpd: $(DEPDIR)/vsftpd.do_compile
	$(start_build)
	cd @DIR_vsftpd@ && \
		@INSTALL_vsftpd@
		cp $(buildprefix)/root/etc/vsftpd.conf $(PKDIR)/etc
	$(tocdk_build)
	$(toflash_build)
#	@DISTCLEANUP_vsftpd@
	@[ "x$*" = "x" ] && touch $@ || true

#
# ETHTOOL
#
DESCRIPTION_ethtool = "ethtool"
FILES_ethtool = \
/usr/sbin/*

$(DEPDIR)/ethtool.do_prepare: @DEPENDS_ethtool@
	@PREPARE_ethtool@
	touch $@

$(DEPDIR)/ethtool.do_compile: bootstrap $(DEPDIR)/ethtool.do_prepare
	cd @DIR_ethtool@  && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--libdir=$(targetprefix)/usr/lib \
			--prefix=/usr && \
		$(MAKE)
	touch $@

$(DEPDIR)/min-ethtool $(DEPDIR)/std-ethtool $(DEPDIR)/max-ethtool \
$(DEPDIR)/ethtool: \
$(DEPDIR)/%ethtool: $(DEPDIR)/ethtool.do_compile
	$(start_build)
	cd @DIR_ethtool@  && \
		@INSTALL_ethtool@
	$(tocdk_build)
	$(toflash_build)
#	@DISTCLEANUP_ethtool@
	@[ "x$*" = "x" ] && touch $@ || true

#
# SAMBA
#
$(DEPDIR)/samba.do_prepare: @DEPENDS_samba@
	@PREPARE_samba@
	touch $@

$(DEPDIR)/samba.do_compile: bootstrap $(DEPDIR)/samba.do_prepare
	cd @DIR_samba@ && \
		cd source3 && \
		./autogen.sh && \
		$(BUILDENV) \
		libreplace_cv_HAVE_GETADDRINFO=no \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix= \
			--exec-prefix=/usr \
			--disable-pie \
			--disable-avahi \
			--disable-cups \
			--disable-relro \
			--disable-swat \
			--disable-shared-libs \
			--disable-socket-wrapper \
			--disable-nss-wrapper \
			--disable-smbtorture4 \
			--disable-fam \
			--disable-iprint \
			--disable-dnssd \
			--disable-pthreadpool \
			--disable-dmalloc \
			--with-included-iniparser \
			--with-included-popt \
			--with-sendfile-support \
			--without-aio-support \
			--without-cluster-support \
			--without-ads \
			--without-krb5 \
			--without-dnsupdate \
			--without-automount \
			--without-ldap \
			--without-pam \
			--without-pam_smbpass \
			--without-winbind \
			--without-wbclient \
			--without-syslog \
			--without-nisplus-home \
			--without-quotas \
			--without-sys-quotas \
			--without-utmp \
			--without-acl-support \
			--with-configdir=/etc/samba \
			--with-privatedir=/etc/samba/private \
			--with-mandir=/usr/share/man \
			--with-piddir=/var/run \
			--with-logfilebase=/var/log \
			--with-lockdir=/var/lock \
			--with-swatdir=/usr/share/swat \
			--disable-cups && \
		$(MAKE) $(MAKE_OPTS) && \
		$(target)-strip -s bin/smbd && $(target)-strip -s bin/nmbd
	touch $@

$(DEPDIR)/min-samba $(DEPDIR)/std-samba $(DEPDIR)/max-samba \
$(DEPDIR)/samba: \
$(DEPDIR)/%samba: $(DEPDIR)/samba.do_compile
	cd @DIR_samba@ && \
		cd source3 && \
		$(INSTALL) -d $(prefix)/$*cdkroot/etc/samba && \
		$(INSTALL) -c -m644 ../examples/smb.conf.spark $(prefix)/$*cdkroot/etc/samba/smb.conf && \
		$(INSTALL) -d $(prefix)/$*cdkroot/etc/init.d && \
		$(INSTALL) -c -m755 ../examples/samba.spark $(prefix)/$*cdkroot/etc/init.d/samba && \
		@INSTALL_samba@
#	@DISTCLEANUP_samba@
	@[ "x$*" = "x" ] && touch $@ || true
	@TUXBOX_YAUD_CUSTOMIZE@

#
# NETIO
#
$(DEPDIR)/netio.do_prepare: @DEPENDS_netio@
	@PREPARE_netio@
	touch $@

$(DEPDIR)/netio.do_compile: bootstrap $(DEPDIR)/netio.do_prepare
	cd @DIR_netio@ && \
		$(MAKE_OPTS) \
		$(MAKE) all O=.o X= CFLAGS="-DUNIX" LIBS="$(LDFLAGS) -lpthread" OUT=-o
	touch $@

$(DEPDIR)/min-netio $(DEPDIR)/std-netio $(DEPDIR)/max-netio \
$(DEPDIR)/netio: \
$(DEPDIR)/%netio: $(DEPDIR)/netio.do_compile
	cd @DIR_netio@ && \
		$(INSTALL) -d $(prefix)/$*cdkroot/usr/bin && \
		@INSTALL_netio@
#	@DISTCLEANUP_netio@
	@[ "x$*" = "x" ] && touch $@ || true

#
# LIGHTTPD
#
$(DEPDIR)/lighttpd.do_prepare: @DEPENDS_lighttpd@
	@PREPARE_lighttpd@
	touch $@

$(DEPDIR)/lighttpd.do_compile: bootstrap $(DEPDIR)/lighttpd.do_prepare
	cd @DIR_lighttpd@ && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix= \
			--exec-prefix=/usr \
			--datarootdir=/usr/share && \
		$(MAKE)
	touch $@

$(DEPDIR)/min-lighttpd $(DEPDIR)/std-lighttpd $(DEPDIR)/max-lighttpd \
$(DEPDIR)/lighttpd: \
$(DEPDIR)/%lighttpd: $(DEPDIR)/lighttpd.do_compile
	cd @DIR_lighttpd@ && \
		@INSTALL_lighttpd@
	cd @DIR_lighttpd@ && \
		$(INSTALL) -d $(prefix)/$*cdkroot/etc/lighttpd && \
		$(INSTALL) -c -m644 doc/lighttpd.conf $(prefix)/$*cdkroot/etc/lighttpd && \
		$(INSTALL) -d $(prefix)/$*cdkroot/etc/init.d && \
		$(INSTALL) -c -m644 doc/rc.lighttpd.redhat $(prefix)/$*cdkroot/etc/init.d/lighttpd
	$(INSTALL) -d $(prefix)/$*cdkroot/etc/lighttpd && $(INSTALL) -m755 root/etc/lighttpd/lighttpd.conf $(prefix)/$*cdkroot/etc/lighttpd
	$(INSTALL) -d $(prefix)/$*cdkroot/etc/init.d && $(INSTALL) -m755 root/etc/init.d/lighttpd $(prefix)/$*cdkroot/etc/init.d
#	@DISTCLEANUP_lighttpd@
	@[ "x$*" = "x" ] && touch $@ || true

#
# NETKIT_FTP
#
$(DEPDIR)/netkit_ftp.do_prepare: @DEPENDS_netkit_ftp@
	@PREPARE_netkit_ftp@
	touch $@

$(DEPDIR)/netkit_ftp.do_compile: bootstrap ncurses libreadline $(DEPDIR)/netkit_ftp.do_prepare
	cd @DIR_netkit_ftp@  && \
		$(BUILDENV) \
		./configure \
			--with-c-compiler=$(target)-gcc \
			--prefix=/usr \
			--installroot=$(prefix)/$*cdkroot && \
		$(MAKE)
	touch $@

$(DEPDIR)/min-netkit_ftp $(DEPDIR)/std-netkit_ftp $(DEPDIR)/max-netkit_ftp \
$(DEPDIR)/netkit_ftp: \
$(DEPDIR)/%netkit_ftp: $(DEPDIR)/netkit_ftp.do_compile
	cd @DIR_netkit_ftp@  && \
		@INSTALL_netkit_ftp@
#	@DISTCLEANUP_netkit_ftp@
	@[ "x$*" = "x" ] && touch $@ || true

#
# WIRELESS_TOOLS
#
$(DEPDIR)/wireless_tools.do_prepare: @DEPENDS_wireless_tools@
	@PREPARE_wireless_tools@
	touch $@

$(DEPDIR)/wireless_tools.do_compile: bootstrap $(DEPDIR)/wireless_tools.do_prepare
	cd @DIR_wireless_tools@  && \
		$(MAKE) $(MAKE_OPTS)
	touch $@

$(DEPDIR)/min-wireless_tools $(DEPDIR)/std-wireless_tools $(DEPDIR)/max-wireless_tools \
$(DEPDIR)/wireless_tools: \
$(DEPDIR)/%wireless_tools: $(DEPDIR)/wireless_tools.do_compile
	cd @DIR_wireless_tools@  && \
		@INSTALL_wireless_tools@
#	@DISTCLEANUP_wireless_tools@
	@[ "x$*" = "x" ] && touch $@ || true

#
# WPA_SUPPLICANT
#
$(DEPDIR)/wpa_supplicant.do_prepare: @DEPENDS_wpa_supplicant@
	@PREPARE_wpa_supplicant@
	touch $@

$(DEPDIR)/wpa_supplicant.do_compile: bootstrap Patches/wpa_supplicant.config $(DEPDIR)/wpa_supplicant.do_prepare
	cd @DIR_wpa_supplicant@  && \
		$(INSTALL) -m 644 ../$(word 2,$^) .config && \
		$(MAKE) $(MAKE_OPTS)
	touch $@

$(DEPDIR)/min-wpa_supplicant $(DEPDIR)/std-wpa_supplicant $(DEPDIR)/max-wpa_supplicant \
$(DEPDIR)/wpa_supplicant: \
$(DEPDIR)/%wpa_supplicant: $(DEPDIR)/wpa_supplicant.do_compile
	cd @DIR_wpa_supplicant@  && \
		@INSTALL_wpa_supplicant@
#	@DISTCLEANUP_wpa_supplicant@
	@[ "x$*" = "x" ] && touch $@ || true
