#import "WDDManager.h"
#import "WDDUtils.h"
#import "TWHeaders.h"
#import "WDDLayoutShared.h"

typedef NS_ENUM(NSInteger, WDDContextViewType) {
    WDDContextViewTypeNone,
    WDDContextViewTypeSocial,
    WDDContextViewTypeTweet,
    WDDContextViewTypeConversation
};
static WDDContextViewType contextViewTypeForClass(Class cls) {
    if (!cls) return WDDContextViewTypeNone;
    if (WDDClassContains(cls, "SocialContext"))       return WDDContextViewTypeSocial;
    if (WDDClassContains(cls, "TweetContext"))        return WDDContextViewTypeTweet;
    if (WDDClassContains(cls, "ConversationContext")) return WDDContextViewTypeConversation;
    return WDDContextViewTypeNone;
}

static BOOL isConnectorLineView(UIView *subview) {
    if (!subview) return NO;

    static Class conversationConnectorViewClass = nil;
    static Class t1StandardStatusConversationConnectorsViewClass = nil;
    static Class t1ConversationTreeConnectorsViewClass = nil;
    static Class t1CurvedLineClass = nil;
    static Class tfnRoundedCornerViewClass = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        conversationConnectorViewClass = objc_getClass("ConversationConnectorView");
        t1StandardStatusConversationConnectorsViewClass = objc_getClass("T1StandardStatusConversationConnectorsView");
        t1ConversationTreeConnectorsViewClass = objc_getClass("T1ConversationTreeConnectorsView");
        t1CurvedLineClass = objc_getClass("T1CurvedLine");
        tfnRoundedCornerViewClass = objc_getClass("TFNRoundedCornerView");
    });

    Class cls = [subview class];
    if ([subview isKindOfClass:conversationConnectorViewClass] ||
        [subview isKindOfClass:t1StandardStatusConversationConnectorsViewClass] ||
        [subview isKindOfClass:t1ConversationTreeConnectorsViewClass] ||
        [subview isKindOfClass:t1CurvedLineClass]) {
        return YES;
    }

    if ([subview isKindOfClass:tfnRoundedCornerViewClass]) {
        CGRect f = subview.frame;
        if (f.size.width > 0 && f.size.width <= 6.0) {
            return YES;
        }
    }

    CGRect f = subview.frame;
    if (f.size.width <= 0 || f.size.height <= 0) return NO;
    if (f.size.width > 6.0) return NO;
    if (f.size.height < 10.0) return NO;

    if (f.origin.x >= 6.0 && f.origin.x <= 8.0) return YES;
    if (f.origin.x >= 10.0 && f.origin.x <= 55.0) return YES;

    return NO;
}

static inline void WDDApplyFrame(UIView *view, CGRect frame) {
    if (!view) return;
    if (CGRectEqualToRect(view.frame, frame)) return;
    view.frame = frame;
}

static void adjustStatusViewLayout(UIView *statusView) {
    if (!statusView) return;

    BOOL hideReply = [WDDManager hideReplyToIndicator];
    BOOL hideAvatar = [WDDManager hideAvatar];
    if (!hideReply && !hideAvatar) return;

    NSArray *subviews = statusView.subviews;

    if (hideReply) {
        id viewModel = nil;
        if ([statusView respondsToSelector:@selector(viewModel)]) {
            viewModel = [statusView performSelector:@selector(viewModel)];
        }
        for (UIView *subview in subviews) {
            WDDContextViewType type = contextViewTypeForClass([subview class]);
            if (type == WDDContextViewTypeSocial) {
                if (WDDIsViewModelReply(viewModel)) {
                    subview.hidden = YES;
                    subview.alpha = 0.0;
                    CGRect f = subview.frame;
                    f.size.height = 0.0;
                    WDDApplyFrame(subview, f);
                }
            } else if (type == WDDContextViewTypeTweet || type == WDDContextViewTypeConversation) {
                subview.hidden = YES;
                subview.alpha = 0.0;
                CGRect f = subview.frame;
                f.size.height = 0.0;
                WDDApplyFrame(subview, f);
            }
        }
    }

    if (hideAvatar) {
        CGFloat margin = 12.0;
        CGFloat targetWidth = statusView.bounds.size.width - (margin * 2);
        UIView *frontMost = subviews.lastObject;

        for (UIView *subview in subviews) {
            CGRect f = subview.frame;

            if (f.origin.x < 10.0 && f.size.width < 65.0 && f.size.width > 0) {
                subview.hidden = YES;
                subview.userInteractionEnabled = NO;
                WDDApplyFrame(subview, CGRectZero);
                continue;
            }

            if (isConnectorLineView(subview)) {
                subview.hidden = YES;
                WDDApplyFrame(subview, CGRectZero);
                continue;
            }

            for (UIView *innerView in subview.subviews) {
                if (isConnectorLineView(innerView)) {
                    innerView.hidden = YES;
                    WDDApplyFrame(innerView, CGRectZero);
                }
            }

            if (!subview.hidden && subview.alpha > 0.1 && f.origin.x >= 30.0) {
                f.origin.x = margin;
                f.size.width = targetWidth;
                WDDApplyFrame(subview, f);
                if (frontMost != subview) {
                    [statusView bringSubviewToFront:subview];
                    frontMost = subview;
                }
            }
        }
    }
}

%hook T1StandardStatusView
- (void)setFrame:(CGRect)frame {
    if ([WDDManager hideAvatar]) {
        frame.size.width = [UIScreen mainScreen].bounds.size.width;
    }
    %orig(frame);
}

- (void)layoutSubviews {
    %orig;
    adjustStatusViewLayout((UIView *)self);
}
%end

%hook ConversationConnectorView
- (void)setFrame:(CGRect)frame {
    if ([WDDManager hideAvatar]) {
        frame = CGRectZero;
        ((UIView *)self).hidden = YES;
    }
    %orig(frame);
}
%end

%hook T1StandardStatusConversationConnectorsView
- (void)setFrame:(CGRect)frame {
    if ([WDDManager hideAvatar]) {
        frame = CGRectZero;
        ((UIView *)self).hidden = YES;
    }
    %orig(frame);
}

- (void)layoutSubviews {
    %orig;
    if ([WDDManager hideAvatar]) {
        for (UIView *subview in ((UIView *)self).subviews) {
            subview.hidden = YES;
            subview.frame = CGRectZero;
        }
    }
}
%end

%hook T1ConversationTreeConnectorsView
- (void)setFrame:(CGRect)frame {
    if ([WDDManager hideAvatar]) {
        frame = CGRectZero;
        ((UIView *)self).hidden = YES;
    }
    %orig(frame);
}

- (void)layoutSubviews {
    %orig;
    if ([WDDManager hideAvatar]) {
        for (UIView *subview in ((UIView *)self).subviews) {
            subview.hidden = YES;
            subview.frame = CGRectZero;
        }
    }
}
%end

%ctor {
    %init;
}
