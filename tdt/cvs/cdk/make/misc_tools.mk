# misc/tools

#DESCRIPTION_misc_tools = "misc tools for box"
#SRC_URI_misc_tools = "git://gitorious.org/~schpuntik/open-duckbox-project-sh4/tdt-amiko.git"
#DIR_misc_tools = $(appsdir)/misc/tools


#$(appsdir)/misc/tools/config.status: bootstrap libpng
#$(appsdir)/misc/tools/config.status: bootstrap
#	export PATH=$(hostprefix)/bin:$(PATH) && \
#	cd $(appsdir)/misc/tools && \
#	libtoolize -f -c && \
#	$(CONFIGURE) --prefix= \
#	$(if $(MULTICOM406), --enable-multicom406) $(if $(MULTICOM324), --enable-multicom324)
#
#$(DEPDIR)/misc-tools: $(DEPDIR)/%misc-tools: driver libstdc++-dev libdvdnav libdvdcss libpng jpeg ffmpeg expat fontconfig bzip2 $(appsdir)/misc/tools/config.status
#	$(start_build)
#	$(get_git_version)
#	$(MAKE) -C $(appsdir)/misc/tools all install DESTDIR=$(PKDIR) \
#	CPPFLAGS="\
#	$(if $(SPARK), -DPLATFORM_SPARK) \
#	$(if $(SPARK7162), -DPLATFORM_SPARK7162) \
#	$(if $(HL101), -DPLATFORM_HL101) \
#	$(if $(PLAYER179), -DPLAYER179) \
#	$(if $(PLAYER191), -DPLAYER191) \
#	$(if $(VDR1722), -DVDR1722) \
#	$(if $(VDR1727), -DVDR1727)"
#	$(tocdk_build)
#	$(toflash_build)
#	touch $@

misc-tools-clean: \
	devinit-clean \
	evremote2-clean \
	fp_control-clean \
	gitVCInfo-clean \
	hotplug-clean \
	libeplayer3-clean \
	libmme_host-clean \
	libmmeimage-clean \
	showiframe-clean \
	stfbcontrol-clean \
	streamproxy-clean \
	ustslave-clean \
	eplayer4-clean



#
# DEVINIT
#
BEGIN[[
devinit
  git
  {PN}-{PV}
  plink:$(appsdir)/misc/tools/{PN}:{PN}-{PV}
  make:install:DESTDIR=PKDIR
;
]]END

DESCRIPTION_devinit = "devinit"
SRC_URI_devinit = "https://code.google.com/p/tdt-amiko/"
PKGR_devinit = r1
FILES_devinit = \
/bin/devinit

define DISTCLEANUP_devinit
	cd $(DIR_devinit) && \
	$(MAKE) distclean
	rm -f $(DEPDIR)/devinit
	rm -f $(DIR_devinit)
endef
define DEPSCLEANUP_devinit
	cd $(DIR_devinit) && \
	$(MAKE) distclean
	rm -f $(DEPDIR)/devinit.do_compile
endef

$(DEPDIR)/devinit.do_prepare: bootstrap $(DEPENDS_devinit)
	$(PREPARE_devinit)
	touch $@

$(DEPDIR)/devinit.do_compile: $(DEPDIR)/devinit.do_prepare
	export PATH=$(hostprefix)/bin:$(PATH) && \
	cd $(DIR_devinit) && \
	libtoolize -f -c && \
	$(CONFIGURE) --prefix= \
	$(if $(MULTICOM406), --enable-multicom406) $(if $(MULTICOM324), --enable-multicom324) \
	$(MAKE)
	touch $@

$(DEPDIR)/devinit: $(DEPDIR)/devinit.do_compile
	$(start_build)
	$(get_git_version)
	cd $(DIR_devinit) && \
		$(INSTALL_devinit)
	CPPFLAGS="\
	$(if $(SPARK), -DPLATFORM_SPARK) \
	$(if $(SPARK7162), -DPLATFORM_SPARK7162) \
	$(if $(HL101), -DPLATFORM_HL101) \
	$(if $(PLAYER179), -DPLAYER179) \
	$(if $(PLAYER191), -DPLAYER191)"
	$(tocdk_build)
	$(toflash_build)
	touch $@

#
# EVREMOTE2
#
BEGIN[[
evremote2
  git
  {PN}-{PV}
  plink:$(appsdir)/misc/tools/{PN}:{PN}-{PV}
  make:install:DESTDIR=PKDIR
;
]]END

