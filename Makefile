ARCHS = arm64
TARGET := iphone:clang:16.5:14.0
INSTALL_TARGET_PROCESSES = Twitter

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = wddtwitter

wddtwitter_FILES = WDDTweak.x WDDSettingsViewController.m WDDUIComponents.m BHDimPalette.m WDDManager.m WDDUtils.m WDDFilters.x WDDLayoutShared.m WDDViewModelMask.x WDDConnectorLayout.x WDDSpam.x WDDMediaLayout.x WDDCardLayout.x WDDArticleSource.x WDDGrok.x WDDViewCount.x WDDGestures.x WDDSettings.x
wddtwitter_FRAMEWORKS = UIKit Foundation CoreGraphics Photos
wddtwitter_CFLAGS = -fobjc-arc -Wno-deprecated-declarations -Wno-unused-variable -Wno-unused-function

include $(THEOS_MAKE_PATH)/tweak.mk
