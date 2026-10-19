#import "WDDManager.h"
#import "WDDUtils.h"
#import "TWHeaders.h"
#import <objc/runtime.h>
#import <objc/message.h>

static BOOL g_isCalculatingQuotedLayout = NO;
static BOOL g_hasAdjustedQuotedWidth = NO;

// ==============================
// UI Hiding Features
// ==============================

// MARK: Hide Blue verified checkmark
%hook T1CompositionStatusViewModel
- (BOOL)isFromUserVerified {
    return [WDDManager hideBlueVerified] ? NO : %orig;
}
- (BOOL)isFromUserBlueVerified {
    return [WDDManager hideBlueVerified] ? NO : %orig;
}
- (BOOL)hasMedia {
    if ([WDDManager hideTimelineImages] && !WDDIsFocalContext(nil)) {
        return NO;
    }
    return ([WDDManager enableSingleImageSizing] && g_isCalculatingQuotedLayout) ? NO : %orig;
}
- (NSArray *)inlineMediaInfos {
    if ([WDDManager hideTimelineImages] && !WDDIsFocalContext(nil)) {
        return @[];
    }
    return ([WDDManager enableSingleImageSizing] && g_isCalculatingQuotedLayout) ? @[] : %orig;
}
- (NSArray *)representedMediaEntities {
    if ([WDDManager hideTimelineImages] && !WDDIsFocalContext(nil)) {
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
    if ([WDDManager hideTimelineImages] && !WDDIsFocalContext(nil)) {
        return NO;
    }
    return ([WDDManager enableSingleImageSizing] && g_isCalculatingQuotedLayout) ? NO : %orig;
}
- (NSArray *)inlineMediaInfos {
    if ([WDDManager hideTimelineImages] && !WDDIsFocalContext(nil)) {
        return @[];
    }
    return ([WDDManager enableSingleImageSizing] && g_isCalculatingQuotedLayout) ? @[] : %orig;
}
- (NSArray *)representedMediaEntities {
    if ([WDDManager hideTimelineImages] && !WDDIsFocalContext(nil)) {
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
    if ([WDDManager hideTimelineImages] && !WDDIsFocalContext(nil)) {
        return NO;
    }
    return ([WDDManager enableSingleImageSizing] && g_isCalculatingQuotedLayout) ? NO : %orig;
}
- (NSArray *)inlineMediaInfos {
    if ([WDDManager hideTimelineImages] && !WDDIsFocalContext(nil)) {
        return @[];
    }
    return ([WDDManager enableSingleImageSizing] && g_isCalculatingQuotedLayout) ? @[] : %orig;
}
- (NSArray *)representedMediaEntities {
    if ([WDDManager hideTimelineImages] && !WDDIsFocalContext(nil)) {
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
    if ([WDDManager hideTimelineImages] && !WDDIsFocalContext(nil)) {
        return NO;
    }
    return ([WDDManager enableSingleImageSizing] && g_isCalculatingQuotedLayout) ? NO : %orig;
}
- (NSArray *)inlineMediaInfos {
    if ([WDDManager hideTimelineImages] && !WDDIsFocalContext(nil)) {
        return @[];
    }
    return ([WDDManager enableSingleImageSizing] && g_isCalculatingQuotedLayout) ? @[] : %orig;
}
- (NSArray *)representedMediaEntities {
    if ([WDDManager hideTimelineImages] && !WDDIsFocalContext(nil)) {
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
    if ([WDDManager hideTimelineImages] && !WDDIsFocalContext(nil)) {
        return NO;
    }
    return ([WDDManager enableSingleImageSizing] && g_isCalculatingQuotedLayout) ? NO : %orig;
}
- (NSArray *)inlineMediaInfos {
    if ([WDDManager hideTimelineImages] && !WDDIsFocalContext(nil)) {
        return @[];
    }
    return ([WDDManager enableSingleImageSizing] && g_isCalculatingQuotedLayout) ? @[] : %orig;
}
- (NSArray *)representedMediaEntities {
    if ([WDDManager hideTimelineImages] && !WDDIsFocalContext(nil)) {
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
    if ([WDDManager hideTimelineImages] && !WDDIsFocalContext(nil)) {
        return NO;
    }
    return ([WDDManager enableSingleImageSizing] && g_isCalculatingQuotedLayout) ? NO : %orig;
}
- (NSArray *)inlineMediaInfos {
    if ([WDDManager hideTimelineImages] && !WDDIsFocalContext(nil)) {
        return @[];
    }
    return ([WDDManager enableSingleImageSizing] && g_isCalculatingQuotedLayout) ? @[] : %orig;
}
- (NSArray *)representedMediaEntities {
    if ([WDDManager hideTimelineImages] && !WDDIsFocalContext(nil)) {
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
    if ([WDDManager hideTimelineImages] && !WDDIsFocalContext(nil)) {
        return NO;
    }
    return ([WDDManager enableSingleImageSizing] && g_isCalculatingQuotedLayout) ? NO : %orig;
}
- (NSArray *)inlineMediaInfos {
    if ([WDDManager hideTimelineImages] && !WDDIsFocalContext(nil)) {
        return @[];
    }
    return ([WDDManager enableSingleImageSizing] && g_isCalculatingQuotedLayout) ? @[] : %orig;
}
- (NSArray *)representedMediaEntities {
    if ([WDDManager hideTimelineImages] && !WDDIsFocalContext(nil)) {
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

// ==============================
// Avatar Hiding and Layout Adjustment
// ==============================

typedef NS_ENUM(NSInteger, WDDContextViewType) {
    WDDContextViewTypeNone,
    WDDContextViewTypeSocial,
    WDDContextViewTypeTweet,
    WDDContextViewTypeConversation
};

static BOOL isAvatarClass(Class cls) {
    if (!cls) return NO;
    static NSMutableDictionary<Class, NSNumber *> *cache = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cache = [[NSMutableDictionary alloc] init];
    });
    @synchronized(cache) {
        NSNumber *cached = cache[(id)cls];
        if (cached) {
            return [cached boolValue];
        }
        NSString *className = NSStringFromClass(cls);
        BOOL result = [className rangeOfString:@"Avatar" options:NSCaseInsensitiveSearch].location != NSNotFound;
        cache[(id)cls] = @(result);
        return result;
    }
}

static WDDContextViewType contextViewTypeForClass(Class cls) {
    if (!cls) return WDDContextViewTypeNone;
    
    static NSMutableDictionary<Class, NSNumber *> *cache = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cache = [[NSMutableDictionary alloc] init];
    });
    
    @synchronized(cache) {
        NSNumber *cachedType = cache[(id)cls];
        if (cachedType) {
            return [cachedType integerValue];
        }
        
        NSString *className = NSStringFromClass(cls);
        WDDContextViewType type = WDDContextViewTypeNone;
        if ([className rangeOfString:@"SocialContext" options:NSCaseInsensitiveSearch].location != NSNotFound) {
            type = WDDContextViewTypeSocial;
        } else if ([className rangeOfString:@"TweetContext" options:NSCaseInsensitiveSearch].location != NSNotFound) {
            type = WDDContextViewTypeTweet;
        } else if ([className rangeOfString:@"ConversationContext" options:NSCaseInsensitiveSearch].location != NSNotFound) {
            type = WDDContextViewTypeConversation;
        }
        
        cache[(id)cls] = @(type);
        return type;
    }
}

// Helper: detect if a subview is a conversation connector line.
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
    
    // Accept if it is in the target position (6.0 - 8.0) OR the original position (10.0 - 55.0)
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

// ==============================
// Timeline Media Sizing and Layout Adjustments
// ==============================

static void makeImageViewsAspectFill(UIView *view, CGRect rect) {
    if (!view) return;
    if ([view isKindOfClass:[UIImageView class]]) {
        view.frame = rect;
        view.clipsToBounds = YES;
        view.contentMode = UIViewContentModeScaleAspectFill;
    }
    for (UIView *subview in view.subviews) {
        subview.frame = view.bounds;
        makeImageViewsAspectFill(subview, view.bounds);
    }
}

%hook T1StandardStatusAttachmentViewAdapter

- (unsigned long long)attachmentType {
    unsigned long long origType = %orig;
    if (origType == 2) {
        if ([WDDManager hideTimelineImages] && !WDDIsFocalContext(nil)) {
            return 0;
        }
    }
    return origType;
}

- (id)photoVideoForwardView {
    if ([WDDManager hideTimelineImages] && !WDDIsFocalContext(nil)) {
        return nil;
    }
    return %orig;
}

// 视频自动播放容器（图片没有，视频才有）。
// 屏蔽媒体时一并掐掉，避免它继续参与布局留下空白。
- (id)autoplayPlayerContainer {
    if ([WDDManager hideTimelineImages] && !WDDIsFocalContext(nil)) {
        return nil;
    }
    return %orig;
}

// 关键修复：屏蔽图片/视频后视频仍留占位空白。
//
// 原因：附件布局状态（T1StandardStatusAttachmentViewLayoutState）的高度由
// attachmentType 决定。旧逻辑只在 attachmentType == 2（图片）时归零，
// 视频的枚举值不是 2，于是布局仍按媒体尺寸预留了高度 —— 视图被藏起来了，
// 空间却还在，表现就是「视频没了但有一块空白」。
//
// 这里改为不依赖具体枚举值：只要这个附件不是卡片（card / unifiedCard），
// 就把布局状态压成 0 尺寸 + 0 附件类型。这样图片 / 视频 / GIF 一并生效，
// 而投票、卡片等非媒体附件不受影响。
- (id)layoutStateForViewModel:(id)viewModel layoutMetrics:(id)layoutMetrics {
    id state = %orig;
    if (!state) return state;

    if (!([WDDManager hideTimelineImages] && !WDDIsFocalContext(nil))) {
        return state;
    }

    // 卡片类附件不是"图片/视频"，保持原样
    id cardState = nil, unifiedCardState = nil;
    @try { cardState = [state valueForKey:@"cardViewLayoutState"]; } @catch (__unused NSException *e) {}
    @try { unifiedCardState = [state valueForKey:@"unifiedCardViewLayoutState"]; } @catch (__unused NSException *e) {}
    if (cardState || unifiedCardState) {
        return state;
    }

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

- (CGSize)_t1_verticalMediaSizeForAspectRatio:(double)aspectRatio width:(double)width anatomyFeatures:(id)anatomyFeatures {
    if ([WDDManager hideTimelineImages] && !WDDIsFocalContext(nil)) {
        return CGSizeZero;
    }
    if (![WDDManager enableSingleImageSizing]) {
        return %orig;
    }
    if (g_isCalculatingQuotedLayout) {
        return CGSizeZero;
    }
    if (!g_isCalculatingQuotedLayout && [self respondsToSelector:@selector(displayType)] && [self displayType] == 1) {
        return %orig;
    }
    return %orig(16.0 / 9.0, width, anatomyFeatures);
}

- (CGSize)_t1_photoVideoForwardViewSizeForViewModel:(id)viewModel layoutMetrics:(id)layoutMetrics width:(double)width attachmentType:(unsigned long long)type {
    if ([WDDManager hideTimelineImages] && !WDDIsFocalContext(nil)) {
        return CGSizeZero;
    }
    if (![WDDManager enableSingleImageSizing]) {
        return %orig;
    }
    if (g_isCalculatingQuotedLayout) {
        return CGSizeZero;
    }
    CGSize size = %orig;
    if (!g_isCalculatingQuotedLayout && [self respondsToSelector:@selector(displayType)] && [self displayType] == 1) {
        return size;
    }
    
    if (type == 2) {
        NSArray *media = nil;
        if ([viewModel respondsToSelector:@selector(inlineMediaInfos)]) {
            media = [viewModel inlineMediaInfos];
        } else if ([viewModel respondsToSelector:@selector(representedMediaEntities)]) {
            media = [viewModel representedMediaEntities];
        }
        
        if (media == nil || media.count == 1) {
            double targetHeight = width * (9.0 / 16.0);
            if (targetHeight <= 0) {
                targetHeight = 100.0;
            }
            size.height = targetHeight;
        }
    }
    return size;
}

- (id)_t1_unifiedCardViewLayoutStateForViewModel:(id)viewModel unifiedCard:(id)unifiedCard shouldHideFooter:(BOOL)shouldHideFooter layoutMetrics:(id)layoutMetrics width:(double)width {
    if ([WDDManager hideTimelineImages] && !WDDIsFocalContext(nil)) {
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

// 与上面的 layoutStateForViewModel: 配套：让附件布局状态对外报告「无附件」。
// 同样排除卡片类（card / unifiedCard），避免把投票、外链卡片一起藏掉。
@interface T1StandardStatusAttachmentViewLayoutState : NSObject
@end

%hook T1StandardStatusAttachmentViewLayoutState

- (unsigned long long)attachmentType {
    unsigned long long type = %orig;
    if (type == 0) return 0;
    if (!([WDDManager hideTimelineImages] && !WDDIsFocalContext(nil))) return type;

    id cardState = nil, unifiedCardState = nil;
    @try { cardState = [self valueForKey:@"cardViewLayoutState"]; } @catch (__unused NSException *e) {}
    @try { unifiedCardState = [self valueForKey:@"unifiedCardViewLayoutState"]; } @catch (__unused NSException *e) {}
    if (cardState || unifiedCardState) return type;

    return 0;
}

%end

%hook T1QuotedStandardStatusView
- (void)layoutSubviews {
    %orig;
    if ([WDDManager enableSingleImageSizing]) {
        UIView *mediaView = nil;
        if ([self respondsToSelector:@selector(photoVideoForwardView)]) {
            mediaView = [self photoVideoForwardView];
        }
        if (!mediaView && [self respondsToSelector:@selector(visibleMediaForwardView)]) {
            mediaView = [self visibleMediaForwardView];
        }
        if (mediaView) {
            mediaView.hidden = YES;
            mediaView.frame = CGRectZero;
        }
    }
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
                
                // Pass 2: Find the leftmost header element's X coordinate to the right of the avatar
                for (UIView *subview in ((UIView *)self).subviews) {
                    if (subview == avatarView) continue;
                    CGRect f = subview.frame;
                    if (f.origin.x > avatarFrame.origin.x && f.origin.y < maxHeaderY && f.size.width > 0 && f.size.height > 0) {
                        // Exclude background views
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
                
                // Hide avatar view
                avatarView.hidden = YES;
                avatarView.alpha = 0.0;
                avatarView.frame = CGRectZero;
                
                // Shift all header elements left
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
    if ([WDDManager hideTimelineImages] && !WDDIsFocalContext(self)) {
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
    if ([self respondsToSelector:@selector(displayType)] && [self displayType] == 1) {
        return %orig;
    }
    if ([self respondsToSelector:@selector(numberOfMediaItems)]) {
        if ([self numberOfMediaItems] == 1) {
            return 2; // UIViewContentModeScaleAspectFill
        }
    }
    return %orig;
}

- (void)layoutSubviews {
    if ([WDDManager hideTimelineImages] && !WDDIsFocalContext(self)) {
        self.hidden = YES;
        self.frame = CGRectZero;
        for (UIView *subview in self.subviews) {
            subview.hidden = YES;
        }
        return;
    }
    %orig;
    
    if (![WDDManager enableSingleImageSizing]) {
        return;
    }
    
    if ([self respondsToSelector:@selector(displayType)] && [self displayType] == 1) {
        return;
    }
    
    if ([self respondsToSelector:@selector(numberOfMediaItems)]) {
        if ([self numberOfMediaItems] == 1) {
            self.clipsToBounds = YES;
            CGRect fillBounds = self.bounds;
            
            if ([self respondsToSelector:@selector(mediaContainerView)]) {
                UIView *container = [self mediaContainerView];
                if (container) {
                    container.frame = fillBounds;
                    container.clipsToBounds = YES;
                    container.contentMode = UIViewContentModeScaleAspectFill;
                    makeImageViewsAspectFill(container, fillBounds);
                }
            }
            if ([self respondsToSelector:@selector(inlineMediaView)]) {
                UIView *mediaView = [self inlineMediaView];
                if (mediaView) {
                    mediaView.frame = fillBounds;
                    mediaView.clipsToBounds = YES;
                    mediaView.contentMode = UIViewContentModeScaleAspectFill;
                    makeImageViewsAspectFill(mediaView, fillBounds);
                }
            }
        }
    }
}
%end

%hook T1UnifiedCardImageView
- (void)setImage:(UIImage *)image {
    if ([WDDManager hideTimelineImages] && !WDDIsFocalContext(self)) {
        %orig(nil);
        self.hidden = YES;
        return;
    }
    %orig(image);
}

- (void)setFrame:(CGRect)frame {
    if ([WDDManager hideTimelineImages] && !WDDIsFocalContext(self)) {
        %orig(CGRectZero);
        self.hidden = YES;
        return;
    }
    %orig(frame);
}

- (void)layoutSubviews {
    if ([WDDManager hideTimelineImages] && !WDDIsFocalContext(self)) {
        self.hidden = YES;
        self.frame = CGRectZero;
        return;
    }
    %orig;
}

- (CGSize)sizeThatFits:(CGSize)size {
    if ([WDDManager hideTimelineImages] && !WDDIsFocalContext(self)) {
        return CGSizeZero;
    }
    return %orig(size);
}

- (CGSize)intrinsicContentSize {
    if ([WDDManager hideTimelineImages] && !WDDIsFocalContext(self)) {
        return CGSizeZero;
    }
    return %orig;
}
%end

%hook T1CardImageView
- (void)setImage:(UIImage *)image {
    if ([WDDManager hideTimelineImages] && !WDDIsFocalContext(self)) {
        %orig(nil);
        self.hidden = YES;
        return;
    }
    %orig(image);
}

- (void)setFrame:(CGRect)frame {
    if ([WDDManager hideTimelineImages] && !WDDIsFocalContext(self)) {
        %orig(CGRectZero);
        self.hidden = YES;
        return;
    }
    %orig(frame);
}

- (void)layoutSubviews {
    if ([WDDManager hideTimelineImages] && !WDDIsFocalContext(self)) {
        self.hidden = YES;
        self.frame = CGRectZero;
        return;
    }
    %orig;
}

- (CGSize)sizeThatFits:(CGSize)size {
    if ([WDDManager hideTimelineImages] && !WDDIsFocalContext(self)) {
        return CGSizeZero;
    }
    return %orig(size);
}

- (CGSize)intrinsicContentSize {
    if ([WDDManager hideTimelineImages] && !WDDIsFocalContext(self)) {
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
    
    // 过滤普通的 containment 子控制器（如视频、广告或卡片内部控制器），防止它们污染当前活动页面的判定
    UIViewController *parent = self.parentViewController;
    if (parent && 
        ![parent isKindOfClass:[UINavigationController class]] && 
        ![parent isKindOfClass:[UITabBarController class]] &&
        ![parent isKindOfClass:objc_getClass("TFNTabbedViewController")]) {
        return;
    }
    
    WDDActiveViewController = self;
    WDDActiveViewControllerIsDetail = WDDIsCurrentActiveContextDetail();
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
    WDDActiveViewControllerIsDetail = WDDIsCurrentActiveContextDetail();
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
