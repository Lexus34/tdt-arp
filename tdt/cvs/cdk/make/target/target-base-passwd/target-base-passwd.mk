#
# AR-P buildsystem smart Makefile
#
package[[ target_base_passwd

BDEPENDS_${P} = $(target_filesystem) $(host_base_passwd)

PR_${P} = 2

${P}_VERSION = 3.5.9-11
${P}_SPEC = stm-$(${P}).spec
${P}_SPEC_PATCH =
${P}_PATCHES =
${P}_SRCRPM = $(archivedir)/$(STLINUX)-$(${P})-$(${P}_VERSION).src.rpm

call[[ base ]]
call[[ base_rpm ]]

call[[ rpm_do_compile ]]

$(TARGET_${P}).do_package: $(TARGET_${P}).do_compile
	$(PKDIR_clean)
	$(fromrpm_copy)
	mv $(PKDIR)/$(targetprefix)/* $(PKDIR)
	touch $@

FILES_${P} = /etc/* /usr/*
define postinst_${P}
#!/bin/sh
update-passwd -L \
-p $$OPKG_OFFLINE_ROOT/usr/share/base-passwd/passwd.master \
-g $$OPKG_OFFLINE_ROOT/usr/share/base-passwd/group.master \
-P $$OPKG_OFFLINE_ROOT/etc/passwd \
-S $$OPKG_OFFLINE_ROOT/etc/shadow \
-G $$OPKG_OFFLINE_ROOT/etc/group
endef

call[[ ipkbox ]]

]]package