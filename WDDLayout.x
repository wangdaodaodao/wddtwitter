#import "WDDManager.h"
#import "WDDUtils.h"
#import "TWHeaders.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import <string.h>

static _Thread_local BOOL g_isCalculatingQuotedLayout = NO;
static _Thread_local BOOL g_hasAdjustedQuotedWidth = NO;

static BOOL WDDShouldFixSingleImageSize(id viewModel);

%hook T1CompositionStatusViewModel
- (BOOL)isFromUserVerified {
    return [WDDManager hideBlueVerified] ? NO : %orig;
}
- (BOOL)isFromUserBlueVerified {
    return [WDDManager hideBlueVerified] ? NO : %orig;
}
- (BOOL)hasMedia {
    if (WDDShouldHideTimelineMedia(nil)) {
        return NO;
    }
    return ([WDDManager enableSingleImageSizing] && g_isCalculatingQuotedLayout) ? NO : %orig;
}
- (NSArray *)inlineMediaInfos {
    if (WDDShouldHideTimelineMedia(nil)) {
        return @[];
    }
    return ([WDDManager enableSingleImageSizing] && g_isCalculatingQuotedLayout) ? @[] : %orig;
}
- (NSArray *)representedMediaEntities {
    if (WDDShouldHideTimelineMedia(nil)) {
        return @[];
    }
    return ([WDDManager enableSingleImageSizing] && g_isCalculatingQuotedLayout) ? @[] : %orig;
}
- (id)fromUserHighlightedDesignatorInfo {
    return [WDDManager hideAccountLabels] ? nil : %orig;
}
- (BOOL)hasPaidPromotionDisclosure {
    return [WDDManager hideDisclosureLabels] ? NO : %orig;
}
- (BOOL)hasAIGeneratedDisclosure {
    return [WDDManager hideDisclosureLabels] ? NO : %orig;
}
%end

%hook TFNTwitterStatus
- (BOOL)isFromUserVerified {
    return [WDDManager hideBlueVerified] ? NO : %orig;
}
- (BOOL)isFromUserBlueVerified {
    return [WDDManager hideBlueVerified] ? NO : %orig;
}
- (NSString *)fromUserFullName {
    return [WDDManager hideAuthorName] ? @"" : %orig;
}
- (BOOL)hasMedia {
    if (WDDShouldHideTimelineMedia(nil)) {
        return NO;
    }
    return ([WDDManager enableSingleImageSizing] && g_isCalculatingQuotedLayout) ? NO : %orig;
}
- (NSArray *)inlineMediaInfos {
    if (WDDShouldHideTimelineMedia(nil)) {
        return @[];
    }
    return ([WDDManager enableSingleImageSizing] && g_isCalculatingQuotedLayout) ? @[] : %orig;
}
- (NSArray *)representedMediaEntities {
    if (WDDShouldHideTimelineMedia(nil)) {
        return @[];
    }
    return ([WDDManager enableSingleImageSizing] && g_isCalculatingQuotedLayout) ? @[] : %orig;
}
- (id)fromUserHighlightedDesignatorInfo {
    return [WDDManager hideAccountLabels] ? nil : %orig;
}
- (BOOL)hasPaidPromotionDisclosure {
    return [WDDManager hideDisclosureLabels] ? NO : %orig;
}
- (BOOL)hasAIGeneratedDisclosure {
    return [WDDManager hideDisclosureLabels] ? NO : %orig;
}
%end