DESCRIPTION_evremote2 = "evremote2"
SRC_URI_evremote2 = "https://code.google.com/p/tdt-amiko/"
PKGR_evremote2 = r1
FILES_evremote2 = \
/bin/evremote2 \
/bin/evtest

define DISTCLEANUP_evremote2
	cd $(DIR_evremote2) && \
	$(MAKE) distclean
	rm -f $(DEPDIR)/evremote2
	rm -f $(DIR_evremote2)
endef
define DEPSCLEANUP_evremote2
	cd $(DIR_evremote2) && \
	$(MAKE) distclean
	rm -f $(DEPDIR)/evremote2.do_compile
endef

$(DEPDIR)/evremote2.do_prepare: bootstrap $(DEPENDS_evremote2)
	$(PREPARE_evremote2)
	touch $@

$(DEPDIR)/evremote2.do_compile: $(DEPDIR)/evremote2.do_prepare
	export PATH=$(hostprefix)/bin:$(PATH) && \
	cd $(DIR_evremote2) && \
	libtoolize -f -c && \
	$(CONFIGURE) --prefix= \
	$(if $(MULTICOM406), --enable-multicom406) $(if $(MULTICOM324), --enable-multicom324) \
	$(MAKE)
	touch $@

$(DEPDIR)/evremote2: $(DEPDIR)/evremote2.do_compile
	$(start_build)
	$(get_git_version)
	cd $(DIR_evremote2) && \
		$(INSTALL_evremote2)
	CPPFLAGS="\
	$(if $(SPARK), -DPLATFORM_SPARK) \
	$(if $(SPARK7162), -DPLATFORM_SPARK7162) \
	$(if $(HL101), -DPLATFORM_HL101) \
	$(if $(PLAYER179), -DPLAYER179) \
	$(if $(PLAYER191), -DPLAYER191)"
	$(tocdk_build)
	$(toflash_build)
	touch $@

#
# FP-CONTROL
#
BEGIN[[
fp_control
  git
  {PN}-{PV}
  plink:$(appsdir)/misc/tools/fp_control:{PN}-{PV}
  make:install:DESTDIR=PKDIR
;
]]END

DESCRIPTION_fp_control = "fp_control"
SRC_URI_fp_control = "https://code.google.com/p/tdt-amiko/"
PKGR_fp_control = r1
FILES_fp_control = \
/bin/fp_control

define DISTCLEANUP_fp_control
	cd $(DIR_fp_control) && \
	$(MAKE) distclean
	rm -f $(DEPDIR)/fp_control
	rm -f $(DIR_fp_control)
endef
define DEPSCLEANUP_fp_control
	cd $(DIR_fp_control) && \
	$(MAKE) distclean
	rm -f $(DEPDIR)/fp_control.do_compile
endef

$(DEPDIR)/fp_control.do_prepare: bootstrap $(DEPENDS_fp_control)
	$(PREPARE_fp_control)
	touch $@

$(DEPDIR)/fp_control.do_compile: $(DEPDIR)/fp_control.do_prepare
	export PATH=$(hostprefix)/bin:$(PATH) && \
	cd $(DIR_fp_control) && \
	libtoolize -f -c && \
	$(CONFIGURE) --prefix= \
	$(if $(MULTICOM406), --enable-multicom406) $(if $(MULTICOM324), --enable-multicom324) \
	$(MAKE)
	touch $@

$(DEPDIR)/fp_control: $(DEPDIR)/fp_control.do_compile
	$(start_build)
	$(get_git_version)
	cd $(DIR_fp_control) && \
		$(INSTALL_fp_control)
	CPPFLAGS="\
	$(if $(SPARK), -DPLATFORM_SPARK) \
	$(if $(SPARK7162), -DPLATFORM_SPARK7162) \
	$(if $(HL101), -DPLATFORM_HL101) \
	$(if $(PLAYER179), -DPLAYER179) \
	$(if $(PLAYER191), -DPLAYER191)"
	$(tocdk_build)
	$(toflash_build)
	touch $@

#
# gitVCInfo
#
BEGIN[[
gitVCInfo
  git
  {PN}-{PV}
  plink:$(appsdir)/misc/tools/{PN}:{PN}-{PV}
  make:install:DESTDIR=PKDIR
;
]]END

