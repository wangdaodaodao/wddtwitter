#import "WDDManager.h"
#import "WDDUtils.h"
#import "TWHeaders.h"
#import "WDDLayoutShared.h"

%hook T1QuotedStandardStatusView
- (void)layoutSubviews {
    %orig;

    if ([WDDManager hideAvatar]) {
        UIView *avatarView = nil;
        for (UIView *subview in ((UIView *)self).subviews) {
            if (isAvatarClass([subview class])) {
                avatarView = subview;
                break;
            }
        }

        if (avatarView) {
            CGRect avatarFrame = avatarView.frame;
            if (avatarFrame.size.width > 0) {
                CGFloat maxHeaderY = avatarFrame.origin.y + avatarFrame.size.height + 4.0;
                CGFloat minTextX = 9999.0;

                for (UIView *subview in ((UIView *)self).subviews) {
                    if (subview == avatarView) continue;
                    CGRect f = subview.frame;
                    if (f.origin.x > avatarFrame.origin.x && f.origin.y < maxHeaderY && f.size.width > 0 && f.size.height > 0) {

                        if (f.size.width < ((UIView *)self).bounds.size.width - 20.0) {
                            if (f.origin.x < minTextX) {
                                minTextX = f.origin.x;
                            }
                        }
                    }
                }

                CGFloat shiftAmount = 0.0;
                if (minTextX < 9999.0 && minTextX > avatarFrame.origin.x) {
                    shiftAmount = minTextX - avatarFrame.origin.x;
                }

                avatarView.hidden = YES;
                avatarView.alpha = 0.0;
                avatarView.frame = CGRectZero;

                if (shiftAmount > 0) {
                    for (UIView *subview in ((UIView *)self).subviews) {
                        if (subview == avatarView) continue;
                        CGRect f = subview.frame;
                        if (f.origin.x > avatarFrame.origin.x && f.origin.y < maxHeaderY && f.size.width > 0 && f.size.height > 0) {
                            if (f.size.width < ((UIView *)self).bounds.size.width - 20.0) {
                                f.origin.x -= shiftAmount;
                                subview.frame = f;
                            }
                        }
                    }
                }
            } else {
                avatarView.hidden = YES;
                avatarView.alpha = 0.0;
                avatarView.frame = CGRectZero;
            }
        }
    }
}
%end

%hook T1QuotedStandardStatusViewLayoutStateGenerator

- (id)layoutStateForViewModel:(id)viewModel options:(unsigned long long)options account:(id)account width:(double)width layoutMetrics:(id)layoutMetrics withPreviousLayoutState:(id)previousLayoutState {
    g_isCalculatingQuotedLayout = YES;
    BOOL adjusted = NO;
    if ([WDDManager hideAvatar] && !g_hasAdjustedQuotedWidth) {
        width += 56.0;
        g_hasAdjustedQuotedWidth = YES;
        adjusted = YES;
    }
    id result = %orig(viewModel, options, account, width, layoutMetrics, previousLayoutState);
    if (adjusted) {
        g_hasAdjustedQuotedWidth = NO;
    }
    g_isCalculatingQuotedLayout = NO;
    return result;
}

- (id)layoutStateForViewModel:(id)viewModel options:(unsigned long long)options account:(id)account layoutMetrics:(id)layoutMetrics withPreviousLayoutState:(id)previousLayoutState {
    g_isCalculatingQuotedLayout = YES;
    id result = %orig;
    g_isCalculatingQuotedLayout = NO;
    return result;
}

- (id)_t1_updateLayoutStateForDefaultQuoteTweetViewModel:(id)viewModel layoutState:(id)layoutState viewAdapterSet:(id)viewAdapterSet options:(unsigned long long)options account:(id)account width:(double)width layoutMetrics:(id)layoutMetrics {
    BOOL adjusted = NO;
    if ([WDDManager hideAvatar] && !g_hasAdjustedQuotedWidth) {
        width += 56.0;
        g_hasAdjustedQuotedWidth = YES;
        adjusted = YES;
    }
    id result = %orig(viewModel, layoutState, viewAdapterSet, options, account, width, layoutMetrics);
    if (adjusted) {
        g_hasAdjustedQuotedWidth = NO;
    }
    return result;
}

