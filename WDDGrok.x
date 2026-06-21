#import "WDDManager.h"
#import "WDDUtils.h"
#import "TWHeaders.h"
#import <objc/runtime.h>
#import <objc/message.h>

// ==============================
// Hide Translation Banner / Grok Translation
// ==============================

%group TimelineTranslation

%hook T1StandardStatusTranslateLayoutState
- (BOOL)isTranslatable {
    if ([WDDManager hideTranslationNotice]) {
        NSNumber *associated = objc_getAssociatedObject(self, @selector(isTranslatable));
        if (associated) {
            return [associated boolValue] ? %orig : NO;
        }
        
        NSMutableDictionary *threadDict = [[NSThread currentThread] threadDictionary];
        BOOL isFocal = NO;
        if (threadDict[@"WDDIsFocalLayout"]) {
            isFocal = [threadDict[@"WDDIsFocalLayout"] boolValue];
        } else {
            isFocal = WDDActiveViewControllerIsDetail;
        }
        
        objc_setAssociatedObject(self, @selector(isTranslatable), @(isFocal), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        return isFocal ? %orig : NO;
    }
    return %orig;
}

- (void)setTranslatable:(BOOL)translatable {
    if ([WDDManager hideTranslationNotice]) {
        NSNumber *associated = objc_getAssociatedObject(self, @selector(isTranslatable));
        BOOL isFocal = NO;
        if (associated) {
            isFocal = [associated boolValue];
        } else {
            NSMutableDictionary *threadDict = [[NSThread currentThread] threadDictionary];
            if (threadDict[@"WDDIsFocalLayout"]) {
                isFocal = [threadDict[@"WDDIsFocalLayout"] boolValue];
            } else {
                isFocal = WDDActiveViewControllerIsDetail;
            }
            objc_setAssociatedObject(self, @selector(isTranslatable), @(isFocal), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
        
        if (isFocal) {
            %orig(translatable);
        } else {
            %orig(NO);
        }
    } else {
        %orig(translatable);
    }
}
%end

%hook T1StandardStatusTranslateAdapter
- (BOOL)shouldBeVisibleForViewModel:(id)viewModel {
    if ([WDDManager hideTranslationNotice]) {
        NSMutableDictionary *threadDict = [[NSThread currentThread] threadDictionary];
        BOOL isFocal = NO;
        if (threadDict[@"WDDIsFocalLayout"]) {
            isFocal = [threadDict[@"WDDIsFocalLayout"] boolValue];
        } else {
            isFocal = WDDActiveViewControllerIsDetail;
        }
        if (isFocal) {
            return %orig;
        }
        return NO;
    }
    return %orig;
}
- (BOOL)shouldBeVisibleForViewModel:(id)viewModel displayType:(long long)displayType {
    if ([WDDManager hideTranslationNotice]) {
        NSMutableDictionary *threadDict = [[NSThread currentThread] threadDictionary];
        BOOL isFocal = NO;
        if (threadDict[@"WDDIsFocalLayout"]) {
            isFocal = [threadDict[@"WDDIsFocalLayout"] boolValue];
        } else {
            isFocal = WDDActiveViewControllerIsDetail;
        }
        if (isFocal) {
            return %orig;
        }
        return NO;
    }
    return %orig;
}
%end

%hook T1StandardStatusGrokTranslateButtonViewAdapter
- (BOOL)shouldBeVisibleForViewModel:(id)viewModel {
    if ([WDDManager hideTranslationNotice]) {
        NSMutableDictionary *threadDict = [[NSThread currentThread] threadDictionary];
        BOOL isFocal = NO;
        if (threadDict[@"WDDIsFocalLayout"]) {
            isFocal = [threadDict[@"WDDIsFocalLayout"] boolValue];
        } else {
            isFocal = WDDActiveViewControllerIsDetail;
        }
        if (isFocal) {
            return %orig;
        }
        return NO;
    }
    return %orig;
}
- (BOOL)shouldBeVisibleForViewModel:(id)viewModel displayType:(long long)displayType {
    if ([WDDManager hideTranslationNotice]) {
        NSMutableDictionary *threadDict = [[NSThread currentThread] threadDictionary];
        BOOL isFocal = NO;
        if (threadDict[@"WDDIsFocalLayout"]) {
            isFocal = [threadDict[@"WDDIsFocalLayout"] boolValue];
        } else {
            isFocal = WDDActiveViewControllerIsDetail;
        }
        if (isFocal) {
            return %orig;
        }
        return NO;
    }
    return %orig;
}
%end

%hook T1StandardStatusGrokAutoTranslateAnnotationViewAdapter
- (BOOL)shouldBeVisibleForViewModel:(id)viewModel {
    if ([WDDManager hideTranslationNotice]) {
        NSMutableDictionary *threadDict = [[NSThread currentThread] threadDictionary];
        BOOL isFocal = NO;
        if (threadDict[@"WDDIsFocalLayout"]) {
            isFocal = [threadDict[@"WDDIsFocalLayout"] boolValue];
        } else {
            isFocal = WDDActiveViewControllerIsDetail;
        }
        if (isFocal) {
            return %orig;
        }
        return NO;
    }
    return %orig;
}
- (BOOL)shouldBeVisibleForViewModel:(id)viewModel displayType:(long long)displayType {
    if ([WDDManager hideTranslationNotice]) {
        NSMutableDictionary *threadDict = [[NSThread currentThread] threadDictionary];
        BOOL isFocal = NO;
        if (threadDict[@"WDDIsFocalLayout"]) {
            isFocal = [threadDict[@"WDDIsFocalLayout"] boolValue];
        } else {
            isFocal = WDDActiveViewControllerIsDetail;
        }
        if (isFocal) {
            return %orig;
        }
        return NO;
    }
    return %orig;
}
%end

%hook T1StandardStatusGrokAutoTranslateToggleViewAdapter
- (BOOL)shouldBeVisibleForViewModel:(id)viewModel {
    if ([WDDManager hideTranslationNotice]) {
        NSMutableDictionary *threadDict = [[NSThread currentThread] threadDictionary];
        BOOL isFocal = NO;
        if (threadDict[@"WDDIsFocalLayout"]) {
            isFocal = [threadDict[@"WDDIsFocalLayout"] boolValue];
        } else {
            isFocal = WDDActiveViewControllerIsDetail;
        }
        if (isFocal) {
            return %orig;
        }
        return NO;
    }
    return %orig;
}
- (BOOL)shouldBeVisibleForViewModel:(id)viewModel displayType:(long long)displayType {
    if ([WDDManager hideTranslationNotice]) {
        NSMutableDictionary *threadDict = [[NSThread currentThread] threadDictionary];
        BOOL isFocal = NO;
        if (threadDict[@"WDDIsFocalLayout"]) {
            isFocal = [threadDict[@"WDDIsFocalLayout"] boolValue];
        } else {
            isFocal = WDDActiveViewControllerIsDetail;
        }
        if (isFocal) {
            return %orig;
        }
        return NO;
    }
    return %orig;
}
%end

%hook T1StandardStatusTranslateView
- (id)initWithFrame:(CGRect)frame {
    id result = %orig(frame);
    if (result && [WDDManager hideTranslationNotice]) {
        BOOL isFocal = WDDIsFocalContext((UIView *)result);
        objc_setAssociatedObject(result, @selector(layoutSubviews), @(isFocal), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        if (!isFocal) {
            UIView *view = (UIView *)result;
            view.hidden = YES;
            view.alpha = 0.0;
        }
    }
    return result;
}

- (id)init {
    id result = %orig;
    if (result && [WDDManager hideTranslationNotice]) {
        BOOL isFocal = WDDIsFocalContext((UIView *)result);
        objc_setAssociatedObject(result, @selector(layoutSubviews), @(isFocal), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        if (!isFocal) {
            UIView *view = (UIView *)result;
            view.hidden = YES;
            view.alpha = 0.0;
        }
    }
    return result;
}

- (void)layoutSubviews {
    %orig;
    if ([WDDManager hideTranslationNotice]) {
        NSNumber *associated = objc_getAssociatedObject(self, @selector(layoutSubviews));
        BOOL isFocal = associated ? [associated boolValue] : WDDIsFocalContext((UIView *)self);
        if (!isFocal) {
            UIView *view = (UIView *)self;
            view.hidden = YES;
            view.alpha = 0.0;
        }
    }
}

- (CGSize)sizeThatFits:(CGSize)size {
    if ([WDDManager hideTranslationNotice]) {
        NSNumber *associated = objc_getAssociatedObject(self, @selector(layoutSubviews));
        BOOL isFocal = associated ? [associated boolValue] : WDDIsFocalContext((UIView *)self);
        if (!isFocal) {
            return CGSizeZero;
        }
    }
    return %orig(size);
}
%end

%hook T1StandardStatusGrokTranslationFeedbackViewAdapter
- (BOOL)shouldBeVisibleForViewModel:(id)viewModel {
    return [WDDManager hideTranslationNotice] ? NO : %orig;
}
- (BOOL)shouldBeVisibleForViewModel:(id)viewModel displayType:(long long)displayType {
    return [WDDManager hideTranslationNotice] ? NO : %orig;
}
%end

%hook T1StandardStatusTweetContextViewAdapter
- (BOOL)shouldBeVisibleForViewModel:(id)viewModel {
    return [WDDManager hideReplyToIndicator] ? NO : %orig;
}
- (BOOL)shouldBeVisibleForViewModel:(id)viewModel displayType:(id)displayType {
    return [WDDManager hideReplyToIndicator] ? NO : %orig;
}
%end

%hook T1StandardStatusConversationContextViewAdapter
- (BOOL)shouldBeVisibleForViewModel:(id)viewModel {
    return [WDDManager hideReplyToIndicator] ? NO : %orig;
}
- (BOOL)shouldBeVisibleForViewModel:(id)viewModel displayType:(id)displayType {
    return [WDDManager hideReplyToIndicator] ? NO : %orig;
}
%end

%hook T1StandardStatusSocialContextViewAdapter
- (BOOL)shouldBeVisibleForViewModel:(id)viewModel {
    if ([WDDManager hideReplyToIndicator] && WDDIsViewModelReply(viewModel)) {
        return NO;
    }
    return %orig;
}
- (BOOL)shouldBeVisibleForViewModel:(id)viewModel displayType:(id)displayType {
    if ([WDDManager hideReplyToIndicator] && WDDIsViewModelReply(viewModel)) {
        return NO;
    }
    return %orig;
}
%end

%end // end of TimelineTranslation group

// ==============================
// Hide Grok Buttons
// ==============================

%hook T1StandardStatusEditWithGrokButtonViewAdapter
- (BOOL)shouldBeVisibleForViewModel:(id)viewModel {
    if ([WDDManager hideGrokButtons]) {
        if (WDDIsFocalContext(nil)) {
            return %orig;
        }
        return NO;
    }
    return %orig;
}
- (BOOL)shouldBeVisibleForViewModel:(id)viewModel displayType:(long long)displayType {
    if ([WDDManager hideGrokButtons]) {
        if (WDDIsFocalContext(nil)) {
            return %orig;
        }
        return NO;
    }
    return %orig;
}
%end

%hook T1StandardStatusGrokEditPhotoButtonAdapter
- (BOOL)shouldBeVisibleForViewModel:(id)viewModel {
    if ([WDDManager hideGrokButtons]) {
        if (WDDIsFocalContext(nil)) {
            return %orig;
        }
        return NO;
    }
    return %orig;
}
- (BOOL)shouldBeVisibleForViewModel:(id)viewModel displayType:(long long)displayType {
    if ([WDDManager hideGrokButtons]) {
        if (WDDIsFocalContext(nil)) {
            return %orig;
        }
        return NO;
    }
    return %orig;
}
%end

%hook T1StandardStatusDownloadGrokImagineButtonViewAdapter
- (BOOL)shouldBeVisibleForViewModel:(id)viewModel {
    if ([WDDManager hideGrokButtons]) {
        if (WDDIsFocalContext(nil)) {
            return %orig;
        }
        return NO;
    }
    return %orig;
}
- (BOOL)shouldBeVisibleForViewModel:(id)viewModel displayType:(long long)displayType {
    if ([WDDManager hideGrokButtons]) {
        if (WDDIsFocalContext(nil)) {
            return %orig;
        }
        return NO;
    }
    return %orig;
}
%end

%hook T1StandardStatusGrokCreateOwnButtonAdapter
- (BOOL)shouldBeVisibleForViewModel:(id)viewModel {
    if ([WDDManager hideGrokButtons]) {
        if (WDDIsFocalContext(nil)) {
            return %orig;
        }
        return NO;
    }
    return %orig;
}
- (BOOL)shouldBeVisibleForViewModel:(id)viewModel displayType:(long long)displayType {
    if ([WDDManager hideGrokButtons]) {
        if (WDDIsFocalContext(nil)) {
            return %orig;
        }
        return NO;
    }
    return %orig;
}
%end

%hook T1StandardStatusAskGrokButtonViewAdapter
- (BOOL)shouldBeVisibleForViewModel:(id)viewModel {
    if ([WDDManager hideGrokButtons]) {
        if (WDDIsFocalContext(nil)) {
            return %orig;
        }
        return NO;
    }
    return %orig;
}
- (BOOL)shouldBeVisibleForViewModel:(id)viewModel displayType:(long long)displayType {
    if ([WDDManager hideGrokButtons]) {
        if (WDDIsFocalContext(nil)) {
            return %orig;
        }
        return NO;
    }
    return %orig;
}
%end

%hook T1StatusPostCtaGrokDownloadView
- (id)initWithFrame:(CGRect)frame {
    id result = %orig(frame);
    if (result && [WDDManager hideGrokButtons]) {
        if (!WDDIsFocalContext((UIView *)result)) {
            UIView *view = (UIView *)result;
            view.hidden = YES;
            view.alpha = 0.0;
        }
    }
    return result;
}
- (id)init {
    id result = %orig;
    if (result && [WDDManager hideGrokButtons]) {
        if (!WDDIsFocalContext((UIView *)result)) {
            UIView *view = (UIView *)result;
            view.hidden = YES;
            view.alpha = 0.0;
        }
    }
    return result;
}
- (void)layoutSubviews {
    %orig;
    if ([WDDManager hideGrokButtons]) {
        UIView *view = (UIView *)self;
        if (!WDDIsFocalContext(view)) {
            view.hidden = YES;
            view.alpha = 0.0;
        }
    }
}
- (CGSize)sizeThatFits:(CGSize)size {
    if ([WDDManager hideGrokButtons]) {
        if (!WDDIsFocalContext((UIView *)self)) {
            return CGSizeZero;
        }
    }
    return %orig;
}
%end

%hook StatusPostCtaGrokDownloadView
- (id)initWithFrame:(CGRect)frame {
    id result = %orig(frame);
    if (result && [WDDManager hideGrokButtons]) {
        if (!WDDIsFocalContext((UIView *)result)) {
            UIView *view = (UIView *)result;
            view.hidden = YES;
            view.alpha = 0.0;
        }
    }
    return result;
}
- (id)init {
    id result = %orig;
    if (result && [WDDManager hideGrokButtons]) {
        if (!WDDIsFocalContext((UIView *)result)) {
            UIView *view = (UIView *)result;
            view.hidden = YES;
            view.alpha = 0.0;
        }
    }
    return result;
}
- (void)layoutSubviews {
    %orig;
    if ([WDDManager hideGrokButtons]) {
        UIView *view = (UIView *)self;
        if (!WDDIsFocalContext(view)) {
            view.hidden = YES;
            view.alpha = 0.0;
        }
    }
}
- (CGSize)sizeThatFits:(CGSize)size {
    if ([WDDManager hideGrokButtons]) {
        if (!WDDIsFocalContext((UIView *)self)) {
            return CGSizeZero;
        }
    }
    return %orig;
}
%end

%hook T1StandardStatusEditWithGrokButtonView
- (id)initWithFrame:(CGRect)frame {
    id result = %orig(frame);
    if (result && [WDDManager hideGrokButtons]) {
        if (!WDDIsFocalContext((UIView *)result)) {
            UIView *view = (UIView *)result;
            view.hidden = YES;
            view.alpha = 0.0;
        }
    }
    return result;
}
- (id)init {
    id result = %orig;
    if (result && [WDDManager hideGrokButtons]) {
        if (!WDDIsFocalContext((UIView *)result)) {
            UIView *view = (UIView *)result;
            view.hidden = YES;
            view.alpha = 0.0;
        }
    }
    return result;
}
- (void)layoutSubviews {
    %orig;
    if ([WDDManager hideGrokButtons]) {
        UIView *view = (UIView *)self;
        if (!WDDIsFocalContext(view)) {
            view.hidden = YES;
            view.alpha = 0.0;
        }
    }
}
- (CGSize)sizeThatFits:(CGSize)size {
    if ([WDDManager hideGrokButtons]) {
        if (!WDDIsFocalContext((UIView *)self)) {
            return CGSizeZero;
        }
    }
    return %orig;
}
%end

%hook StandardStatusEditWithGrokButtonView
- (id)initWithFrame:(CGRect)frame {
    id result = %orig(frame);
    if (result && [WDDManager hideGrokButtons]) {
        if (!WDDIsFocalContext((UIView *)result)) {
            UIView *view = (UIView *)result;
            view.hidden = YES;
            view.alpha = 0.0;
        }
    }
    return result;
}
- (id)init {
    id result = %orig;
    if (result && [WDDManager hideGrokButtons]) {
        if (!WDDIsFocalContext((UIView *)result)) {
            UIView *view = (UIView *)result;
            view.hidden = YES;
            view.alpha = 0.0;
        }
    }
    return result;
}
- (void)layoutSubviews {
    %orig;
    if ([WDDManager hideGrokButtons]) {
        UIView *view = (UIView *)self;
        if (!WDDIsFocalContext(view)) {
            view.hidden = YES;
            view.alpha = 0.0;
        }
    }
}
- (CGSize)sizeThatFits:(CGSize)size {
    if ([WDDManager hideGrokButtons]) {
        if (!WDDIsFocalContext((UIView *)self)) {
            return CGSizeZero;
        }
    }
    return %orig;
}
%end

%hook T1StandardStatusAskGrokButtonView
- (id)initWithFrame:(CGRect)frame {
    id result = %orig(frame);
    if (result && [WDDManager hideGrokButtons]) {
        if (!WDDIsFocalContext((UIView *)result)) {
            UIView *view = (UIView *)result;
            view.hidden = YES;
            view.alpha = 0.0;
        }
    }
    return result;
}
- (id)init {
    id result = %orig;
    if (result && [WDDManager hideGrokButtons]) {
        if (!WDDIsFocalContext((UIView *)result)) {
            UIView *view = (UIView *)result;
            view.hidden = YES;
            view.alpha = 0.0;
        }
    }
    return result;
}
- (void)layoutSubviews {
    %orig;
    if ([WDDManager hideGrokButtons]) {
        UIView *view = (UIView *)self;
        if (!WDDIsFocalContext(view)) {
            view.hidden = YES;
            view.alpha = 0.0;
        }
    }
}
- (CGSize)sizeThatFits:(CGSize)size {
    if ([WDDManager hideGrokButtons]) {
        if (!WDDIsFocalContext((UIView *)self)) {
            return CGSizeZero;
        }
    }
    return %orig;
}
%end

%hook StandardStatusAskGrokButtonView
- (id)initWithFrame:(CGRect)frame {
    id result = %orig(frame);
    if (result && [WDDManager hideGrokButtons]) {
        if (!WDDIsFocalContext((UIView *)result)) {
            UIView *view = (UIView *)result;
            view.hidden = YES;
            view.alpha = 0.0;
        }
    }
    return result;
}
- (id)init {
    id result = %orig;
    if (result && [WDDManager hideGrokButtons]) {
        if (!WDDIsFocalContext((UIView *)result)) {
            UIView *view = (UIView *)result;
            view.hidden = YES;
            view.alpha = 0.0;
        }
    }
    return result;
}
- (void)layoutSubviews {
    %orig;
    if ([WDDManager hideGrokButtons]) {
        UIView *view = (UIView *)self;
        if (!WDDIsFocalContext(view)) {
            view.hidden = YES;
            view.alpha = 0.0;
        }
    }
}
- (CGSize)sizeThatFits:(CGSize)size {
    if ([WDDManager hideGrokButtons]) {
        if (!WDDIsFocalContext((UIView *)self)) {
            return CGSizeZero;
        }
    }
    return %orig;
}
%end

%hook T1GrokEditPhotoButtonView
- (id)initWithFrame:(CGRect)frame {
    id result = %orig(frame);
    if (result && [WDDManager hideGrokButtons]) {
        if (!WDDIsFocalContext((UIView *)result)) {
            UIView *view = (UIView *)result;
            view.hidden = YES;
            view.alpha = 0.0;
        }
    }
    return result;
}
- (id)init {
    id result = %orig;
    if (result && [WDDManager hideGrokButtons]) {
        if (!WDDIsFocalContext((UIView *)result)) {
            UIView *view = (UIView *)result;
            view.hidden = YES;
            view.alpha = 0.0;
        }
    }
    return result;
}
- (void)layoutSubviews {
    %orig;
    if ([WDDManager hideGrokButtons]) {
        UIView *view = (UIView *)self;
        if (!WDDIsFocalContext(view)) {
            view.hidden = YES;
            view.alpha = 0.0;
        }
    }
}
- (CGSize)sizeThatFits:(CGSize)size {
    if ([WDDManager hideGrokButtons]) {
        if (!WDDIsFocalContext((UIView *)self)) {
            return CGSizeZero;
        }
    }
    return %orig;
}
%end

%hook GrokEditPhotoButtonView
- (id)initWithFrame:(CGRect)frame {
    id result = %orig(frame);
    if (result && [WDDManager hideGrokButtons]) {
        if (!WDDIsFocalContext((UIView *)result)) {
            UIView *view = (UIView *)result;
            view.hidden = YES;
            view.alpha = 0.0;
        }
    }
    return result;
}
- (id)init {
    id result = %orig;
    if (result && [WDDManager hideGrokButtons]) {
        if (!WDDIsFocalContext((UIView *)result)) {
            UIView *view = (UIView *)result;
            view.hidden = YES;
            view.alpha = 0.0;
        }
    }
    return result;
}
- (void)layoutSubviews {
    %orig;
    if ([WDDManager hideGrokButtons]) {
        UIView *view = (UIView *)self;
        if (!WDDIsFocalContext(view)) {
            view.hidden = YES;
            view.alpha = 0.0;
        }
    }
}
- (CGSize)sizeThatFits:(CGSize)size {
    if ([WDDManager hideGrokButtons]) {
        if (!WDDIsFocalContext((UIView *)self)) {
            return CGSizeZero;
        }
    }
    return %orig;
}
%end

%hook GrokCreateOwnVideoButtonView
- (id)initWithFrame:(CGRect)frame {
    id result = %orig(frame);
    if (result && [WDDManager hideGrokButtons]) {
        if (!WDDIsFocalContext((UIView *)result)) {
            UIView *view = (UIView *)result;
            view.hidden = YES;
            view.alpha = 0.0;
        }
    }
    return result;
}
- (id)init {
    id result = %orig;
    if (result && [WDDManager hideGrokButtons]) {
        if (!WDDIsFocalContext((UIView *)result)) {
            UIView *view = (UIView *)result;
            view.hidden = YES;
            view.alpha = 0.0;
        }
    }
    return result;
}
- (void)layoutSubviews {
    %orig;
    if ([WDDManager hideGrokButtons]) {
        UIView *view = (UIView *)self;
        if (!WDDIsFocalContext(view)) {
            view.hidden = YES;
            view.alpha = 0.0;
        }
    }
}
- (CGSize)sizeThatFits:(CGSize)size {
    if ([WDDManager hideGrokButtons]) {
        if (!WDDIsFocalContext((UIView *)self)) {
            return CGSizeZero;
        }
    }
    return %orig;
}
%end

// ==============================
// Grok Feature Switches Overrides
// ==============================

%hook TPSTwitterFeatureSwitches
- (BOOL)boolForKey:(NSString *)key {
    if ([WDDManager hideGrokButtons]) {
        if ([key isEqualToString:@"grok_chat_download_standalone_button_enabled"] ||
            [key isEqualToString:@"grok_explain_download_banner_enabled"] ||
            [key isEqualToString:@"grok_ios_app_campaign_grok_chat_download_banner"] ||
            [key isEqualToString:@"grok_ios_app_campaign_grok_posts"] ||
            [key isEqualToString:@"dash_items_download_grok_enabled"] ||
            [key isEqualToString:@"grok_immersive_create_own_button_enabled"] ||
            [key isEqualToString:@"grok_timeline_create_own_is_enabled"] ||
            [key isEqualToString:@"grok_timeline_create_own_is_enabled_detail_page"] ||
            [key isEqualToString:@"grok_timeline_create_own_is_enabled_quoted_status"] ||
            [key isEqualToString:@"grok_edit_with_grok_button_under_post_focal_enabled"] ||
            [key isEqualToString:@"grok_edit_with_grok_button_under_post_preview_enabled"] ||
            [key isEqualToString:@"grok_ask_grok_button_under_post_focal_enabled"] ||
            [key isEqualToString:@"grok_ask_grok_button_under_post_preview_enabled"] ||
            [key isEqualToString:@"grok_ios_edit_photo_post_button_enabled"] ||
            [key isEqualToString:@"ios_composer_grok_button_enabled"]) {
            return NO;
        }
    }
    return %orig;
}
%end

%group QuotedTranslation
%hook ClassName
- (BOOL)isTranslatable {
    if ([WDDManager hideTranslationNotice]) {
        NSNumber *associated = objc_getAssociatedObject(self, @selector(isTranslatable));
        if (associated) {
            return [associated boolValue] ? %orig : NO;
        }
        
        NSMutableDictionary *threadDict = [[NSThread currentThread] threadDictionary];
        BOOL isFocal = NO;
        if (threadDict[@"WDDIsFocalLayout"]) {
            isFocal = [threadDict[@"WDDIsFocalLayout"] boolValue];
        } else {
            isFocal = WDDActiveViewControllerIsDetail;
        }
        
        objc_setAssociatedObject(self, @selector(isTranslatable), @(isFocal), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        return isFocal ? %orig : NO;
    }
    return %orig;
}
%end
%end

%ctor {
    %init;
    %init(TimelineTranslation);
    
    Class quotedLayoutClass = objc_getClass("_TtC14T1TwitterSwiftP33_3A09CF4E063C1F38BB397ABF76410C9439GrokTranslateQuotedAnnoationLayoutState");
    if (quotedLayoutClass) {
        %init(QuotedTranslation, ClassName = quotedLayoutClass);
    }
}