DESCRIPTION_gitVCInfo = "gitVCInfo"
SRC_URI_gitVCInfo = "https://code.google.com/p/tdt-amiko/"
PKGR_gitVCInfo = r1
FILES_gitVCInfo = \
/bin/gitVCInfo

define DISTCLEANUP_gitVCInfo
	cd $(DIR_gitVCInfo) && \
	$(MAKE) distclean
	rm -f $(DEPDIR)/gitVCInfo
	rm -f $(DIR_gitVCInfo)
endef
define DEPSCLEANUP_gitVCInfo
	cd $(DIR_gitVCInfo) && \
	$(MAKE) distclean
	rm -f $(DEPDIR)/gitVCInfo.do_compile
endef

$(DEPDIR)/gitVCInfo.do_prepare: bootstrap $(DEPENDS_gitVCInfo)
	$(PREPARE_gitVCInfo)
	touch $@

$(DEPDIR)/gitVCInfo.do_compile: $(DEPDIR)/gitVCInfo.do_prepare
	export PATH=$(hostprefix)/bin:$(PATH) && \
	cd $(DIR_gitVCInfo) && \
	libtoolize -f -c && \
	$(CONFIGURE) --prefix= \
	$(if $(MULTICOM406), --enable-multicom406) $(if $(MULTICOM324), --enable-multicom324) \
	$(MAKE)
	touch $@

$(DEPDIR)/gitVCInfo: $(DEPDIR)/gitVCInfo.do_compile
	$(start_build)
	$(get_git_version)
	cd $(DIR_gitVCInfo) && \
		$(INSTALL_gitVCInfo)
	CPPFLAGS="\
	$(if $(SPARK), -DPLATFORM_SPARK) \
	$(if $(SPARK7162), -DPLATFORM_SPARK7162) \
	$(if $(HL101), -DPLATFORM_HL101) \
	$(if $(PLAYER179), -DPLAYER179) \
	$(if $(PLAYER191), -DPLAYER191)"
	$(tocdk_build)
	$(toflash_build)
	touch $@

#
# HOTPLUG
#
BEGIN[[
hotplug
  git
  {PN}-{PV}
  plink:$(appsdir)/misc/tools/{PN}:{PN}-{PV}
  make:install:DESTDIR=PKDIR
;
]]END

DESCRIPTION_hotplug = "hotplug"
SRC_URI_hotplug = "https://code.google.com/p/tdt-amiko/"
PKGR_hotplug =r1
FILES_hotplug = \
/bin/hotplug

define DISTCLEANUP_hotplug
	cd $(DIR_hotplug) && \
	$(MAKE) distclean
	rm -f $(DEPDIR)/hotplug
	rm -f $(DIR_hotplug)
endef
define DEPSCLEANUP_hotplug
	cd $(DIR_hotplug) && \
	$(MAKE) distclean
	rm -f $(DEPDIR)/hotplug.do_compile
endef

$(DEPDIR)/hotplug.do_prepare: bootstrap $(DEPENDS_hotplug)
	$(PREPARE_hotplug)
	touch $@

$(DEPDIR)/hotplug.do_compile: $(DEPDIR)/hotplug.do_prepare
	export PATH=$(hostprefix)/bin:$(PATH) && \
	cd $(DIR_hotplug) && \
	libtoolize -f -c && \
	$(CONFIGURE) --prefix= \
	$(if $(MULTICOM406), --enable-multicom406) $(if $(MULTICOM324), --enable-multicom324) \
	$(MAKE)
	touch $@

$(DEPDIR)/hotplug: $(DEPDIR)/hotplug.do_compile
	$(start_build)
	$(get_git_version)
	cd $(DIR_hotplug) && \
		$(INSTALL_hotplug)
	CPPFLAGS="\
	$(if $(SPARK), -DPLATFORM_SPARK) \
	$(if $(SPARK7162), -DPLATFORM_SPARK7162) \
	$(if $(HL101), -DPLATFORM_HL101) \
	$(if $(PLAYER179), -DPLAYER179) \
	$(if $(PLAYER191), -DPLAYER191)"
	$(tocdk_build)
	$(toflash_build)
	touch $@

#
# LIBEPLAYER3
#
BEGIN[[
libeplayer3
  git
  {PN}-{PV}
  plink:$(appsdir)/misc/tools/{PN}:{PN}-{PV}
  make:install:DESTDIR=PKDIR
;
]]END