%hook T1TwitterCoreStatusViewModelAdapter
- (BOOL)isFromUserVerified {
    return [WDDManager hideBlueVerified] ? NO : %orig;
}
- (BOOL)isFromUserBlueVerified {
    return [WDDManager hideBlueVerified] ? NO : %orig;
}
- (BOOL)hasMedia {
    if (WDDShouldHideTimelineMedia(nil)) {
        return NO;
    }
    return ([WDDManager enableSingleImageSizing] && g_isCalculatingQuotedLayout) ? NO : %orig;
}
- (NSArray *)inlineMediaInfos {
    if (WDDShouldHideTimelineMedia(nil)) {
        return @[];
    }
    return ([WDDManager enableSingleImageSizing] && g_isCalculatingQuotedLayout) ? @[] : %orig;
}
- (NSArray *)representedMediaEntities {
    if (WDDShouldHideTimelineMedia(nil)) {
        return @[];
    }
    return ([WDDManager enableSingleImageSizing] && g_isCalculatingQuotedLayout) ? @[] : %orig;
}
- (id)fromUserHighlightedDesignatorInfo {
    return [WDDManager hideAccountLabels] ? nil : %orig;
}
- (BOOL)hasPaidPromotionDisclosure {
    return [WDDManager hideDisclosureLabels] ? NO : %orig;
}
- (BOOL)hasAIGeneratedDisclosure {
    return [WDDManager hideDisclosureLabels] ? NO : %orig;
}
%end

%hook T1TranslatedStatusViewModel
- (BOOL)hasMedia {
    if (WDDShouldHideTimelineMedia(nil)) {
        return NO;
    }
    return ([WDDManager enableSingleImageSizing] && g_isCalculatingQuotedLayout) ? NO : %orig;
}
- (NSArray *)inlineMediaInfos {
    if (WDDShouldHideTimelineMedia(nil)) {
        return @[];
    }
    return ([WDDManager enableSingleImageSizing] && g_isCalculatingQuotedLayout) ? @[] : %orig;
}
- (NSArray *)representedMediaEntities {
    if (WDDShouldHideTimelineMedia(nil)) {
        return @[];
    }
    return ([WDDManager enableSingleImageSizing] && g_isCalculatingQuotedLayout) ? @[] : %orig;
}
- (id)fromUserHighlightedDesignatorInfo {
    return [WDDManager hideAccountLabels] ? nil : %orig;
}
- (BOOL)hasPaidPromotionDisclosure {
    return [WDDManager hideDisclosureLabels] ? NO : %orig;
}
- (BOOL)hasAIGeneratedDisclosure {
    return [WDDManager hideDisclosureLabels] ? NO : %orig;
}
%end

%hook TTACoreStatusViewModelURT
- (BOOL)hasMedia {
    if (WDDShouldHideTimelineMedia(nil)) {
        return NO;
    }
    return ([WDDManager enableSingleImageSizing] && g_isCalculatingQuotedLayout) ? NO : %orig;
}
- (NSArray *)inlineMediaInfos {
    if (WDDShouldHideTimelineMedia(nil)) {
        return @[];
    }
    return ([WDDManager enableSingleImageSizing] && g_isCalculatingQuotedLayout) ? @[] : %orig;
}
- (NSArray *)representedMediaEntities {
    if (WDDShouldHideTimelineMedia(nil)) {
        return @[];
    }
    return ([WDDManager enableSingleImageSizing] && g_isCalculatingQuotedLayout) ? @[] : %orig;
}
- (id)fromUserHighlightedDesignatorInfo {
    return [WDDManager hideAccountLabels] ? nil : %orig;
}
- (BOOL)hasPaidPromotionDisclosure {
    return [WDDManager hideDisclosureLabels] ? NO : %orig;
}
- (BOOL)hasAIGeneratedDisclosure {
    return [WDDManager hideDisclosureLabels] ? NO : %orig;
}
%end

