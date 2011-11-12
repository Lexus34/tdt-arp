# tuxbox/enigma2

#if ENABLE_MEDIAFWGSTREAMER
#MEDIAFW = gstreamer
#else
#MEDIAFW = eplayer4
#endif

$(DEPDIR)/enigma2-nightly.do_prepare:
	REVISION=""; \
	DIFF="0"; \
	rm -rf $(appsdir)/enigma2-nightly; \
	rm -rf $(appsdir)/enigma2-nightly.org; \
	rm -rf $(appsdir)/enigma2-nightly.newest; \
	rm -rf $(appsdir)/enigma2-nightly.patched; \
	clear; \
	echo "Media Framwork: $(MEDIAFW)"; \
	echo "Choose between the following revisions:"; \
	echo " 0) inactive"; \
	echo "---- REVISIONS ----"; \
	echo "1) inactive"; \
	echo "2) inactive"; \
	echo "3) inactive"; \
	echo "4) inactive"; \
	echo "5) Fri,  5 Nov 2010 00:16 - E2 V2.4 libplayer3 7fd4241a1d7b8d7c36385860b24882636517473b"; \
	echo "6) inactive"; \
	echo "7) current inactive... comming soon, here is the next stable (case 7 == DIFF=7)"; \
	read -p "Select: "; \
	echo "Selection: " $$REPLY; \
	[ "$$REPLY" == "0" ] && DIFF="0" && HEAD="experimental"; \
	[ "$$REPLY" == "1" ] && DIFF="1" && HEAD="experimental" && REVISION=""; \
	[ "$$REPLY" == "2" ] && DIFF="2" && HEAD="experimental" && REVISION=""; \
	[ "$$REPLY" == "3" ] && DIFF="3" && HEAD="experimental" && REVISION=""; \
	[ "$$REPLY" == "4" ] && DIFF="4" && HEAD="master" && REVISION=""; \
	[ "$$REPLY" == "5" ] && DIFF="5" && HEAD="master" && REVISION="7fd4241a1d7b8d7c36385860b24882636517473b"; \
	[ "$$REPLY" == "6" ] && DIFF="6" && HEAD="experimental" && REVISION=""; \
	echo "Revision: " $$REVISION; \
	[ -d "$(appsdir)/enigma2-nightly" ] && \
	git pull $(appsdir)/enigma2-nightly $$HEAD;\
	[ -d "$(appsdir)/enigma2-nightly" ] || \
	git clone -b $$HEAD git://gitorious.org/open-duckbox-project-sh4/guigit.git $(appsdir)/enigma2-nightly; \
	cp -ra $(appsdir)/enigma2-nightly $(appsdir)/enigma2-nightly.newest; \
	[ "$$REVISION" == "" ] || (cd $(appsdir)/enigma2-nightly; git checkout "$$REVISION"; cd "$(buildprefix)";); \
	cp -ra $(appsdir)/enigma2-nightly $(appsdir)/enigma2-nightly.org; \
	cd $(appsdir)/enigma2-nightly && patch -p1 < "../../cdk/Patches/enigma2-nightly.$$DIFF.diff"; \
	cd $(appsdir)/enigma2-nightly && patch -p1 < "../../cdk/Patches/enigma2-nightly.$$DIFF.$(MEDIAFW).diff"; \
	cd $(appsdir)/enigma2-nightly && patch -p1 < "../../cdk/Patches/enigma2-nightly.VideoEnhancement.$$DIFF.diff"; \
	$(if $(SPARK),cd $(appsdir)/enigma2-nightly && patch -p1 < "../../cdk/Patches/enigma2-nightly.Evolution.spark.$$DIFF.diff" ); \
	cd $(appsdir)/enigma2-nightly && patch -p1 < "../../cdk/Patches/enigma2-nightly.tuxtxt.diff"
	cp -ra $(appsdir)/enigma2-nightly $(appsdir)/enigma2-nightly.patched
	touch $@

#	git clone -b $$HEAD git://git.opendreambox.org/git/enigma2.git $(appsdir)/enigma2-nightly;

$(appsdir)/enigma2-nightly/config.status: bootstrap freetype expat fontconfig libpng jpeg libgif libfribidi libid3tag libmad libsigc libreadline \
		libdvbsi++ python libxml2 libxslt elementtree zope-interface twisted pyopenssl lxml libxmlccwrap ncurses-dev $(MEDIAFW_DEP)
	cd $(appsdir)/enigma2-nightly && \
		./autogen.sh && \
		sed -e 's|#!/usr/bin/python|#!$(crossprefix)/bin/python|' -i po/xml2po.py && \
		./configure \
			--host=$(target) \
			--without-libsdl \
			--with-datadir=/usr/local/share \
			--with-libdir=/usr/lib \
			--with-plugindir=/usr/lib/tuxbox/plugins \
			--prefix=/usr \
			--datadir=/usr/local/share \
			--sysconfdir=/etc \
			STAGING_INCDIR=$(hostprefix)/usr/include \
			STAGING_LIBDIR=$(hostprefix)/usr/lib \
			PKG_CONFIG=$(hostprefix)/bin/pkg-config \
			PKG_CONFIG_PATH=$(targetprefix)/usr/lib/pkgconfig \
			PY_PATH=$(targetprefix)/usr \
			CPPFLAGS="$(CPPFLAGS) -DPLATFORM_SPARK -I$(driverdir)/include -I $(buildprefix)/$(KERNEL_DIR)/include"

$(DEPDIR)/enigma2-nightly.do_compile: $(appsdir)/enigma2-nightly/config.status
	cd $(appsdir)/enigma2-nightly && \
		$(MAKE) all
	touch $@

$(DEPDIR)/enigma2-nightly: enigma2-nightly.do_prepare enigma2-nightly.do_compile
	$(MAKE) -C $(appsdir)/enigma2-nightly install DESTDIR=$(targetprefix)
	if [ -e $(targetprefix)/usr/bin/enigma2 ]; then \
		$(target)-strip $(targetprefix)/usr/bin/enigma2; \
	fi
	if [ -e $(targetprefix)/usr/local/bin/enigma2 ]; then \
		$(target)-strip $(targetprefix)/usr/local/bin/enigma2; \
	fi
	touch $@

enigma2-nightly-clean enigma2-nightly-distclean:
	rm -f $(DEPDIR)/enigma2-nightly
	rm -f $(DEPDIR)/enigma2-nightly.do_compile
	rm -f $(DEPDIR)/enigma2-nightly.do_prepare
	rm -rf $(appsdir)/enigma2-nightly
	rm -rf $(appsdir)/enigma2-nightly.newest
	rm -rf $(appsdir)/enigma2-nightly.org
	rm -rf $(appsdir)/enigma2-nightly.patched

