#import "WDDManager.h"
#import "WDDUtils.h"
#import "TWHeaders.h"
#import <objc/runtime.h>
#import <objc/message.h>

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
%end

%hook T1TwitterCoreStatusViewModelAdapter
- (BOOL)isFromUserVerified {
    return [WDDManager hideBlueVerified] ? NO : %orig;
}
- (BOOL)isFromUserBlueVerified {
    return [WDDManager hideBlueVerified] ? NO : %orig;
}
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
static BOOL g_isCalculatingQuotedLayout = NO;
static BOOL g_hasAdjustedQuotedWidth = NO;

%hook T1StandardStatusAttachmentViewAdapter

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

%hook TFNTwitterStatus
- (BOOL)hasMedia {
    return ([WDDManager enableSingleImageSizing] && g_isCalculatingQuotedLayout) ? NO : %orig;
}
- (NSArray *)inlineMediaInfos {
    return ([WDDManager enableSingleImageSizing] && g_isCalculatingQuotedLayout) ? @[] : %orig;
}
- (NSArray *)representedMediaEntities {
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

%hook T1CompositionStatusViewModel
- (BOOL)hasMedia {
    return ([WDDManager enableSingleImageSizing] && g_isCalculatingQuotedLayout) ? NO : %orig;
}
- (NSArray *)inlineMediaInfos {
    return ([WDDManager enableSingleImageSizing] && g_isCalculatingQuotedLayout) ? @[] : %orig;
}
- (NSArray *)representedMediaEntities {
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
    return ([WDDManager enableSingleImageSizing] && g_isCalculatingQuotedLayout) ? NO : %orig;
}
- (NSArray *)inlineMediaInfos {
    return ([WDDManager enableSingleImageSizing] && g_isCalculatingQuotedLayout) ? @[] : %orig;
}
- (NSArray *)representedMediaEntities {
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
- (BOOL)hasMedia {
    return ([WDDManager enableSingleImageSizing] && g_isCalculatingQuotedLayout) ? NO : %orig;
}
- (NSArray *)inlineMediaInfos {
    return ([WDDManager enableSingleImageSizing] && g_isCalculatingQuotedLayout) ? @[] : %orig;
}
- (NSArray *)representedMediaEntities {
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

%hook T1StatusPhotoVideoForwardView

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