%hook TwitterCoreStatusViewModelAdapter
- (BOOL)hasMedia {
    if (WDDShouldHideTimelineMedia(nil)) {
        return NO;
    }
    return ([WDDManager enableSingleImageSizing] && g_isCalculatingQuotedLayout) ? NO : %orig;
}
- (NSArray *)inlineMediaInfos {
    if (WDDShouldHideTimelineMedia(nil)) {
        return @[];
    }
    return ([WDDManager enableSingleImageSizing] && g_isCalculatingQuotedLayout) ? @[] : %orig;
}
- (NSArray *)representedMediaEntities {
    if (WDDShouldHideTimelineMedia(nil)) {
        return @[];
    }
    return ([WDDManager enableSingleImageSizing] && g_isCalculatingQuotedLayout) ? @[] : %orig;
}
- (id)fromUserHighlightedDesignatorInfo {
    return [WDDManager hideAccountLabels] ? nil : %orig;
}
- (BOOL)hasPaidPromotionDisclosure {
    return [WDDManager hideDisclosureLabels] ? NO : %orig;
}
- (BOOL)hasAIGeneratedDisclosure {
    return [WDDManager hideDisclosureLabels] ? NO : %orig;
}
%end
%group SwiftHooks
%hook T1TwitterSwift_TwitterCoreStatusViewModelAdapter
- (BOOL)hasMedia {
    if (WDDShouldHideTimelineMedia(nil)) {
        return NO;
    }
    return ([WDDManager enableSingleImageSizing] && g_isCalculatingQuotedLayout) ? NO : %orig;
}
- (NSArray *)inlineMediaInfos {
    if (WDDShouldHideTimelineMedia(nil)) {
        return @[];
    }
    return ([WDDManager enableSingleImageSizing] && g_isCalculatingQuotedLayout) ? @[] : %orig;
}
- (NSArray *)representedMediaEntities {
    if (WDDShouldHideTimelineMedia(nil)) {
        return @[];
    }
    return ([WDDManager enableSingleImageSizing] && g_isCalculatingQuotedLayout) ? @[] : %orig;
}
- (id)fromUserHighlightedDesignatorInfo {
    return [WDDManager hideAccountLabels] ? nil : %orig;
}
- (BOOL)hasPaidPromotionDisclosure {
    return [WDDManager hideDisclosureLabels] ? NO : %orig;
}
- (BOOL)hasAIGeneratedDisclosure {
    return [WDDManager hideDisclosureLabels] ? NO : %orig;
}
%end
%end

%hook TFNTwitterUser
- (NSString *)fullName {
    return [WDDManager hideAuthorName] ? @"" : %orig;
}
- (BOOL)isVerified {
    return [WDDManager hideBlueVerified] ? NO : %orig;
}
- (BOOL)isBlueVerified {
    return [WDDManager hideBlueVerified] ? NO : %orig;
}
- (BOOL)isVerifiedAccount {
    return [WDDManager hideBlueVerified] ? NO : %orig;
}
- (id)highlightedDesignatorInfo {
    return [WDDManager hideAccountLabels] ? nil : %orig;
}
- (id)parodyCommentaryFanLabel {
    return [WDDManager hideAccountLabels] ? nil : %orig;
}
- (BOOL)hasParodyProfileLabel {
    return [WDDManager hideAccountLabels] ? NO : %orig;
}
%end

%hook T1StandardUserViewModel
- (NSString *)fullName {
    return [WDDManager hideAuthorName] ? @"" : %orig;
}
- (BOOL)verified {
    return [WDDManager hideBlueVerified] ? NO : %orig;
}
- (BOOL)isVerified {
    return [WDDManager hideBlueVerified] ? NO : %orig;
}
- (BOOL)isBlueVerified {
    return [WDDManager hideBlueVerified] ? NO : %orig;
}
- (BOOL)isVerifiedAccount {
    return [WDDManager hideBlueVerified] ? NO : %orig;
}
- (id)highlightedDesignatorInfo {
    return [WDDManager hideAccountLabels] ? nil : %orig;
}
- (id)parodyCommentaryFanLabel {
    return [WDDManager hideAccountLabels] ? nil : %orig;
}
- (BOOL)hasParodyProfileLabel {
    return [WDDManager hideAccountLabels] ? NO : %orig;
}
%end

