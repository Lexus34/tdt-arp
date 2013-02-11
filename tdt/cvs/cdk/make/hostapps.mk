
$(hostappsdir)/config.status: bootstrap
	cd $(hostappsdir) && \
	./autogen.sh && \
	./configure --prefix=$(hostprefix)

hostapps: $(hostappsdir)/config.status
	$(MAKE) -C $(hostappsdir)
#	touch $@

#
# ccache
#

BEGIN[[
ccache
  2.4
  {PN}-{PV}
  extract:http://samba.org/ftp/{PN}/{PN}-{PV}.tar.gz
  make:install:DESTDIR=HOST
;
]]END

ifdef ENABLE_CCACHE
$(hostprefix)/bin/ccache: $(DEPENDS_ccache)
	$(PREPARE_ccache)
	cd $(DIR_ccache) && \
		./configure \
			--build=$(build) \
			--host=$(build) \
			--prefix= && \
			$(MAKE) all && \
			$(INSTALL_ccache)
#	@CLEANUP_ccache@
endif

#
# MKCRAMFS
#
BEGIN[[
cramfs
  1.1
  {PN}-{PV}
  extract:http://heanet.dl.sourceforge.net/sourceforge/{PN}/{PN}-{PV}.tar.gz
  install:mk{PN}:HOST/bin
;
]]END

mkcramfs: @MKCRAMFS@

$(hostprefix)/bin/mkcramfs: $(DEPENDS_cramfs)
	$(PREPARE_cramfs)
	cd $(DIR_cramfs) && \
		$(MAKE) mkcramfs && \
		$(INSTALL_cramfs)
#	@DISTCLEANUP_cramfs@

#
# MKSQUASHFS with LZMA support
#
BEGIN[[
squashfs
  3.0
  mk{PN}
  pdircreate:mk{PN}
  extract:http://heanet.dl.sourceforge.net/sourceforge/sevenzip/lzma442.tar.bz2
  patch:file://lzma_zlib-stream.diff
  extract:http://heanet.dl.sourceforge.net/sourceforge/{PN}/{PN}{PV}.tar.gz
  patch:file://mk{PN}_lzma.diff
;
squashfs
  4.0
  mk{PN}
  pdircreate:mk{PN}
  extract:http://heanet.dl.sourceforge.net/sourceforge/sevenzip/lzma465.tar.bz2
  extract:http://heanet.dl.sourceforge.net/sourceforge/{PN}/{PN}{PV}.tar.gz
  patch:file://{PN}-tools-{PV}-lzma.patch
;
]]END

MKSQUASHFS = $(hostprefix)/bin/mksquashfs
mksquashfs: $(MKSQUASHFS)

$(hostprefix)/bin/mksquashfs: $(DEPENDS_squashfs)
	rm -rf $(DIR_squashfs)
	mkdir -p $(DIR_squashfs)
	cd $(DIR_squashfs) && \
	bunzip2 -cd $(archivedir)/lzma465.tar.bz2 | TAPE=- tar -x && \
	gunzip -cd $(archivedir)/squashfs4.0.tar.gz | TAPE=- tar -x && \
	cd squashfs4.0/squashfs-tools && patch -p1 < $(buildprefix)/Patches/squashfs-tools-4.0-lzma.patch
	$(MAKE) -C $(DIR_squashfs)/squashfs4.0/squashfs-tools
	$(INSTALL) -d $(@D)
	$(INSTALL) -m755 $(DIR_squashfs@/squashfs4.0/squashfs-tools/mksquashfs $)
	$(INSTALL) -m755 $(DIR_squashfs@/squashfs4.0/squashfs-tools/unsquashfs $()D)
#	rm -rf $(DIR_squashfs)

#
# IPKG-UTILS
#
BEGIN[[
ipkg_utils
  050831
  {PN}-{PV}
  extract:ftp://ftp.gwdg.de/linux/handhelds/packages/{PN}/{PN}-{PV}.tar.gz
  patch:file://{PN}.diff
  make:install
;
]]END

IPKG_BUILD_BIN = $(crossprefix)/bin/ipkg-build

ipkg-utils: $(IPKG_BUILD_BIN)