- (id)_t1_updateLayoutStateForMediaFirstMediumQuoteTweetViewModel:(id)viewModel layoutState:(id)layoutState viewAdapterSet:(id)viewAdapterSet options:(unsigned long long)options account:(id)account width:(double)width layoutMetrics:(id)layoutMetrics {
    if ([WDDManager enableSingleImageSizing]) {
        return [self _t1_updateLayoutStateForDefaultQuoteTweetViewModel:viewModel layoutState:layoutState viewAdapterSet:viewAdapterSet options:options account:account width:width layoutMetrics:layoutMetrics];
    }
    BOOL adjusted = NO;
    if ([WDDManager hideAvatar] && !g_hasAdjustedQuotedWidth) {
        width += 56.0;
        g_hasAdjustedQuotedWidth = YES;
        adjusted = YES;
    }
    id result = %orig(viewModel, layoutState, viewAdapterSet, options, account, width, layoutMetrics);
    if (adjusted) {
        g_hasAdjustedQuotedWidth = NO;
    }
    return result;
}

%end

%hook T1StatusPhotoVideoForwardView

- (void)setFrame:(CGRect)frame {
    if (WDDShouldHideTimelineMedia(self)) {
        WDDApplyMediaHidden(self, YES);
        %orig(CGRectZero);
        return;
    }
    WDDApplyMediaHidden(self, NO);
    %orig(frame);
}

- (long long)_t1_imageContentMode {
    if (![WDDManager enableSingleImageSizing]) {
        return %orig;
    }
    if ([self respondsToSelector:@selector(numberOfMediaItems)]) {
        if ([self numberOfMediaItems] == 1) {
            if (WDDIsMediaViewerContext(self)) {
                return %orig;
            }
            return 2;
        }
    }
    return %orig;
}

- (void)layoutSubviews {
    if (WDDShouldHideTimelineMedia(self)) {
        WDDApplyMediaHidden(self, YES);

        if (!CGRectIsEmpty(self.frame)) {
            self.frame = CGRectZero;
        }
        return;
    }

    WDDApplyMediaHidden(self, NO);
    %orig;

    if (![WDDManager enableSingleImageSizing]) {
        return;
    }

    if ([self respondsToSelector:@selector(numberOfMediaItems)]) {
        if ([self numberOfMediaItems] == 1) {
            if (WDDIsMediaViewerContext(self)) {
                return;
            }
            if (!self.clipsToBounds) {
                self.clipsToBounds = YES;
            }

            if ([self respondsToSelector:@selector(mediaContainerView)]) {
                UIView *container = [self mediaContainerView];
                if (container) {
                    if (!container.clipsToBounds) {
                        container.clipsToBounds = YES;
                    }
                    makeImageViewsAspectFill(container, container.bounds);
                }
            }
            if ([self respondsToSelector:@selector(inlineMediaView)]) {
                UIView *mediaView = [self inlineMediaView];
                if (mediaView) {
                    if (!mediaView.clipsToBounds) {
                        mediaView.clipsToBounds = YES;
                    }
                    makeImageViewsAspectFill(mediaView, mediaView.bounds);
                }
            }
        }
    }
}
%end

%hook T1UnifiedCardImageView
- (void)setImage:(UIImage *)image {
    WDDApplyMediaHidden(self, WDDShouldHideTimelineMedia(self));
    %orig(image);
}

- (void)setFrame:(CGRect)frame {
    if (WDDShouldHideTimelineMedia(self)) {
        WDDApplyMediaHidden(self, YES);
        %orig(CGRectZero);
        return;
    }
    WDDApplyMediaHidden(self, NO);
    %orig(frame);
}

- (void)layoutSubviews {
    if (WDDShouldHideTimelineMedia(self)) {
        WDDApplyMediaHidden(self, YES);
        if (!CGRectIsEmpty(self.frame)) {
            self.frame = CGRectZero;
        }
        return;
    }
    WDDApplyMediaHidden(self, NO);
    %orig;
}

