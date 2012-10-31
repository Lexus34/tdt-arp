TODO:
* What to do with precompiled binaries/drivers.
* Missing binaries/drivers.
* Common binaries and drivers
* Create custom directories for each box with configs in static/
   halt
   fstab
   keymap
   auto.usb
   lircd.conf
   hostname
   ...
* What to do with drivers which are common but are not build for every box. Maybe as simple as if [ -e...
   cp $(kernelprefix)/linux-sh4/drivers/usb/serial/ftdi_sio.ko $(prefix)/release/lib/modules/ftdi.ko
   cp $(kernelprefix)/linux-sh4/drivers/usb/serial/pl2303.ko $(prefix)/release/lib/modules
   cp $(kernelprefix)/linux-sh4/drivers/usb/serial/usbserial.ko $(prefix)/release/lib/modules
   cp $(kernelprefix)/linux-sh4/fs/autofs4/autofs4.ko $(prefix)/release/lib/modules

audio710x:
   cp $(staticprefix)/firmware/audio.elf $(releaseprefix)/boot/audio.elf
audio7105:
   cp $(staticprefix)/firmware/audio_7105.elf $(releaseprefix)/boot/audio.elf
video7100:
   cp $(staticprefix)/firmware/video.elf $(releaseprefix)/boot/video.elf
video7109:
   cp $(staticprefix)/firmware/video_7109.elf $(releaseprefix)/boot/video.elf
video7105:
   cp $(staticprefix)/firmware/video_7105.elf $(releaseprefix)/boot/video.elf
video7111:
   cp $(staticprefix)/firmware/video_7111.elf $(releaseprefix)/boot/video.elf

cpu7100: audio710x video7100
   cp $(targetprefix)/lib/modules/$(KERNELVERSION)/extra/stgfb/stmfb/stmcore-display-stx7100.ko $(releaseprefix)/lib/modules/
cpu7101: cpu7109
cpu7109: audio710x video7109
   cp $(targetprefix)/lib/modules/$(KERNELVERSION)/extra/stgfb/stmfb/stmcore-display-stx7109c3.ko $(releaseprefix)/lib/modules/
cpu7105: audio7105 video7105
   cp $(targetprefix)/lib/modules/$(KERNELVERSION)/extra/stgfb/stmfb/stmcore-display-stx7105.ko $(releaseprefix)/lib/modules/
   cp $(prefix)/release/lib/firmware/component_7105_pdk7105.fw $(releaseprefix)/lib/firmware/component.fw
cpu7111: audio7105 video7111
   cp $(targetprefix)/lib/modules/$(KERNELVERSION)/extra/stgfb/stmfb/stmcore-display-stx7111.ko $(releaseprefix)/lib/modules/
   cp $(prefix)/release/lib/firmware/component_7111_mb618.fw $(releaseprefix)/lib/firmware/component.fw


release_spark: cpu7111
   cp $(targetprefix)/lib/modules/$(KERNELVERSION)/extra/frontcontroller/aotom/aotom.ko $(releaseprefix)/lib/modules/

release_spark7162: cpu7105
   cp $(targetprefix)/lib/modules/$(KERNELVERSION)/extra/frontcontroller/aotom/aotom.ko $(releaseprefix)/lib/modules/

release_hl101: cpu7101
   cp $(targetprefix)/lib/modules/$(KERNELVERSION)/extra/frontcontroller/proton/proton.ko $(releaseprefix)/lib/modules/

release_common:
cp -f $(targetprefix)/sbin/shutdown $(releaseprefix)/sbin/



