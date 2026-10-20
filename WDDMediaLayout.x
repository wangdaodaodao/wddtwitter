#import "WDDManager.h"
#import "WDDUtils.h"
#import "TWHeaders.h"
#import "WDDLayoutShared.h"

%hook T1StandardStatusAttachmentViewAdapter

- (unsigned long long)attachmentType {
    unsigned long long origType = %orig;
    if (origType == 2) {
        if (WDDShouldHideTimelineMedia(nil)) {
            return 0;
        }
    }
    return origType;
}

- (id)photoVideoForwardView {
    if (WDDShouldHideTimelineMedia(nil)) {
        return nil;
    }
    return %orig;
}

- (id)autoplayPlayerContainer {
    if (WDDShouldHideTimelineMedia(nil)) {
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

    if (WDDShouldHideTimelineMedia(nil)) {
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
    if (WDDShouldHideTimelineMedia(nil)) {
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
    if (WDDShouldHideTimelineMedia(nil)) {
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
    if (WDDShouldHideTimelineMedia(nil)) {
        BOOL previous = g_wddThreadCollapseUnifiedCard;
        g_wddThreadCollapseUnifiedCard = YES;
        id result = %orig(viewModel, unifiedCard, shouldHideFooter, layoutMetrics, width);
        g_wddThreadCollapseUnifiedCard = previous;
        return result;
    }
    return %orig(viewModel, unifiedCard, shouldHideFooter, layoutMetrics, width);
}

%end

@interface T1StandardStatusAttachmentViewLayoutState : NSObject
@end

%hook T1StandardStatusAttachmentViewLayoutState

- (unsigned long long)attachmentType {
    unsigned long long type = %orig;
    if (type == 0) return 0;
    if (!WDDShouldHideTimelineMedia(nil)) return type;

    id cardState = nil, unifiedCardState = nil, quotedState = nil;
    @try { cardState = [self valueForKey:@"cardViewLayoutState"]; } @catch (__unused NSException *e) {}
    @try { unifiedCardState = [self valueForKey:@"unifiedCardViewLayoutState"]; } @catch (__unused NSException *e) {}
    @try { quotedState = [self valueForKey:@"quotedStandardStatusViewLayoutState"]; } @catch (__unused NSException *e) {}
    if (cardState || unifiedCardState || quotedState) return type;

    return 0;
}

%end

%ctor {
    %init;
}