- (CGSize)sizeThatFits:(CGSize)size {
    if (WDDShouldHideTimelineMedia(self)) {
        return CGSizeZero;
    }
    return %orig(size);
}

- (CGSize)intrinsicContentSize {
    if (WDDShouldHideTimelineMedia(self)) {
        return CGSizeZero;
    }
    return %orig;
}
%end

%hook T1CardImageView
- (void)setImage:(UIImage *)image {
    WDDApplyMediaHidden(self, WDDShouldHideTimelineMedia(self));
    %orig(image);
}

- (void)setFrame:(CGRect)frame {
    if (WDDShouldHideTimelineMedia(self)) {
        WDDApplyMediaHidden(self, YES);
        %orig(CGRectZero);
        return;
    }
    WDDApplyMediaHidden(self, NO);
    %orig(frame);
}

- (void)layoutSubviews {
    if (WDDShouldHideTimelineMedia(self)) {
        WDDApplyMediaHidden(self, YES);
        if (!CGRectIsEmpty(self.frame)) {
            self.frame = CGRectZero;
        }
        return;
    }
    WDDApplyMediaHidden(self, NO);
    %orig;
}

- (CGSize)sizeThatFits:(CGSize)size {
    if (WDDShouldHideTimelineMedia(self)) {
        return CGSizeZero;
    }
    return %orig(size);
}

- (CGSize)intrinsicContentSize {
    if (WDDShouldHideTimelineMedia(self)) {
        return CGSizeZero;
    }
    return %orig;
}
%end

static void WDDUpdateActiveDetailFlag(UIViewController *vc) {
    if (!vc) return;
    if (WDDIsMediaViewerController(vc)) return;

    if (WDDIsCurrentActiveContextDetail()) {
        WDDActiveViewControllerIsDetail = YES;
        return;
    }

    if (vc.presentingViewController && !vc.isBeingDismissed) {
        return;
    }

    WDDActiveViewControllerIsDetail = NO;
}

%hook UIViewController
- (void)viewWillAppear:(BOOL)animated {
    %orig;
    WDDInvalidateMediaViewerCache();

    NSString *className = NSStringFromClass([self class]);
    if ([className hasPrefix:@"UI"] || [className hasPrefix:@"_"]) {
        return;
    }

    UIViewController *parent = self.parentViewController;
    if (parent &&
        ![parent isKindOfClass:[UINavigationController class]] &&
        ![parent isKindOfClass:[UITabBarController class]] &&
        ![parent isKindOfClass:objc_getClass("TFNTabbedViewController")]) {
        return;
    }

    WDDActiveViewController = self;
    WDDUpdateActiveDetailFlag(self);
}

- (void)viewDidAppear:(BOOL)animated {
    %orig;
    WDDInvalidateMediaViewerCache();

    NSString *className = NSStringFromClass([self class]);
    if ([className hasPrefix:@"UI"] || [className hasPrefix:@"_"]) {
        return;
    }

    UIViewController *parent = self.parentViewController;
    if (parent &&
        ![parent isKindOfClass:[UINavigationController class]] &&
        ![parent isKindOfClass:[UITabBarController class]] &&
        ![parent isKindOfClass:objc_getClass("TFNTabbedViewController")]) {
        return;
    }

    WDDActiveViewController = self;
    WDDUpdateActiveDetailFlag(self);
}

- (void)viewDidDisappear:(BOOL)animated {
    %orig;
    WDDInvalidateMediaViewerCache();

    if (WDDIsMediaViewerController(self) && WDDActiveViewController == self) {
        WDDActiveViewController = nil;
    }
}
%end

%hook T1ConversationFocalStatusViewLayoutStateGenerator
- (id)layoutStateForViewModel:(id)viewModel options:(unsigned long long)options account:(id)account layoutMetrics:(id)layoutMetrics withPreviousLayoutState:(id)previousLayoutState {
    BOOL previous = g_wddThreadFocalLayout;
    g_wddThreadFocalLayout = YES;
    id result = %orig(viewModel, options, account, layoutMetrics, previousLayoutState);
    g_wddThreadFocalLayout = previous;
    return result;
}