DESCRIPTION_libeplayer3 = "libeplayer3"
SRC_URI_libeplayer3 = "https://code.google.com/p/tdt-amiko/"
PKGR_libeplayer3 = r1
FILES_libeplayer3 = \
/bin/eplayer3 \
/bin/meta \
/lib/libeplayer3.*

define DISTCLEANUP_libeplayer3
	cd $(DIR_libeplayer3) && \
	$(MAKE) distclean
	rm -f $(DEPDIR)/libeplayer3
	rm -f $(DIR_libeplayer3)
endef
define DEPSCLEANUP_libeplayer3
	cd $(DIR_libeplayer3) && \
	$(MAKE) distclean
	rm -f $(DEPDIR)/libeplayer3.do_compile
endef

$(DEPDIR)/libeplayer3.do_prepare: bootstrap driver libstdc++-dev libdvdnav libdvdcss libpng jpeg ffmpeg expat fontconfig bzip2 $(DEPENDS_libeplayer3)
	$(PREPARE_libeplayer3)
	touch $@

$(DEPDIR)/libeplayer3.do_compile: $(DEPDIR)/libeplayer3.do_prepare
	export PATH=$(hostprefix)/bin:$(PATH) && \
	cd $(DIR_libeplayer3) && \
	libtoolize -f -c && \
	$(CONFIGURE) --prefix= \
		--includedir=/usr/include \
	$(if $(MULTICOM406), --enable-multicom406) $(if $(MULTICOM324), --enable-multicom324) \
	$(MAKE)
	touch $@

$(DEPDIR)/libeplayer3: $(DEPDIR)/libeplayer3.do_compile
	$(start_build)
	$(get_git_version)
	cd $(DIR_libeplayer3) && \
		$(INSTALL_libeplayer3)
	CPPFLAGS="\
	$(if $(SPARK), -DPLATFORM_SPARK) \
	$(if $(SPARK7162), -DPLATFORM_SPARK7162) \
	$(if $(HL101), -DPLATFORM_HL101) \
	$(if $(PLAYER179), -DPLAYER179) \
	$(if $(PLAYER191), -DPLAYER191)"
	$(tocdk_build)
	$(toflash_build)
	touch $@

#
# LIBMME-HOST
#
BEGIN[[
libmme_host
  git
  {PN}-{PV}
  plink:$(appsdir)/misc/tools/libmme_host:{PN}-{PV}
  make:install:DESTDIR=PKDIR
;
]]END

DESCRIPTION_libmme_host = "libmme-host"
SRC_URI_libmme_host = "https://code.google.com/p/tdt-amiko/"
PKGR_libmme_host = r1
FILES_libmme_host = \
/lib/libmme_host.*

define DISTCLEANUP_libmme_host
	cd $(DIR_libmme_host) && \
	$(MAKE) distclean
	rm -f $(DEPDIR)/libmme_host
	rm -f $(DIR_libmme_host)
endef
define DEPSCLEANUP_libmme_host
	cd $(DIR_libmme_host) && \
	$(MAKE) distclean
	rm -f $(DEPDIR)/libmme_host.do_compile
endef

$(DEPDIR)/libmme_host.do_prepare: bootstrap $(DEPENDS_libmme_host)
	$(PREPARE_libmme_host)
	touch $@

$(DEPDIR)/libmme_host.do_compile: $(DEPDIR)/libmme_host.do_prepare
	export PATH=$(hostprefix)/bin:$(PATH) && \
	cd $(DIR_libmme_host) && \
	libtoolize -f -c && \
	$(CONFIGURE) --prefix= \
	$(if $(MULTICOM406), --enable-multicom406) $(if $(MULTICOM324), --enable-multicom324) \
	$(MAKE)
	touch $@

$(DEPDIR)/libmme_host: $(DEPDIR)/libmme_host.do_compile
	$(start_build)
	$(get_git_version)
	cd $(DIR_libmme_host) && \
		$(INSTALL_libmme_host)
	CPPFLAGS="\
	$(if $(SPARK), -DPLATFORM_SPARK) \
	$(if $(SPARK7162), -DPLATFORM_SPARK7162) \
	$(if $(HL101), -DPLATFORM_HL101) \
	$(if $(PLAYER179), -DPLAYER179) \
	$(if $(PLAYER191), -DPLAYER191)"
	$(tocdk_build)
	$(toflash_build)
	touch $@