%hook T1ProfileUserViewModel
- (NSString *)fullName {
    return [WDDManager hideAuthorName] ? @"" : %orig;
}
- (BOOL)isVerifiedAccount {
    return [WDDManager hideBlueVerified] ? NO : %orig;
}
- (id)highlightedDesignatorInfo {
    return [WDDManager hideAccountLabels] ? nil : %orig;
}
- (id)parodyCommentaryFanLabel {
    return [WDDManager hideAccountLabels] ? nil : %orig;
}
- (BOOL)hasParodyProfileLabel {
    return [WDDManager hideAccountLabels] ? NO : %orig;
}
%end

typedef NS_ENUM(NSInteger, WDDContextViewType) {
    WDDContextViewTypeNone,
    WDDContextViewTypeSocial,
    WDDContextViewTypeTweet,
    WDDContextViewTypeConversation
};

static inline BOOL WDDClassContains(Class cls, const char *needle) {
    if (!cls || !needle) return NO;
    const char *name = class_getName(cls);
    return name ? (strcasestr(name, needle) != NULL) : NO;
}

static BOOL isAvatarClass(Class cls) {
    return WDDClassContains(cls, "Avatar");
}

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

static void adjustStatusViewLayout(UIView *statusView) {
    if (!statusView) return;

    if ([WDDManager hideReplyToIndicator]) {
        id viewModel = nil;
        if ([statusView respondsToSelector:@selector(viewModel)]) {
            viewModel = [statusView performSelector:@selector(viewModel)];
        }
        for (UIView *subview in statusView.subviews) {
            WDDContextViewType type = contextViewTypeForClass([subview class]);
            if (type == WDDContextViewTypeSocial) {
                if (WDDIsViewModelReply(viewModel)) {
                    subview.hidden = YES;
                    subview.alpha = 0.0;
                    CGRect f = subview.frame;
                    f.size.height = 0.0;
                    subview.frame = f;
                }
            } else if (type == WDDContextViewTypeTweet || type == WDDContextViewTypeConversation) {
                subview.hidden = YES;
                subview.alpha = 0.0;
                CGRect f = subview.frame;
                f.size.height = 0.0;
                subview.frame = f;
            }
        }
    }

    if ([WDDManager hideAvatar]) {
        CGFloat margin = 12.0;
        for (UIView *subview in statusView.subviews) {
            CGRect f = subview.frame;
            if (isConnectorLineView(subview)) {
                subview.hidden = YES;
                subview.frame = CGRectZero;
                continue;
            }
            for (UIView *innerView in subview.subviews) {
                if (isConnectorLineView(innerView)) {
                    innerView.hidden = YES;
                    innerView.frame = CGRectZero;
                }
            }
            if (f.origin.x < 10.0 && f.size.width < 65.0 && f.size.width > 0) {
                subview.hidden = YES;
                subview.userInteractionEnabled = NO;
                subview.frame = CGRectZero;
            } else if (!subview.hidden && subview.alpha > 0.1) {
                if (f.origin.x >= 30.0) {
                    f.origin.x = margin;
                    f.size.width = statusView.bounds.size.width - (margin * 2);
                    subview.frame = f;
                    [statusView bringSubviewToFront:subview];
                }
            }
        }
    }
}

%hook T1StatusView
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

static void makeImageViewsAspectFill(UIView *view, CGRect rect) {
    (void)rect;
    if (!view) return;
    if ([view isKindOfClass:[UIImageView class]]) {
        if (!view.clipsToBounds) {
            view.clipsToBounds = YES;
        }
        if (view.contentMode != UIViewContentModeScaleAspectFill) {
            view.contentMode = UIViewContentModeScaleAspectFill;
        }
    }
    for (UIView *subview in view.subviews) {
        makeImageViewsAspectFill(subview, view.bounds);
    }
}

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

