#import "WDDManager.h"
#import "WDDUtils.h"
#import "TWHeaders.h"
#import "WDDLayoutShared.h"

static UIView *WDDAdapterHostView(id adapter) {
    if (!adapter) return nil;
    SEL sel = NSSelectorFromString(@"hostView");
    if ([adapter respondsToSelector:sel]) {
        @try {
            id host = ((id (*)(id, SEL))objc_msgSend)(adapter, sel);
            if ([host isKindOfClass:[UIView class]]) return host;
        } @catch (__unused NSException *e) {}
    }
    return nil;
}

static BOOL WDDAdapterShouldHideMedia(id adapter) {
    return WDDShouldHideTimelineMedia(WDDAdapterHostView(adapter));
}

%hook T1StandardStatusAttachmentViewAdapter

- (unsigned long long)attachmentType {
    unsigned long long origType = %orig;
    if (origType == 2 && WDDAdapterShouldHideMedia(self)) {
        return 0;
    }
    return origType;
}

- (id)autoplayPlayerContainer {
    if (WDDAdapterShouldHideMedia(self)) {
        return nil;
    }
    return %orig;
}

- (id)layoutStateForViewModel:(id)viewModel layoutMetrics:(id)layoutMetrics {
    id state = %orig;
    if (!state) return state;

    id cardState = nil, unifiedCardState = nil, quotedState = nil;
    @try { cardState = [state valueForKey:@"cardViewLayoutState"]; } @catch (__unused NSException *e) {}
    @try { unifiedCardState = [state valueForKey:@"unifiedCardViewLayoutState"]; } @catch (__unused NSException *e) {}
    @try { quotedState = [state valueForKey:@"quotedStandardStatusViewLayoutState"]; } @catch (__unused NSException *e) {}
    if (cardState || unifiedCardState || quotedState) {
        return state;
    }

    if (WDDAdapterShouldHideMedia(self)) {
        @try { [state setValue:@(0) forKey:@"attachmentType"]; } @catch (__unused NSException *e) {}

        if ([state respondsToSelector:NSSelectorFromString(@"setSize:")]) {
            @try {
                [state setValue:[NSValue valueWithCGSize:CGSizeZero] forKey:@"size"];
            } @catch (__unused NSException *e) {}
        }
        if ([state respondsToSelector:NSSelectorFromString(@"setUseAdaptiveMediaLayout:")]) {
            @try { [state setValue:@NO forKey:@"useAdaptiveMediaLayout"]; } @catch (__unused NSException *e) {}
        }
        return state;
    }

    if ([WDDManager enableSingleImageSizing]) {
        CGSize size = CGSizeZero;
        @try { size = [[state valueForKey:@"size"] CGSizeValue]; } @catch (__unused NSException *e) {}
        if (size.width > 0 && size.height > 0) {
            CGFloat target = size.width * 9.0 / 16.0;
            if (target < size.height - 0.5) {
                size.height = target;
                if ([state respondsToSelector:NSSelectorFromString(@"setSize:")]) {
                    @try { [state setValue:[NSValue valueWithCGSize:size] forKey:@"size"]; } @catch (__unused NSException *e) {}
                }
            }
        }
    }

    return state;
}

- (id)_t1_quotedStandardStatusViewLayoutStateForViewModel:(id)viewModel layoutMetrics:(id)layoutMetrics width:(double)width {
    g_isCalculatingQuotedLayout = YES;
    BOOL adjusted = NO;
    if ([WDDManager hideAvatar] && !g_hasAdjustedQuotedWidth) {
        width += 56.0;
        g_hasAdjustedQuotedWidth = YES;
        adjusted = YES;
    }
    id result = %orig(viewModel, layoutMetrics, width);
    if (adjusted) {
        g_hasAdjustedQuotedWidth = NO;
    }
    g_isCalculatingQuotedLayout = NO;
    return result;
}

- (CGSize)_t1_verticalPhotoSizeForAspectRatio:(double)aspectRatio width:(double)width {
    if (WDDAdapterShouldHideMedia(self)) {
        return CGSizeZero;
    }
    if (![WDDManager enableSingleImageSizing]) {
        return %orig;
    }
    if (width <= 0) {
        return %orig;
    }
    CGSize orig = %orig;

    CGFloat w = orig.width > 0 ? orig.width : width;
    CGFloat target = w * 9.0 / 16.0;

    if (orig.height > 0 && target >= orig.height) {
        return orig;
    }
    return CGSizeMake(w, target);
}

- (CGSize)_t1_photoVideoForwardViewSizeForViewModel:(id)viewModel layoutMetrics:(id)layoutMetrics width:(double)width attachmentType:(unsigned long long)type {
    if (WDDAdapterShouldHideMedia(self)) {
        return CGSizeZero;
    }
    if (![WDDManager enableSingleImageSizing]) {
        return %orig;
    }

    CGSize size = %orig;

    CGFloat baseWidth = size.width > 0 ? size.width : width;
    if (baseWidth <= 0) {
        return size;
    }
    CGFloat target = baseWidth * 9.0 / 16.0;
    if (size.height > 0 && target >= size.height) {
        return size;
    }
    return CGSizeMake(baseWidth, target);
}

- (id)_t1_unifiedCardViewLayoutStateForViewModel:(id)viewModel unifiedCard:(id)unifiedCard shouldHideFooter:(BOOL)shouldHideFooter layoutMetrics:(id)layoutMetrics width:(double)width {
    BOOL hideSource = [WDDManager hideSourceAttribution];
    if (hideSource) {
        shouldHideFooter = YES;
    }

    id result = nil;
    if (WDDAdapterShouldHideMedia(self)) {
        BOOL previous = g_wddThreadCollapseUnifiedCard;
        g_wddThreadCollapseUnifiedCard = YES;
        result = %orig(viewModel, unifiedCard, shouldHideFooter, layoutMetrics, width);
        g_wddThreadCollapseUnifiedCard = previous;
    } else {
        result = %orig(viewModel, unifiedCard, shouldHideFooter, layoutMetrics, width);
    }

    if (hideSource && result) {
        CGSize cardSize = CGSizeZero;
        @try {
            NSValue *value = [result valueForKey:@"size"];
            if ([value isKindOfClass:[NSValue class]]) cardSize = [value CGSizeValue];
        } @catch (__unused NSException *e) {}

        if (cardSize.height > 0.0 && cardSize.height <= 44.0) {
            @try {
                [result setValue:[NSValue valueWithCGSize:CGSizeZero] forKey:@"size"];
            } @catch (__unused NSException *e) {}
        }
    }

    return result;
}

%end

%ctor {
    %init;
}
