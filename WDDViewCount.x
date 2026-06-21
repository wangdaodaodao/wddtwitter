#import "WDDManager.h"
#import <objc/runtime.h>

// ==============================
// View Count Hiding Logic
// ==============================

%hook _TtC9T1Twitter33T1StatusViewCountDisplayHelperApp

+ (BOOL)isShowViewCountTopRightEnabled {
    if ([WDDManager hideTimelineViewCount]) {
        return NO;
    }
    return %orig;
}

+ (BOOL)isViewCountHomeTimelineEnabled {
    if ([WDDManager hideTimelineViewCount]) {
        return NO;
    }
    return %orig;
}

+ (BOOL)shouldShowViewCountFor:(id)status viewModel:(id)viewModel isKnownFocal:(BOOL)isKnownFocal {
    if ([WDDManager hideTimelineViewCount]) {
        return NO;
    }
    return %orig(status, viewModel, isKnownFocal);
}

%end