static NSArray *WDDMediaArrayForViewModel(id viewModel) {
    if (!viewModel) return nil;
    NSArray *media = nil;
    @try {
        if ([viewModel respondsToSelector:@selector(inlineMediaInfos)]) {
            media = [viewModel inlineMediaInfos];
        }
        if (![media isKindOfClass:[NSArray class]] || media.count == 0) {
            if ([viewModel respondsToSelector:@selector(representedMediaEntities)]) {
                media = [viewModel representedMediaEntities];
            }
        }
    } @catch (__unused NSException *e) {}
    return [media isKindOfClass:[NSArray class]] ? media : nil;
}

static BOOL WDDMediaInfoIsVideo(id info) {
    if (!info) return NO;

    NSString *cls = NSStringFromClass([info class]);
    if ([cls rangeOfString:@"Video" options:NSCaseInsensitiveSearch].location != NSNotFound) {
        return YES;
    }
    for (NSString *key in @[@"isVideo", @"isMediaEntityVideo", @"isPlayable"]) {
        if ([info respondsToSelector:NSSelectorFromString(key)]) {
            BOOL b = NO;
            @try { b = [[info valueForKey:key] boolValue]; } @catch (__unused NSException *e) {}
            if (b) return YES;
        }
    }
    return NO;
}

static BOOL WDDShouldFixSingleImageSize(id viewModel) {
    if (![WDDManager enableSingleImageSizing]) return NO;
    if (g_isCalculatingQuotedLayout) return NO;
    if (WDDIsInFocalLayout()) return NO;

    NSArray *media = WDDMediaArrayForViewModel(viewModel);
    if (media) {
        if (media.count != 1) return NO;
        if (WDDMediaInfoIsVideo(media.firstObject)) return NO;
        return YES;
    }

    return YES;
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
        NSMutableDictionary *threadDict = [[NSThread currentThread] threadDictionary];
        id oldVal = threadDict[@"WDDCollapseUnifiedCardLayout"];
        threadDict[@"WDDCollapseUnifiedCardLayout"] = @YES;
        id result = %orig(viewModel, unifiedCard, shouldHideFooter, layoutMetrics, width);
        if (oldVal) {
            threadDict[@"WDDCollapseUnifiedCardLayout"] = oldVal;
        } else {
            [threadDict removeObjectForKey:@"WDDCollapseUnifiedCardLayout"];
        }
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
        %orig(CGRectZero);
        self.hidden = YES;
        return;
    }
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
        self.hidden = YES;

        if (!CGRectIsEmpty(self.frame)) {
            self.frame = CGRectZero;
        }
        for (UIView *subview in self.subviews) {
            subview.hidden = YES;
        }
        return;
    }
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
    if (WDDShouldHideTimelineMedia(self)) {
        %orig(nil);
        self.hidden = YES;
        return;
    }
    %orig(image);
}

- (void)setFrame:(CGRect)frame {
    if (WDDShouldHideTimelineMedia(self)) {
        %orig(CGRectZero);
        self.hidden = YES;
        return;
    }
    %orig(frame);
}

- (void)layoutSubviews {
    if (WDDShouldHideTimelineMedia(self)) {
        self.hidden = YES;
        if (!CGRectIsEmpty(self.frame)) {
            self.frame = CGRectZero;
        }
        return;
    }
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
    if (WDDShouldHideTimelineMedia(self)) {
        %orig(nil);
        self.hidden = YES;
        return;
    }
    %orig(image);
}

- (void)setFrame:(CGRect)frame {
    if (WDDShouldHideTimelineMedia(self)) {
        %orig(CGRectZero);
        self.hidden = YES;
        return;
    }
    %orig(frame);
}