#
# LIBMMEIMAGE
#
BEGIN[[
libmmeimage
  git
  {PN}-{PV}
  plink:$(appsdir)/misc/tools/{PN}:{PN}-{PV}
  make:install:DESTDIR=PKDIR
;
]]END

DESCRIPTION_libmmeimage = "libmmeimage"
SRC_URI_libmmeimage = "https://code.google.com/p/tdt-amiko/"
PKGR_libmmeimage = r1
FILES_libmmeimage = \
/lib/libmmeimage.*

define DISTCLEANUP_libmmeimage
	cd $(DIR_libmmeimage) && \
	$(MAKE) distclean
	rm -f $(DEPDIR)/libmmeimage
	rm -f $(DIR_libmmeimage)
endef
define DEPSCLEANUP_libmmeimage
	cd $(DIR_libmmeimage) && \
	$(MAKE) distclean
	rm -f $(DEPDIR)/libmmeimage.do_compile
endef

$(DEPDIR)/libmmeimage.do_prepare: bootstrap $(DEPENDS_libmmeimage)
	$(PREPARE_libmmeimage)
	touch $@

$(DEPDIR)/libmmeimage.do_compile: $(DEPDIR)/libmmeimage.do_prepare
	export PATH=$(hostprefix)/bin:$(PATH) && \
	cd $(DIR_libmmeimage) && \
	libtoolize -f -c && \
	$(CONFIGURE) --prefix= \
		     --includedir=/usr/include \
	$(if $(MULTICOM406), --enable-multicom406) $(if $(MULTICOM324), --enable-multicom324) \
	$(MAKE)
	touch $@

$(DEPDIR)/libmmeimage: $(DEPDIR)/libmmeimage.do_compile
	$(start_build)
	$(get_git_version)
	cd $(DIR_libmmeimage) && \
		$(INSTALL_libmmeimage)
	CPPFLAGS="\
	$(if $(SPARK), -DPLATFORM_SPARK) \
	$(if $(SPARK7162), -DPLATFORM_SPARK7162) \
	$(if $(HL101), -DPLATFORM_HL101) \
	$(if $(PLAYER179), -DPLAYER179) \
	$(if $(PLAYER191), -DPLAYER191)"
	$(tocdk_build)
	$(toflash_build)
	touch $@

#
# SHOWIFRAME
#
BEGIN[[
showiframe
  git
  {PN}-{PV}
  plink:$(appsdir)/misc/tools/{PN}:{PN}-{PV}
  make:install:DESTDIR=PKDIR
;
]]END

DESCRIPTION_showiframe = "showiframe"
SRC_URI_showiframe = "https://code.google.com/p/tdt-amiko/"
PKGR_showiframe =r1
FILES_showiframe = \
/bin/showiframe

define DISTCLEANUP_showiframe
	cd $(DIR_showiframe) && \
	$(MAKE) distclean
	rm -f $(DEPDIR)/showiframe
	rm -f $(DIR_showiframe)
endef
define DEPSCLEANUP_showiframe
	cd $(DIR_showiframe) && \
	$(MAKE) distclean
	rm -f $(DEPDIR)/showiframe.do_compile
endef

$(DEPDIR)/showiframe.do_prepare: bootstrap $(DEPENDS_showiframe)
	$(PREPARE_showiframe)
	touch $@

$(DEPDIR)/showiframe.do_compile: $(DEPDIR)/showiframe.do_prepare
	export PATH=$(hostprefix)/bin:$(PATH) && \
	cd $(DIR_showiframe) && \
	libtoolize -f -c && \
	$(CONFIGURE) --prefix= \
	$(if $(MULTICOM406), --enable-multicom406) $(if $(MULTICOM324), --enable-multicom324) \
	$(MAKE)
	touch $@

$(DEPDIR)/showiframe: $(DEPDIR)/showiframe.do_compile
	$(start_build)
	$(get_git_version)
	cd $(DIR_showiframe) && \
		$(INSTALL_showiframe)
	CPPFLAGS="\
	$(if $(SPARK), -DPLATFORM_SPARK) \
	$(if $(SPARK7162), -DPLATFORM_SPARK7162) \
	$(if $(HL101), -DPLATFORM_HL101) \
	$(if $(PLAYER179), -DPLAYER179) \
	$(if $(PLAYER191), -DPLAYER191)"
	$(tocdk_build)
	$(toflash_build)
	touch $@

