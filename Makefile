include $(THEOS)/makefiles/common.mk

export THEOS_DEVICE_PORT = 9991

TWEAK_NAME = OneNoteScrollFix
OneNoteScrollFix_FILES = Tweak.xm

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 OneNote; exit 0;"
