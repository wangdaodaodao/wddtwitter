#import "WDDManager.h"
#import "WDDUtils.h"
#import "TWHeaders.h"
#import <objc/runtime.h>
#import <objc/message.h>

// ==============================
// Hide Translation Banner / Grok Translation
// ==============================

%group TimelineTranslation

%hook T1ConversationFocalStatusViewLayoutStateGenerator
- (id)layoutStateForViewModel:(id)viewModel options:(unsigned long long)options account:(id)account layoutMetrics:(id)layoutMetrics withPreviousLayoutState:(id)previousLayoutState {
    NSMutableDictionary *threadDict = [[NSThread currentThread] threadDictionary];
    id oldVal = threadDict[@"WDDIsFocalLayout"];
    threadDict[@"WDDIsFocalLayout"] = @YES;
    id result = %orig;
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
    id result = %orig;
    if (oldVal) {
        threadDict[@"WDDIsFocalLayout"] = oldVal;
    } else {
        [threadDict removeObjectForKey:@"WDDIsFocalLayout"];
    }
    return result;
}
%end

%hook T1StandardStatusTranslateLayoutState
- (BOOL)isTranslatable {
    if ([WDDManager hideTranslationNotice]) {
        if (WDDIsFocalContext(nil)) {
            return %orig;
        }
        return NO;
    }
    return %orig;
}
- (void)setTranslatable:(BOOL)translatable {
    if ([WDDManager hideTranslationNotice]) {
        if (WDDIsFocalContext(nil)) {
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
        if (WDDIsFocalContext(nil)) {
            return %orig;
        }
        return NO;
    }
    return %orig;
}
- (BOOL)shouldBeVisibleForViewModel:(id)viewModel displayType:(long long)displayType {
    if ([WDDManager hideTranslationNotice]) {
        if (WDDIsFocalContext(nil)) {
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
        if (WDDIsFocalContext(nil)) {
            return %orig;
        }
        return NO;
    }
    return %orig;
}
- (BOOL)shouldBeVisibleForViewModel:(id)viewModel displayType:(long long)displayType {
    if ([WDDManager hideTranslationNotice]) {
        if (WDDIsFocalContext(nil)) {
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
        if (WDDIsFocalContext(nil)) {
            return %orig;
        }
        return NO;
    }
    return %orig;
}
- (BOOL)shouldBeVisibleForViewModel:(id)viewModel displayType:(long long)displayType {
    if ([WDDManager hideTranslationNotice]) {
        if (WDDIsFocalContext(nil)) {
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
        if (WDDIsFocalContext(nil)) {
            return %orig;
        }
        return NO;
    }
    return %orig;
}
- (BOOL)shouldBeVisibleForViewModel:(id)viewModel displayType:(long long)displayType {
    if ([WDDManager hideTranslationNotice]) {
        if (WDDIsFocalContext(nil)) {
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
    if (result && [WDDManager hideTranslationNotice]) {
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
    if ([WDDManager hideTranslationNotice]) {
        UIView *view = (UIView *)self;
        if (!WDDIsFocalContext(view)) {
            view.hidden = YES;
            view.alpha = 0.0;
        } else {
            view.hidden = NO;
            view.alpha = 1.0;
        }
    }
}

- (CGSize)sizeThatFits:(CGSize)size {
    if ([WDDManager hideTranslationNotice]) {
        if (!WDDIsFocalContext((UIView *)self)) {
            return CGSizeZero;
        }
    }
    return %orig;
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
        } else {
            view.hidden = NO;
            view.alpha = 1.0;
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
        } else {
            view.hidden = NO;
            view.alpha = 1.0;
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
        } else {
            view.hidden = NO;
            view.alpha = 1.0;
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
        } else {
            view.hidden = NO;
            view.alpha = 1.0;
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
        } else {
            view.hidden = NO;
            view.alpha = 1.0;
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
        } else {
            view.hidden = NO;
            view.alpha = 1.0;
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
        } else {
            view.hidden = NO;
            view.alpha = 1.0;
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
        } else {
            view.hidden = NO;
            view.alpha = 1.0;
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
        } else {
            view.hidden = NO;
            view.alpha = 1.0;
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

%ctor {
    %init;
    %init(TimelineTranslation);
}