#
#STFBCONTROL
#
BEGIN[[
stfbcontrol
  git
  {PN}-{PV}
  plink:$(appsdir)/misc/tools/{PN}:{PN}-{PV}
  make:install:DESTDIR=PKDIR
;
]]END

DESCRIPTION_stfbcontrol = "stfbcontrol"
SRC_URI_stfbcontrol = "https://code.google.com/p/tdt-amiko/"
PKGR_stfbcontrol = r1
FILES_stfbcontrol = \
/bin/stfbcontrol

define DISTCLEANUP_stfbcontrol
	cd $(DIR_stfbcontrol) && \
	$(MAKE) distclean
	rm -f $(DEPDIR)/stfbcontrol
	rm -f $(DIR_stfbcontrol)
endef
define DEPSCLEANUP_stfbcontrol
	cd $(DIR_stfbcontrol) && \
	$(MAKE) distclean
	rm -f $(DEPDIR)/stfbcontrol.do_compile
endef

$(DEPDIR)/stfbcontrol.do_prepare: bootstrap $(DEPENDS_stfbcontrol)
	$(PREPARE_stfbcontrol)
	touch $@

$(DEPDIR)/stfbcontrol.do_compile: $(DEPDIR)/stfbcontrol.do_prepare
	export PATH=$(hostprefix)/bin:$(PATH) && \
	cd $(DIR_stfbcontrol) && \
	libtoolize -f -c && \
	$(CONFIGURE) --prefix= \
	$(if $(MULTICOM406), --enable-multicom406) $(if $(MULTICOM324), --enable-multicom324) \
	$(MAKE)
	touch $@

$(DEPDIR)/stfbcontrol: $(DEPDIR)/stfbcontrol.do_compile
	$(start_build)
	$(get_git_version)
	cd $(DIR_stfbcontrol) && \
		$(INSTALL_stfbcontrol)
	CPPFLAGS="\
	$(if $(SPARK), -DPLATFORM_SPARK) \
	$(if $(SPARK7162), -DPLATFORM_SPARK7162) \
	$(if $(HL101), -DPLATFORM_HL101) \
	$(if $(PLAYER179), -DPLAYER179) \
	$(if $(PLAYER191), -DPLAYER191)"
	$(tocdk_build)
	$(toflash_build)
	touch $@

#
# STREAMPROXY
#
BEGIN[[
streamproxy
  git
  {PN}-{PV}
  plink:$(appsdir)/misc/tools/{PN}:{PN}-{PV}
  make:install:DESTDIR=PKDIR
;
]]END

DESCRIPTION_streamproxy = "streamproxy"
SRC_URI_streamproxy = "https://code.google.com/p/tdt-amiko/"
PKGR_streamproxy = r1
FILES_streamproxy = \
/bin/streamproxy

define DISTCLEANUP_streamproxy
	cd $(DIR_streamproxy) && \
	$(MAKE) distclean
	rm -f $(DEPDIR)/streamproxy
	rm -f $(DIR_streamproxy)
endef
define DEPSCLEANUP_streamproxy
	cd $(DIR_streamproxy) && \
	$(MAKE) distclean
	rm -f $(DEPDIR)/streamproxy.do_compile
endef

$(DEPDIR)/streamproxy.do_prepare: bootstrap $(DEPENDS_streamproxy)
	$(PREPARE_streamproxy)
	touch $@

$(DEPDIR)/streamproxy.do_compile: $(DEPDIR)/streamproxy.do_prepare
	export PATH=$(hostprefix)/bin:$(PATH) && \
	cd $(DIR_streamproxy) && \
	libtoolize -f -c && \
	$(CONFIGURE) --prefix= \
	$(if $(MULTICOM406), --enable-multicom406) $(if $(MULTICOM324), --enable-multicom324) \
	$(MAKE)
	touch $@

$(DEPDIR)/streamproxy: $(DEPDIR)/streamproxy.do_compile
	$(start_build)
	$(get_git_version)
	cd $(DIR_streamproxy) && \
		$(INSTALL_streamproxy)
	CPPFLAGS="\
	$(if $(SPARK), -DPLATFORM_SPARK) \
	$(if $(SPARK7162), -DPLATFORM_SPARK7162) \
	$(if $(HL101), -DPLATFORM_HL101) \
	$(if $(PLAYER179), -DPLAYER179) \
	$(if $(PLAYER191), -DPLAYER191)"
	$(tocdk_build)
	$(toflash_build)
	touch $@

