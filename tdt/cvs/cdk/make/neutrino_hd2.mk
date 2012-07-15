#
# Makefile to build NEUTRINO
#

$(targetprefix)/var/etc/.version:
	echo "imagename=NeutrinoHD2" > $@
	echo "homepage=http://gitorious.org/open-duckbox-project-sh4" >> $@
	echo "creator=`id -un`" >> $@
	echo "docs=http://gitorious.org/open-duckbox-project-sh4/pages/Home" >> $@
	echo "forum=http://gitorious.org/open-duckbox-project-sh4" >> $@
	echo "version=0100`date +%Y%m%d%H%M`" >> $@
	echo "git =`git describe`" >> $@

N_CPPFLAGS =-DNEW_LIBCURL

N_CONFIG_OPTS = --enable-silent-rules

#
# NEUTRINO HD2
#
$(DEPDIR)/neutrino-hd2.do_prepare:
	svn co http://neutrinohd2.googlecode.com/svn/trunk/neutrino-hd $(appsdir)/neutrino-hd2
	cp -ra $(appsdir)/neutrino-hd2 $(appsdir)/neutrino-hd2.org
	cd $(appsdir)/neutrino-hd2 && patch -p1 < "$(buildprefix)/Patches/neutrino.hd2.diff"
	cd $(appsdir)/neutrino-hd2 && patch -p1 < "$(buildprefix)/Patches/neutrino.hd2.vfd.diff"
	cd $(appsdir)/neutrino-hd2 && patch -p1 < "$(buildprefix)/Patches/neutrino.hd2.eventlist.diff"
	cd $(appsdir)/neutrino-hd2 && patch -p1 < "$(buildprefix)/Patches/neutrino.hd2.infoviewer.diff"
	touch $@

$(appsdir)/neutrino-hd2/config.status: bootstrap $(EXTERNALLCD_DEP) freetype jpeg libpng libgif libid3tag curl libmad libvorbisidec libboost libflac openssl sdparm
	export PATH=$(hostprefix)/bin:$(PATH) && \
	cd $(appsdir)/neutrino-hd2 && \
		ACLOCAL_FLAGS="-I $(hostprefix)/share/aclocal" ./autogen.sh && \
		$(BUILDENV) \
		./configure \
			--host=$(target) \
			$(N_CONFIG_OPTS) \
			--enable-libeplayer3 \
			--with-boxtype=duckbox \
			--enable-pcmsoftdecoder \
			--with-tremor \
			--enable-libass \
			--with-datadir=/usr/local/share \
			--with-libdir=/usr/lib \
			--with-plugindir=/usr/lib/tuxbox/plugins \
			--with-fontdir=/usr/local/share/fonts \
			--with-configdir=/usr/local/share/config \
			--with-gamesdir=/usr/local/share/games \
			PKG_CONFIG=$(hostprefix)/bin/pkg-config \
			PKG_CONFIG_PATH=$(targetprefix)/usr/lib/pkgconfig \
			$(PLATFORM_CPPFLAGS) \
			CPPFLAGS="$(N_CPPFLAGS)"


$(DEPDIR)/neutrino-hd2.do_compile: $(appsdir)/neutrino-hd2/config.status
	cd $(appsdir)/neutrino-hd2 && \
		$(MAKE) all
	touch $@

$(DEPDIR)/neutrino-hd2: neutrino-hd2.do_prepare neutrino-hd2.do_compile
	$(MAKE) -C $(appsdir)/neutrino-hd2 install DESTDIR=$(targetprefix) && \
	make $(targetprefix)/var/etc/.version
	$(target)-strip $(targetprefix)/usr/local/bin/neutrino
	$(target)-strip $(targetprefix)/usr/local/bin/pzapit
	$(target)-strip $(targetprefix)/usr/local/bin/sectionsdcontrol
	touch $@

neutrino-hd2-clean:
	rm -f $(DEPDIR)/neutrino-hd2
	cd $(appsdir)/neutrino-hd2 && \
		$(MAKE) distclean

neutrino-hd2-distclean:
	rm -f $(DEPDIR)/neutrino-hd2
	rm -f $(DEPDIR)/neutrino-hd2.do_compile
	rm -f $(DEPDIR)/neutrino-hd2.do_prepare
	rm -rf $(appsdir)/neutrino-hd2.org
	rm -rf $(appsdir)/neutrino-hd2