$(crossprefix)/bin/ipkg-build: filesystem $(DEPENDS_ipkg_utils) | $(ipkprefix)
	$(PREPARE_ipkg_utils)
	cd $(DIR_ipkg_utils) && \
		$(MAKE) all PREFIX=$(crossprefix) && \
		$(MAKE) install PREFIX=$(crossprefix)
#       @DISTCLEANUP_ipkg-utils@

#
# OPKG-HOST
#
BEGIN[[
opkg_host
  0.1.8
  {PN}
  dirextract:http://opkg.googlecode.com/files/opkg-{PV}.tar.gz
;
]]END

OPKG_BIN = $(crossprefix)/bin/opkg
OPKG_CONF = $(crossprefix)/etc/opkg.conf
OPKG_CONFCDK = $(crossprefix)/etc/opkg-cdk.conf

opkg-host: $(OPKG_BIN) $(ipkcdk) $(ipkprefix) $(ipkextras)

$(crossprefix)/bin/opkg: $(DEPENDS_opkg_host)
	$(PREPARE_opkg_host)
	cd $(DIR_opkg_host)/opkg-$(VERSION_opkg_host) && \
		./configure \
			--prefix=$(crossprefix) && \
		$(MAKE) && \
		$(MAKE) install && \
	$(LN_SF) opkg-cl $@
	install -d $(targetprefix)/usr/lib/opkg
	install -d $(prefix)/pkgroot/usr/lib/opkg
	echo "dest root /" >$(OPKG_CONF)
	( echo "lists_dir ext /usr/lib/opkg"; \
	  echo "arch sh4 10"; \
	  echo "arch all 1"; \
	  echo "src/gz cross file://$(ipkprefix)" ) >>$(OPKG_CONF)
	echo "dest cdkroot /" >$(OPKG_CONFCDK)
	( echo "lists_dir ext /usr/lib/opkg"; \
	  echo "arch sh4 10"; \
	  echo "arch all 1"; \
	  echo "src/gz cross file://$(ipkcdk)" ) >>$(OPKG_CONFCDK)


#
# PYTHON-HOST
#
BEGIN[[
ifdef ENABLE_PY27
host_python
  2.7.3
  {PN}-{PV}
  extract:http://www.python.org/ftp/python/{PV}/Python-{PV}.tar.bz2
  pmove:Python-{PV}:{PN}-{PV}
  patch:file://python_{PV}.diff
  patch:file://python_{PV}-ctypes-libffi-fix-configure.diff
  patch:file://python_{PV}-pgettext.diff
;
else
host_python
  2.6.6
  {PN}-{PV}
  extract:http://www.python.org/ftp/python/{PV}/Python-{PV}.tar.bz2
  pmove:Python-{PV}:{PN}-{PV}
  patch:file://python_{PV}.diff
  patch:file://python_{PV}-ctypes-libffi-fix-configure.diff
  patch:file://python_{PV}-pgettext.diff
endif
;
]]END

python := $(crossprefix)/bin/python

$(DEPDIR)/host_python: $(DEPENDS_host_python)
	$(PREPARE_host_python) && \
	( cd $(DIR_host_python) && \
		rm -rf config.cache; \
		autoconf && \
		CONFIG_SITE= \
		OPT="$(HOST_CFLAGS)" \
		./configure \
			--without-cxx-main \
			--without-threads && \
		$(MAKE) python Parser/pgen && \
		mv python ./hostpython && \
		mv Parser/pgen ./hostpgen && \
		\
		$(MAKE) distclean && \
		./configure \
			--prefix=$(crossprefix) \
			--sysconfdir=$(crossprefix)/etc \
			--without-cxx-main \
			--without-threads && \
		$(MAKE) \
			TARGET_OS=$(build) \
			PYTHON_MODULES_INCLUDE="$(crossprefix)/include" \
			PYTHON_MODULES_LIB="$(crossprefix)/lib" \
			HOSTPYTHON=./hostpython \
			HOSTPGEN=./hostpgen \
			all install && \
		cp ./hostpgen $(crossprefix)/bin/pgen ) && \
	$(DISTCLEANUP_host_python)
	touch $@
