#import "WDDManager.h"
#import "WDDUtils.h"
#import "TWHeaders.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import <string.h>

static BOOL g_isCalculatingQuotedLayout = NO;
static BOOL g_hasAdjustedQuotedWidth = NO;

// 前置声明（定义在文件靠后的位置）
static BOOL WDDShouldFixSingleImageSize(id viewModel);

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

// 类名子串判断：class_getName 返回类对象里现成的 C 字符串，零分配。
// 这两个函数在 layoutSubviews 里按子视图逐个调用，原来的写法每层都建 NSString、
// 还套了 @synchronized 互斥锁 —— 结果又慢又可能成为多线程布局的争用点。
// 换成直接扫 C 字符串后，锁和缓存都可以彻底去掉。
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

// 让图片视图填满给定区域。
//
// 旧实现对每一个子视图都无条件执行 subview.frame = view.bounds，再递归下去。
// 两个问题：
//   1) 只有 UIImageView 需要这个处理，其它子视图被无故改 frame；
//   2) 它在 layoutSubviews 里被调用，设 frame 又会触发被 hook 的 setFrame:，
//      等于把「沿 superview 链找焦点上下文」的开销按子视图数量放大一遍。
// 现在只处理 UIImageView，并且尺寸没变就不赋值（避免多余布局 pass）。
static void makeImageViewsAspectFill(UIView *view, CGRect rect) {
    if (!view) return;
    if ([view isKindOfClass:[UIImageView class]]) {
        if (!CGRectEqualToRect(view.frame, rect)) {
            view.frame = rect;
        }
        view.clipsToBounds = YES;
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

    // 卡片类附件不是"图片/视频"，保持原样。
    // 引用推文（quotedStandardStatusViewLayoutState）也必须排除：
    // 它的高度是由内部的图片布局状态算出来的，只要内层图片塌成 0，
    // 外层卡片自己就会缩短。如果连外层一起归零，卡片会整块消失 / 留下空洞。
    id cardState = nil, unifiedCardState = nil, quotedState = nil;
    @try { cardState = [state valueForKey:@"cardViewLayoutState"]; } @catch (__unused NSException *e) {}
    @try { unifiedCardState = [state valueForKey:@"unifiedCardViewLayoutState"]; } @catch (__unused NSException *e) {}
    @try { quotedState = [state valueForKey:@"quotedStandardStatusViewLayoutState"]; } @catch (__unused NSException *e) {}
    if (cardState || unifiedCardState || quotedState) {
        return state;
    }

    // 屏蔽时用宽松判定（任一信号认为在焦点页就放行），避免误伤详情页；
    // 固定尺寸时用精确判定，否则详情页 / 会话页里的整片时间线都会失效。
    if ([WDDManager hideTimelineImages] &&
        !(WDDIsFocalContext(nil) || WDDIsInFocalLayout())) {
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

    // 「固定图片大小」：直接改写附件布局状态的高度为 16:9。
    //
    // 这里是**兜底层**，必须覆盖所有媒体路径 —— 实测有些图片/视频并不经过
    // _t1_photoVideoForwardViewSizeForViewModel:（比如视频播放器容器、轮播），
    // 只在尺寸方法里改就会漏掉一部分，表现就是「有的能固定、有的不行」。
    // 所以在拿到最终布局状态后再统一压一次高度。
    //
    // 只压矮、不拉高（target < size.height 才改）：
    //   · 竖图 / 方图 / 高视频 —— 压成 16:9，符合预期
    //   · 已经很宽的横图 —— 保持不变，不会被拉伸变形
    //   · 敏感内容横幅等矮元素 —— 高度远小于 16:9，天然不会被误伤
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

// 取视图模型里的媒体数组；拿不到时返回 nil（表示"未知"）
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

// 判断单个媒体是不是视频（"固定单图大小"只针对图片）
// 注意：只认"类名含 Video"和明确的布尔开关，不能因为 videoInfo 非 nil 就判定视频 ——
// 不少图片的媒体对象也带一个占位的 videoInfo，那样会把所有单图都误判掉。
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

// 「固定单图大小」的总开关判定。
// 关键改动：这里不再用 WDDIsFocalContext(nil)。
// 那个函数只要当前页面是推文详情 / 会话页就返回 YES，而会话页里的回复单元格
// 走的正是标准时间线布局 —— 于是整个详情页的图片尺寸全部失效，
// 这就是「功能开关打开了却毫无反应」的真正原因。
// 现在改用 WDDIsInFocalLayout()，只认真正的焦点推文布局。
static BOOL WDDShouldFixSingleImageSize(id viewModel) {
    if (![WDDManager enableSingleImageSizing]) return NO;
    if (g_isCalculatingQuotedLayout) return NO;
    if (WDDIsInFocalLayout()) return NO;        // 焦点推文保持原始比例

    NSArray *media = WDDMediaArrayForViewModel(viewModel);
    if (media) {
        if (media.count != 1) return NO;                       // 多图不处理
        if (WDDMediaInfoIsVideo(media.firstObject)) return NO; // 视频不处理
        return YES;
    }
    // 拿不到媒体数组（不同视图模型的实现差异）时按单图处理，
    // 否则这个功能会静默失效。
    return YES;
}

// 12.35 的竖版照片尺寸方法（旧版叫 _t1_verticalMediaSizeForAspectRatio:width:anatomyFeatures:，已不存在）
// 竖图是「高度很夸张」的主要来源，这里直接按可用宽度算成 16:9。
// 注意这里返回的宽度用传入的 width（可用宽度），原实现会缩成 314，
// 那正是「有的图片宽度不统一」的原因。
- (CGSize)_t1_verticalPhotoSizeForAspectRatio:(double)aspectRatio width:(double)width {
    if ([WDDManager hideTimelineImages] &&
        !(WDDIsFocalContext(nil) || WDDIsInFocalLayout())) {
        return CGSizeZero;
    }
    if (![WDDManager enableSingleImageSizing]) {
        return %orig;
    }
    if (width <= 0) {
        return %orig;
    }
    CGSize orig = %orig;
    // 宽度沿用原实现的宽度（它通常比可用宽度略小一点，是内边距造成的），
    // 直接用可用宽度会溢出几 pt。这里只统一高度比例。
    CGFloat w = orig.width > 0 ? orig.width : width;
    CGFloat target = w * 9.0 / 16.0;
    // 只压矮不拉高，避免把本来就矮的图撑高
    if (orig.height > 0 && target >= orig.height) {
        return orig;
    }
    return CGSizeMake(w, target);
}

- (CGSize)_t1_photoVideoForwardViewSizeForViewModel:(id)viewModel layoutMetrics:(id)layoutMetrics width:(double)width attachmentType:(unsigned long long)type {
    if ([WDDManager hideTimelineImages] &&
        !(WDDIsFocalContext(nil) || WDDIsInFocalLayout())) {
        return CGSizeZero;
    }
    if (![WDDManager enableSingleImageSizing]) {
        return %orig;
    }

    CGSize size = %orig;

    // 不再按 attachmentType 过滤，也不再按宽度阈值过滤 ——
    // 实测多图轮播、引用卡片内的缩略图走的是不同分支，逐个加条件必然漏。
    // 统一规则：宽度用原尺寸（保证铺满），高度只压矮不拉高。
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
    if (!([WDDManager hideTimelineImages] &&
          !(WDDIsFocalContext(nil) || WDDIsInFocalLayout()))) return type;

    // 卡片类、引用推文卡片都不算"图片/视频"：它们的高度由内部子状态决定，
    // 把外层的 attachmentType 抹掉并不会让它变矮，只会留下空洞。
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
    // 注意：这里以前有一段「enableSingleImageSizing 时把引用推文的图片藏掉」的代码，
    // 那是彻底错的 —— 图片被 hidden、frame 归零，但布局状态里的高度还在，
    // 结果就是引用推文 / 转帖 / 回复里出现一块空白占位。已删除。
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
        // 只在确实还没归零时才赋值，避免在 layoutSubviews 里反复触发额外的布局 pass
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
    
    // 注意：这里不再跳过详情页/焦点页。
    // 布局那边已经把高度统一压成 16:9，如果视图层还按原始比例居中显示，
    // 就会出现「框是 16:9、图却缩在中间带黑边」的观感，等于没固定。
    // 所以统一用 aspectFill 填满这个框（裁掉多余部分）。
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
        if (!CGRectIsEmpty(self.frame)) {
            self.frame = CGRectZero;
        }
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
        if (!CGRectIsEmpty(self.frame)) {
            self.frame = CGRectZero;
        }
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
