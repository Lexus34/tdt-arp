# header
#############################################################################

# in case you reference ${P} outside function[[ or package[[ directive
# it is expanded relative to current target name.
# targets should have only one '.' in their filenames !
P = $(subst -,_,$(basename $(notdir $@)))

function[[ header
# place in Makefile.in
${P} := $(subst _,-,${P})
TARGET_${P} := $(DEPDIR)/$(${P})
SYSROOT_${P} := $(word 1,$(subst _, ,${P}))
]]function




# base
#############################################################################

help::
	@echo run \'make all\' if really want to build everything
.PHONY: all

function[[ base
# place after variables definitions in *.mk file and before rule

# Check requirements
${P} ?= $(error undefined ${P})
PV_${P} ?= $(error undefined PV_${P})
PR_${P} ?= $(error undefined PR_${P})
TARGET_${P} ?= $(error undefined TARGET_${P})

# Provide defaults
PN_${P} ?= $(patsubst host-%,%,$(patsubst cross-%,%,$(patsubst target-%,%, $(${P}) )))
DIR_${P} ?= $(workprefix)/${PN}-${PV}
PACKAGE_ARCH_${P} ?= sh4

# opkg control default values
VERSION_${P} ?= ${PV}-${PR}
DESCRIPTION_${P} ?= ${P}
MAINTAINER_${P} ?= Ar-P team
SECTION_${P} ?= base
PRIORITY_${P} ?= optional
LICENSE_${P} ?= unknown
HOMEPAGE_${P} ?= unknown

# build dependencies
DEPENDS_${P} += $(TARGET_${P}).version_${PV}-${PR}
DEPENDS_${P} += $(addprefix $(DEPDIR)/,$(BDEPENDS_${P}))

# Set new variables and targets
PREPARE_${P} = (rm -rf $(DIR_${P}) || true)
INSTALL_${P} = true

$(TARGET_${P}).version_%:
	rm -f $(TARGET_${P}).version_*
	touch $@

$(TARGET_${P}).clean_prepare:
	rm -f $(TARGET_${P}).do_prepare

$(TARGET_${P}).clean_compile:
	rm -f $(TARGET_${P}).do_compile

$(TARGET_${P}).clean_package:
	rm -f $(TARGET_${P}).do_package

$(TARGET_${P}).clean:
	rm -f $(TARGET_${P})

# to add some build rules add prerequisites to this target
$(TARGET_${P}):
	touch $@

# add to list
all: $(TARGET_${P})

]]function

function[[ TARGET_base_do_prepare
# place after variables and rule definitions
$(TARGET_${P}).do_prepare: $(DEPENDS_${P})
	$(PREPARE_${P})
	touch $@
]]function

function[[ TARGET_base_do_config
# place after variables and rule definitions
$(TARGET_${P}).do_menuconfig $(TARGET_${P}).do_xconfig: \
$(TARGET_${P}).do_%: $(TARGET_${P}).do_prepare
	cd $(DIR_${P}) && make $(MAKE_FLAGS_${P}) $*
	@echo
	@echo "You have to edit m a n u a l l y Patches/...${PN}...config to make changes permanent !!!"
	@echo ""
	diff $(DIR_${P})/.config.old $(DIR_${P})/.config
	@echo
	touch $@
]]function

function[[ base_bare
$(warning obsolete base_bare)
call[[ base ]]
]]function



# ipk
#############################################################################

# ipk related constants
INHERIT_VARIABLES := NAME VERSION DESCRIPTION SECTION PRIORITY MAINTAINER LICENSE PACKAGE_ARCH HOMEPAGE RDEPENDS RREPLACES RCONFLICTS SRC_URI FILES
INHERIT_DEFINES := preinst postinst prerm postrm conffiles

# we have several dests, so dependencies are shared across them
host_ipkg_args = -f $(prefix)/opkg.conf -o $(prefix) -d hostroot
cross_ipkg_args = -f $(prefix)/opkg.conf -o $(prefix) -d crossroot
target_ipkg_args = -f $(prefix)/opkg.conf -o $(prefix) -d targetroot