- (id)layoutStateForViewModel:(id)viewModel layoutMetrics:(id)layoutMetrics {
    BOOL previous = g_wddThreadFocalLayout;
    g_wddThreadFocalLayout = YES;
    id result = %orig(viewModel, layoutMetrics);
    g_wddThreadFocalLayout = previous;
    return result;
}
%end

%hook TUCMediaComponentViewLayoutState
- (CGSize)size {
    if (g_wddThreadCollapseUnifiedCard) {
        return CGSizeZero;
    }
    return %orig;
}
- (CGRect)mediaFrame {
    if (g_wddThreadCollapseUnifiedCard) {
        return CGRectZero;
    }
    return %orig;
}
- (CGRect)buttonFrame {
    if (g_wddThreadCollapseUnifiedCard) {
        return CGRectZero;
    }
    return %orig;
}
%end

%group SwipeableMediaHook
%hook _TtCC21TwitterUnifiedCardsUI27SwipeableMediaComponentView11LayoutState
- (CGSize)size {
    if (g_wddThreadCollapseUnifiedCard) {
        return CGSizeZero;
    }
    return %orig;
}
%end
%end

%group MediaGalleryHook
%hook _TtCC21TwitterUnifiedCardsUI25MediaGalleryComponentView11LayoutState
- (CGSize)size {
    if (g_wddThreadCollapseUnifiedCard) {
        return CGSizeZero;
    }
    return %orig;
}
%end
%end

%group CompactVideoHook
%hook _TtC21TwitterUnifiedCardsUI40CompactCardVideoComponentViewLayoutState
- (CGSize)size {
    if (g_wddThreadCollapseUnifiedCard) {
        return CGSizeZero;
    }
    return %orig;
}
%end
%end

%group DeamplificationCellHook
%hook _TtC14T1TwitterSwift45ConversationDeamplificationShowMoreThreadCell
- (void)layoutSubviews {
    %orig;
    BOOL hide = WDDShouldHideProbableSpam() && WDDViewTreeShowsProbableSpam((UIView *)self, 0);
    WDDSyncSpamCellContent((UIView *)self, hide);
}
%end
%end

%ctor {
    %init;

    Class c0 = objc_getClass("T1TwitterSwift.ConversationDeamplificationShowMoreThreadCell");
    if (!c0) c0 = objc_getClass("_TtC14T1TwitterSwift45ConversationDeamplificationShowMoreThreadCell");
    if (c0) {
        %init(DeamplificationCellHook, _TtC14T1TwitterSwift45ConversationDeamplificationShowMoreThreadCell = c0);
    }

    Class c1 = objc_getClass("TwitterUnifiedCardsUI.SwipeableMediaComponentView.LayoutState");
    if (!c1) c1 = objc_getClass("_TtCC21TwitterUnifiedCardsUI27SwipeableMediaComponentView11LayoutState");
    if (c1) {
        %init(SwipeableMediaHook, _TtCC21TwitterUnifiedCardsUI27SwipeableMediaComponentView11LayoutState = c1);
    }

    Class c2 = objc_getClass("TwitterUnifiedCardsUI.MediaGalleryComponentView.LayoutState");
    if (!c2) c2 = objc_getClass("_TtCC21TwitterUnifiedCardsUI25MediaGalleryComponentView11LayoutState");
    if (c2) {
        %init(MediaGalleryHook, _TtCC21TwitterUnifiedCardsUI25MediaGalleryComponentView11LayoutState = c2);
    }

    Class c3 = objc_getClass("TwitterUnifiedCardsUI.CompactCardVideoComponentViewLayoutState");
    if (!c3) c3 = objc_getClass("_TtC21TwitterUnifiedCardsUI40CompactCardVideoComponentViewLayoutState");
    if (c3) {
        %init(CompactVideoHook, _TtC21TwitterUnifiedCardsUI40CompactCardVideoComponentViewLayoutState = c3);
    }
}
