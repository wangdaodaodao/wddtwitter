#import "WDDManager.h"
#import "WDDUtils.h"
#import "TWHeaders.h"
#import <objc/runtime.h>
#import <objc/message.h>

static void WDDApplyTranslationViewVisibility(UIView *view) {
    if (!view) return;
    if (WDDShouldHideTranslation()) {
        objc_setAssociatedObject(view, @selector(layoutSubviews), @YES, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        if (!view.hidden) {
            view.hidden = YES;
        }
        if (view.alpha != 0.0) {
            view.alpha = 0.0;
        }
    } else if ([objc_getAssociatedObject(view, @selector(layoutSubviews)) boolValue]) {
        objc_setAssociatedObject(view, @selector(layoutSubviews), nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        if (view.hidden) {
            view.hidden = NO;
        }
        if (view.alpha == 0.0) {
            view.alpha = 1.0;
        }
    }
}

%group TimelineTranslation

%hook T1StandardStatusTranslateLayoutState
- (BOOL)isTranslatable {
    if (WDDShouldHideTranslation()) {
        return NO;
    }
    return %orig;
}

- (void)setTranslatable:(BOOL)translatable {
    %orig(WDDShouldHideTranslation() ? NO : translatable);
}

- (CGSize)size {
    if (WDDShouldHideTranslation()) {
        return CGSizeZero;
    }
    return %orig;
}

- (void)setSize:(CGSize)size {
    %orig(WDDShouldHideTranslation() ? CGSizeZero : size);
}
%end

%hook T1TranslateButtonDisplayHelper
+ (BOOL)canShowTranslationButtonFor:(id)viewModel {
    if (WDDShouldHideTranslation()) return NO;
    return %orig;
}

+ (BOOL)canShowTranslationButtonFor:(id)viewModel account:(id)account {
    if (WDDShouldHideTranslation()) return NO;
    return %orig;
}
%end

%hook T1StandardStatusTranslateAdapter
- (BOOL)shouldBeVisibleForViewModel:(id)viewModel {
    if (WDDShouldHideTranslation()) {
        return NO;
    }
    return %orig;
}
%end

%hook T1StandardStatusGrokTranslateButtonViewAdapter
- (BOOL)shouldBeVisibleForViewModel:(id)viewModel {
    if (WDDShouldHideTranslation()) {
        return NO;
    }
    return %orig;
}
%end

%hook T1StandardStatusGrokAutoTranslateAnnotationViewAdapter
- (BOOL)shouldBeVisibleForViewModel:(id)viewModel {
    if (WDDShouldHideTranslation()) {
        return NO;
    }
    return %orig;
}
%end

%hook T1StandardStatusGrokAutoTranslateToggleViewAdapter
- (BOOL)shouldBeVisibleForViewModel:(id)viewModel {
    if (WDDShouldHideTranslation()) {
        return NO;
    }
    return %orig;
}
%end

%hook T1StandardStatusTranslateView
+ (double)buttonHeightForWidth:(double)width languageName:(id)languageName showTranslation:(BOOL)showTranslation translationProvider:(id)translationProvider {
    if (WDDShouldHideTranslation()) return 0.0;
    return %orig;
}

- (id)initWithFrame:(CGRect)frame {
    id result = %orig(frame);
    if (result) {
        WDDApplyTranslationViewVisibility((UIView *)result);
    }
    return result;
}

- (id)init {
    id result = %orig;
    if (result) {
        WDDApplyTranslationViewVisibility((UIView *)result);
    }
    return result;
}

- (void)layoutSubviews {
    %orig;
    WDDApplyTranslationViewVisibility((UIView *)self);
}

- (CGSize)sizeThatFits:(CGSize)size {
    if (WDDShouldHideTranslation()) {
        return CGSizeZero;
    }
    return %orig(size);
}

- (CGSize)intrinsicContentSize {
    if (WDDShouldHideTranslation()) {
        return CGSizeZero;
    }
    return %orig;
}
%end

%hook T1StandardStatusGrokTranslationFeedbackViewAdapter
- (BOOL)shouldBeVisibleForViewModel:(id)viewModel {
    return WDDShouldHideTranslation() ? NO : %orig;
}
%end

%hook T1StandardStatusTweetContextViewAdapter
- (BOOL)shouldBeVisibleForViewModel:(id)viewModel {
    return [WDDManager hideReplyToIndicator] ? NO : %orig;
}
%end

%hook T1StandardStatusConversationContextViewAdapter
- (BOOL)shouldBeVisibleForViewModel:(id)viewModel {
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
%end

%end

static BOOL WDDGrokViewShouldHide(UIView *view) {
    return [WDDManager hideGrokButtons] && !WDDIsFocalContext(view);
}

static void WDDHideGrokView(UIView *view) {
    if (!view) return;
    if (!WDDGrokViewShouldHide(view)) return;
    if (!view.hidden) {
        view.hidden = YES;
    }
    if (view.alpha != 0.0) {
        view.alpha = 0.0;
    }
}

static BOOL WDDGrokAdapterShouldHide(void) {
    return [WDDManager hideGrokButtons] && !WDDIsFocalContext(nil);
}

%hook T1StandardStatusEditWithGrokButtonViewAdapter
- (BOOL)shouldBeVisibleForViewModel:(id)viewModel {
    if (WDDGrokAdapterShouldHide()) return NO;
    return %orig;
}
%end

%hook T1StandardStatusGrokEditPhotoButtonAdapter
- (BOOL)shouldBeVisibleForViewModel:(id)viewModel {
    if (WDDGrokAdapterShouldHide()) return NO;
    return %orig;
}
%end

%hook T1StandardStatusDownloadGrokImagineButtonViewAdapter
- (BOOL)shouldBeVisibleForViewModel:(id)viewModel {
    if (WDDGrokAdapterShouldHide()) return NO;
    return %orig;
}
%end

%hook T1StandardStatusGrokCreateOwnButtonAdapter
- (BOOL)shouldBeVisibleForViewModel:(id)viewModel {
    if (WDDGrokAdapterShouldHide()) return NO;
    return %orig;
}
%end

%hook T1StandardStatusAskGrokButtonViewAdapter
- (BOOL)shouldBeVisibleForViewModel:(id)viewModel {
    if (WDDGrokAdapterShouldHide()) return NO;
    return %orig;
}
%end

%hook T1StatusPostCtaGrokDownloadView
- (id)initWithFrame:(CGRect)frame { id r = %orig(frame); WDDHideGrokView((UIView *)r); return r; }
- (id)init { id r = %orig; WDDHideGrokView((UIView *)r); return r; }
- (void)layoutSubviews { %orig; WDDHideGrokView((UIView *)self); }
- (CGSize)sizeThatFits:(CGSize)size { return WDDGrokViewShouldHide((UIView *)self) ? CGSizeZero : %orig(size); }
%end

%hook T1StandardStatusEditWithGrokButtonView
- (id)initWithFrame:(CGRect)frame { id r = %orig(frame); WDDHideGrokView((UIView *)r); return r; }
- (id)init { id r = %orig; WDDHideGrokView((UIView *)r); return r; }
- (void)layoutSubviews { %orig; WDDHideGrokView((UIView *)self); }
- (CGSize)sizeThatFits:(CGSize)size { return WDDGrokViewShouldHide((UIView *)self) ? CGSizeZero : %orig(size); }
%end

%hook T1StandardStatusAskGrokButtonView
- (id)initWithFrame:(CGRect)frame { id r = %orig(frame); WDDHideGrokView((UIView *)r); return r; }
- (id)init { id r = %orig; WDDHideGrokView((UIView *)r); return r; }
- (void)layoutSubviews { %orig; WDDHideGrokView((UIView *)self); }
- (CGSize)sizeThatFits:(CGSize)size { return WDDGrokViewShouldHide((UIView *)self) ? CGSizeZero : %orig(size); }
%end

%hook T1GrokEditPhotoButtonView
- (id)initWithFrame:(CGRect)frame { id r = %orig(frame); WDDHideGrokView((UIView *)r); return r; }
- (id)init { id r = %orig; WDDHideGrokView((UIView *)r); return r; }
- (void)layoutSubviews { %orig; WDDHideGrokView((UIView *)self); }
- (CGSize)sizeThatFits:(CGSize)size { return WDDGrokViewShouldHide((UIView *)self) ? CGSizeZero : %orig(size); }
%end

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
    if (WDDShouldHideTranslation()) {
        return NO;
    }
    return %orig;
}

- (CGSize)size {
    if (WDDShouldHideTranslation()) {
        return CGSizeZero;
    }
    return %orig;
}

- (void)setSize:(CGSize)size {
    %orig(WDDShouldHideTranslation() ? CGSizeZero : size);
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