# format list separated with spaces to list separeated with commas
_ipk_control_list = $(subst $(space),$(comma),$(subst $(space)$(space),$(space),$(subst _,-,$(strip $1))))

# _ipk_write_control
# - 1: pkg that contains variables
# - 2: control file to write into
define _ipk_write_control_common
	$(eval export DESCRIPTION_$1)
	echo "Description: $${DESCRIPTION_$1}" >> $2
	echo 'Section: $(SECTION_$1)' >> $2
	echo 'Priority: $(PRIORITY_$1)' >> $2
	echo 'Maintainer: $(MAINTAINER_$1)' >> $2
	echo 'License: $(LICENSE_$1)' >> $2
	echo 'Homepage: $(HOMEPAGE_$1)' >> $2
	echo 'Source: $(SRC_URI_$1)' >> $2
endef
define _ipk_write_control
	echo 'Package: $(${P})' > $2
	echo 'Version: $(VERSION_$1)' >> $2
	echo 'Architecture: $(PACKAGE_ARCH_$1)' >> $2
	echo 'Depends: $(call _ipk_control_list,$(BDEPENDS_$1))' >> $2
	echo 'Replaces: $(call _ipk_control_list,$(BREPLACES_$1))' >> $2
	echo 'Conflicts: $(call _ipk_control_list,$(BCONFLICTS_$1))' >> $2
	$(call _ipk_write_control_common,$1,$2)
endef

# adapt files for cross compiling
rewrite_libtool = \
	find $(ipkgbuilddir)/* -name "*.la" -type f -exec \
		perl -pi -e "s,^libdir=.*$$,libdir='$(targetprefix)/usr/lib'," {} \;
rewrite_dependency = \
	find $(ipkgbuilddir)/* -name "*.la" -type f -exec \
		perl -pi -e "s, /usr/lib, $(targetprefix)/usr/lib,g if /^dependency_libs/" {} \;
rewrite_pkgconfig = \
	find $(ipkgbuilddir)/* -name "*.pc" -type f -exec \
		perl -pi -e "s,^prefix=.*$$,prefix=$(targetprefix)/usr," {} \;
#FIXME: unpackaged 'cp'
rewrite_config = \
	cp $1 $(crossprefix)/bin/$(notdir $1) && \
	sed -e "s,^prefix=,prefix=$(targetprefix)," -i $(crossprefix)/bin/$(notdir $1)

function[[ ipk
# SYSROOT is one of host, cross, target
SYSROOT_${P} ?= $(error undefined SYSROOT_${P})
# Name of IPK that installs to SYSROOT
IPK_${P} ?= $(ipk${SYSROOT})/$(${P})_${VERSION}_${PACKAGE_ARCH}.ipk

# for sysroot ipk we copy all files.
$(TARGET_${P}).do_ipk: $(TARGET_${P}).do_package
	rm -rf $(ipkgbuilddir)
	mkdir -p $(ipkgbuilddir)/${P}/CONTROL
ifeq (${SYSROOT},host)
	cp -ar $(PKDIR)/$(hostprefix)/* $(ipkgbuilddir)/${P}
endif
ifeq (${SYSROOT},cross)
	cp -ar $(PKDIR)/$(crossprefix)/* $(ipkgbuilddir)/${P}
endif
ifeq (${SYSROOT},target)
	cp -ar $(PKDIR)/* $(ipkgbuilddir)/${P}
	$(rewrite_libtool)
	$(rewrite_dependency)
endif

	$(call _ipk_write_control,${P},$(ipkgbuilddir)/${P}/CONTROL/control)

	rm -rf $(ipkverify)/*
	mkdir -p $(ipkverify)
	ipkg-build -o root -g root $(ipkgbuilddir)/${P} $(ipkverify)

# make shure the built ipk has name defined by IPK_${P} variable !
	test '$(notdir $(IPK_${P}))' == "`ls $(ipkverify)`" || \
	  (echo built package does not match IPK_${P} && false)

	rm -rf $(IPK_${P})
	mv -v $(ipkverify)/* $(IPK_${P})
	touch $@

$(TARGET_${P}).clean_ipk:
	rm -rf $(TARGET_${P}).do_ipk

# finally install
$(TARGET_${P}).do_install: $(TARGET_${P}).do_ipk
	opkg $($(SYSROOT_${P})_ipkg_args) install $(IPK_${P})
# I need this flag to make dependencies work correctly
	opkg $($(SYSROOT_${P})_ipkg_args) flag installed $(${P})
	touch $@

$(TARGET_${P}): $(TARGET_${P}).do_install

# currently not in use.
$(TARGET_${P}).do_preclean:
	opkg $($(SYSROOT_${P})_ipkg_args) --force-removal-of-dependent-packages remove $(${P})
	touch $@

]]function



# ipkbox
#############################################################################

help-functions::
	@echo
	@echo write_control
	@echo - 1: package name

write_control = $(call _ipkbox_write_control,$1,$(ipkgbuilddir)/$1/CONTROL/control)

# _ipkbox_write_control
# - 1: pkg that contains variables
# - 2: control file to write into
define _ipkbox_write_control
	echo 'Package: $(NAME_$1)' > $2
	echo 'Version: $(VERSION_$1)' >> $2
	echo 'Architecture: $(PACKAGE_ARCH_$1)' >> $2
	echo 'Depends: $(call _ipk_control_list,$(RDEPENDS_$1))' >> $2
	echo 'Replaces: $(call _ipk_control_list,$(RREPLACES_$1))' >> $2
	echo 'Conflicts: $(call _ipk_control_list,$(RCONFLICTS_$1))' >> $2

	$(call _ipk_write_control_common,$1,$2)

	$(foreach file, preinst postinst prerm postrm conffiles,
		$(if $($(file)_$1),
			$(eval export $(file)_$1)
			$(info $($(file)_$1))
			printenv $(file)_$1 > $(ipkgbuilddir)/$1/CONTROL/$(file)
		)
	)
	$(foreach file, preinst postinst prerm postrm,
		$(if $($(file)_$1),
			 chmod +x $(ipkgbuilddir)/$(pkg)/CONTROL/$(file)
		)
	)
endef

define strip_libs
	find $(PKDIR) -type f -regex '.*/lib/.*\.so\(\.[0-9]+\)*' \
		-exec echo strip {} \; \
		-exec $(target)-strip --strip-unneeded {} \;