#
# USTSLAVE
#
BEGIN[[
ustslave
  git
  {PN}-{PV}
  plink:$(appsdir)/misc/tools/{PN}:{PN}-{PV}
  make:install:DESTDIR=PKDIR
;
]]END

DESCRIPTION_ustslave = "ustslave"
SRC_URI_ustslave = "https://code.google.com/p/tdt-amiko/"
PKGR_ustslave = r1
FILES_ustslave = \
/bin/ustslave

define DISTCLEANUP_ustslave
	cd $(DIR_ustslave) && \
	$(MAKE) distclean
	rm -f $(DEPDIR)/ustslave
	rm -f $(DIR_ustslave)
endef
define DEPSCLEANUP_ustslave
	cd $(DIR_ustslave) && \
	$(MAKE) distclean
	rm -f $(DEPDIR)/ustslave.do_compile
endef

$(DEPDIR)/ustslave.do_prepare: bootstrap $(DEPENDS_ustslave)
	$(PREPARE_ustslave)
	touch $@

$(DEPDIR)/ustslave.do_compile: $(DEPDIR)/ustslave.do_prepare
	export PATH=$(hostprefix)/bin:$(PATH) && \
	cd $(DIR_ustslave) && \
	libtoolize -f -c && \
	$(CONFIGURE) --prefix= \
	$(if $(MULTICOM406), --enable-multicom406) $(if $(MULTICOM324), --enable-multicom324) \
	$(MAKE)
	touch $@

$(DEPDIR)/ustslave: $(DEPDIR)/ustslave.do_compile
	$(start_build)
	$(get_git_version)
	cd $(DIR_ustslave) && \
		$(INSTALL_ustslave)
	CPPFLAGS="\
	$(if $(SPARK), -DPLATFORM_SPARK) \
	$(if $(SPARK7162), -DPLATFORM_SPARK7162) \
	$(if $(HL101), -DPLATFORM_HL101) \
	$(if $(PLAYER179), -DPLAYER179) \
	$(if $(PLAYER191), -DPLAYER191)"
	$(tocdk_build)
	$(toflash_build)
	touch $@

#
# EPLAYER4
#
BEGIN[[
eplayer4
  git
  {PN}-{PV}
  plink:$(appsdir)/misc/tools/{PN}:{PN}-{PV}
  make:install:DESTDIR=PKDIR
;
]]END

DESCRIPTION_eplayer4 = "eplayer4"
SRC_URI_eplayer4 = "https://code.google.com/p/tdt-amiko/"
PKGR_eplayer4 = r1
FILES_eplayer4 = \
/bin/eplayer4

define DISTCLEANUP_eplayer4
	cd $(DIR_eplayer4) && \
	$(MAKE) distclean
	rm -f $(DEPDIR)/eplayer4
	rm -f $(DIR_eplayer4)
endef
define DEPSCLEANUP_eplayer4
	cd $(DIR_eplayer4) && \
	$(MAKE) distclean
	rm -f $(DEPDIR)/eplayer4.do_compile
endef

$(DEPDIR)/eplayer4.do_prepare: bootstrap $(DEPENDS_eplayer4)
	$(PREPARE_eplayer4)
	touch $@

$(DEPDIR)/eplayer4.do_compile: $(DEPDIR)/eplayer4.do_prepare
	export PATH=$(hostprefix)/bin:$(PATH) && \
	cd $(DIR_eplayer4) && \
	libtoolize -f -c && \
	$(CONFIGURE) --prefix= \
	$(if $(MULTICOM406), --enable-multicom406) $(if $(MULTICOM324), --enable-multicom324) \
	$(MAKE)
	touch $@

$(DEPDIR)/eplayer4: $(DEPDIR)/eplayer4.do_compile
	$(start_build)
	$(get_git_version)
	cd $(DIR_eplayer4) && \
		$(INSTALL_eplayer4)
	CPPFLAGS="\
	$(if $(SPARK), -DPLATFORM_SPARK) \
	$(if $(SPARK7162), -DPLATFORM_SPARK7162) \
	$(if $(HL101), -DPLATFORM_HL101) \
	$(if $(PLAYER179), -DPLAYER179) \
	$(if $(PLAYER191), -DPLAYER191)"
	$(tocdk_build)
	$(toflash_build)
	touch $@