- (void)layoutSubviews {
    if (WDDShouldHideTimelineMedia(self)) {
        self.hidden = YES;
        if (!CGRectIsEmpty(self.frame)) {
            self.frame = CGRectZero;
        }
        return;
    }
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

%hook UIViewController
- (void)viewWillAppear:(BOOL)animated {
    %orig;
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

    if (!WDDIsMediaViewerController(self)) {
        WDDActiveViewControllerIsDetail = WDDIsCurrentActiveContextDetail();
    }
}

- (void)viewDidAppear:(BOOL)animated {
    %orig;
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
    if (!WDDIsMediaViewerController(self)) {
        WDDActiveViewControllerIsDetail = WDDIsCurrentActiveContextDetail();
    }
}
%end

%hook T1ConversationFocalStatusViewLayoutStateGenerator
- (id)layoutStateForViewModel:(id)viewModel options:(unsigned long long)options account:(id)account layoutMetrics:(id)layoutMetrics withPreviousLayoutState:(id)previousLayoutState {
    NSMutableDictionary *threadDict = [[NSThread currentThread] threadDictionary];
    id oldVal = threadDict[@"WDDIsFocalLayout"];
    threadDict[@"WDDIsFocalLayout"] = @YES;
    id result = %orig(viewModel, options, account, layoutMetrics, previousLayoutState);
    if (oldVal) {
        threadDict[@"WDDIsFocalLayout"] = oldVal;
    } else {
        [threadDict removeObjectForKey:@"WDDIsFocalLayout"];
    }
    return result;
}

- (id)layoutStateForViewModel:(id)viewModel layoutMetrics:(id)layoutMetrics {
    NSMutableDictionary *threadDict = [[NSThread currentThread] threadDictionary];
    id oldVal = threadDict[@"WDDIsFocalLayout"];
    threadDict[@"WDDIsFocalLayout"] = @YES;
    id result = %orig(viewModel, layoutMetrics);
    if (oldVal) {
        threadDict[@"WDDIsFocalLayout"] = oldVal;
    } else {
        [threadDict removeObjectForKey:@"WDDIsFocalLayout"];
    }
    return result;
}
%end

%hook TUCMediaComponentViewLayoutState
- (CGSize)size {
    NSMutableDictionary *threadDict = [[NSThread currentThread] threadDictionary];
    if ([threadDict[@"WDDCollapseUnifiedCardLayout"] boolValue]) {
        return CGSizeZero;
    }
    return %orig;
}
- (CGRect)mediaFrame {
    NSMutableDictionary *threadDict = [[NSThread currentThread] threadDictionary];
    if ([threadDict[@"WDDCollapseUnifiedCardLayout"] boolValue]) {
        return CGRectZero;
    }
    return %orig;
}
- (CGRect)buttonFrame {
    NSMutableDictionary *threadDict = [[NSThread currentThread] threadDictionary];
    if ([threadDict[@"WDDCollapseUnifiedCardLayout"] boolValue]) {
        return CGRectZero;
    }
    return %orig;
}
%end

%group SwipeableMediaHook
%hook _TtCC21TwitterUnifiedCardsUI27SwipeableMediaComponentView11LayoutState
- (CGSize)size {
    NSMutableDictionary *threadDict = [[NSThread currentThread] threadDictionary];
    if ([threadDict[@"WDDCollapseUnifiedCardLayout"] boolValue]) {
        return CGSizeZero;
    }
    return %orig;
}
%end
%end

%group MediaGalleryHook
%hook _TtCC21TwitterUnifiedCardsUI25MediaGalleryComponentView11LayoutState
- (CGSize)size {
    NSMutableDictionary *threadDict = [[NSThread currentThread] threadDictionary];
    if ([threadDict[@"WDDCollapseUnifiedCardLayout"] boolValue]) {
        return CGSizeZero;
    }
    return %orig;
}
%end
%end

%group CompactVideoHook
%hook _TtC21TwitterUnifiedCardsUI40CompactCardVideoComponentViewLayoutState
- (CGSize)size {
    NSMutableDictionary *threadDict = [[NSThread currentThread] threadDictionary];
    if ([threadDict[@"WDDCollapseUnifiedCardLayout"] boolValue]) {
        return CGSizeZero;
    }
    return %orig;
}
%end
%end

%ctor {
    %init(SwiftHooks, T1TwitterSwift_TwitterCoreStatusViewModelAdapter = objc_getClass("T1TwitterSwift.TwitterCoreStatusViewModelAdapter"));

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

    %init;
}