endef
define remove_libs
	rm -f $(PKDIR)/lib/*.{a,la,o}
	rm -f $(PKDIR)/usr/lib/*.{a,la,o}
endef
define remove_pkgconfigs
	rm -rf $(PKDIR)/usr/lib/pkgconfig
endef
define remove_includedir
	rm -rf $(PKDIR)/usr/include
endef
define remove_docs
	rm -rf $(PKDIR)/usr/share/doc
	rm -rf $(PKDIR)/usr/share/man
	rm -rf $(PKDIR)/usr/share/info
	rm -rf $(PKDIR)/usr/share/locale
	rm -rf $(PKDIR)/usr/share/gtk-doc
endef

# - 1: ${P}
define _ipkbox_do_split
	$(foreach pkg, $(PACKAGES_$1),
		install -d $(ipkgbuilddir)/$(pkg)/CONTROL/
		$(call write_control,$(pkg))
		$(eval export FILES_$(pkg))
	)
	python $(buildprefix)/split.py $(PKDIR) $(ipkgbuilddir) $(PACKAGES_$1)
endef

function[[ ipkbox

PACKAGES_${P} ?= $(patsubst host_%,%,$(patsubst cross_%,%,$(patsubst target_%,%, ${P} )))
FILES_${P} ?= /

$(TARGET_${P}).set_inherit_vars: $(TARGET_${P}).do_package
	$(info ==> $(notdir $@)) \
	$(foreach pkg, $(PACKAGES_${P}), \
		$(foreach var, $(INHERIT_VARIABLES), \
			$(if $($(var)_$(pkg)),,\
				$(call eval_assign,$(var)_$(pkg),$(var)_${P}) \
			) \
		) \
		$(if $(NAME_$(pkg)),, \
			$(eval NAME_$(pkg) := $(subst _,-,$(pkg)) ) \
		) \
		$(foreach var, $(INHERIT_DEFINES), \
			$(if $($(var)_$(pkg)),,\
				$(call eval_define,$(var)_$(pkg),$(var)_${P}) \
			) \
		) \
	)

.PHONY: $(TARGET_${P}).set_inherit_vars

$(TARGET_${P}).do_split: $(TARGET_${P}).do_package | $(TARGET_${P}).set_inherit_vars
	rm -rf $(ipkgbuilddir)/*
	mkdir -p $(ipkgbuilddir)

	$(call _ipkbox_do_split,${P})

	touch $@

$(TARGET_${P}).do_ipkbox: $(TARGET_${P}).do_split
	$(remove_docs)
	$(remove_libs)
	$(remove_pkgconfigs)
	$(remove_includedir)
	$(strip_libs)

	set -e; \
	for pkg in `ls $(ipkgbuilddir)`; do \
		echo "building package $${pkg} ..."; \
		ipkg-build -o root -g root $(ipkgbuilddir)/$${pkg} $(ipkbox); \
	done

	touch $@

$(TARGET_${P}): $(TARGET_${P}).do_ipkbox

]]function



# git
#############################################################################

# git staff related constants
# you need first 'cd' to interesting directory
git_log_srcrev := git log -1 --format=%H HEAD -- .
git_log_version := echo `git rev-list --count HEAD -- .`-`git log -1 --format=%h HEAD -- .`

help::
	@echo run \'make all-update\' if you want to check all git/svn packages for updates
.PHONY: all-update

function[[ git
# place after rule definitions
# now you have GIT_VERSION_${P} variable

# Check requirements
GIT_DIR_${P} ?= $(error undefined GIT_DIR_${P})

# Set file where we store srcrev
SRCREV_${P} = $(TARGET_${P}).do_srcrev

# add dependencies:
# you need do_srcrev at prepare time, so if git is updated all rebuilds.
$(TARGET_${P}).do_prepare: $(SRCREV_${P})
# I assume you need GIT_VERSION variable at packaging time
$(TARGET_${P}).do_package: $(TARGET_${P}).do_git_version

# initial srcrev value
$(SRCREV_${P}): $(GIT_DIR_${P})
	$(UPDATE_${P})
	cd $(GIT_DIR_${P}) && $(git_log_srcrev) > ${SRCREV}

# update stored srcrev if it has changed
$(TARGET_${P}).do_update: $(GIT_DIR_${P})
	@echo && echo "==> checking ${SRCREV}" && echo
	$(UPDATE_${P})
	cd $(GIT_DIR_${P}) && $(git_log_srcrev) > ${SRCREV}_tmp

	(test -f ${SRCREV} && test "`cat ${SRCREV}_tmp`" == "`cat ${SRCREV}`") \
	|| (cp ${SRCREV}_tmp ${SRCREV} && touch ${SRCREV} && \
	    echo && echo "==> updated ${SRCREV}" && echo)
	
	rm -f ${SRCREV}_tmp

VERSION_${P} = ${PV}${GIT_VERSION}

# GIT_VERSION_${P} is dynamic variable
# We use dynamic variables pattern,
# I suggest to use such Makefile 'hack' everytime you deal with dynamic variables

# end user target is do_git_version, specify it as prerequisite if you access dynamic variable
$(TARGET_${P}).do_git_version: $(TARGET_${P}).write_git_version | $(TARGET_${P}).include_git_version
	touch $@

# inlude is evaluated every time make runs, beacause it is phony target and specified as oder-only prerequisite
$(TARGET_${P}).include_git_version: $(TARGET_${P}).write_git_version
	@echo "==> include $<"
	$(eval include $<)

.PHONY: $(TARGET_${P}).include_git_version

# Here we specify the main code of generating dynamic variables
# output file will be included by make at run time
$(TARGET_${P}).write_git_version: $(GIT_DIR_${P})
	echo -n "GIT_VERSION_${P} := " > $@
	cd $(GIT_DIR_${P}) && $(git_log_version) >> $@

# add to list
all-update: $(TARGET_${P}).do_update

]]function