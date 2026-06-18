#import "WDDManager.h"
#import "WDDSettingsViewController.h"
#import "TWHeaders.h"
#import <objc/runtime.h>
#import <objc/message.h>

// Use casting for self when accessing properties not in TWHeaders.h

// ==============================
// Keyword Filtering Logic
// ==============================

static BOOL shouldHideTweetByKeywords(id item) {
    id status = item;
    if ([item respondsToSelector:@selector(status)]) {
        status = ((id (*)(id, SEL))objc_msgSend)(item, @selector(status));
    }
    
    if (status && [status respondsToSelector:@selector(isReply)]) {
        BOOL isReply = ((BOOL (*) (id, SEL))objc_msgSend)(status, @selector(isReply));
        if (isReply) {
            NSString *text = nil;
            if ([status respondsToSelector:@selector(fullText)]) {
                text = ((id (*)(id, SEL))objc_msgSend)(status, @selector(fullText));
            } else if ([status respondsToSelector:@selector(text)]) {
                text = ((id (*)(id, SEL))objc_msgSend)(status, @selector(text));
            }
            
            if (text && text.length > 0) {
                // 1. Emoji Filter Logic (Bot cleanup)
                if ([WDDManager enableEmojiFilter]) {
                    static NSRegularExpression *chineseRegex = nil;
                    static NSRegularExpression *emojiRegex = nil;
                    static NSRegularExpression *alphaNumRegex = nil;
                    static dispatch_once_t onceToken;
                    dispatch_once(&onceToken, ^{
                        chineseRegex = [NSRegularExpression regularExpressionWithPattern:@"[\\u4e00-\\u9fa5]" options:0 error:NULL];
                        emojiRegex = [NSRegularExpression regularExpressionWithPattern:@"\\p{Emoji_Presentation}|\\p{Emoji}\\uFE0F" options:0 error:NULL];
                        alphaNumRegex = [NSRegularExpression regularExpressionWithPattern:@"[a-zA-Z0-9]" options:0 error:NULL];
                    });
                    
                    NSUInteger chineseCount = [chineseRegex numberOfMatchesInString:text options:0 range:NSMakeRange(0, text.length)];
                    
                    if (chineseCount == 0) {
                        // Check if it has more than 3 emojis
                        NSUInteger emojiCount = [emojiRegex numberOfMatchesInString:text options:0 range:NSMakeRange(0, text.length)];
                        if (emojiCount > 3) {
                            return YES;
                        }
                        
                        // If no Chinese and <= 3 emojis, check for letters/numbers
                        NSUInteger alphaNumCount = [alphaNumRegex numberOfMatchesInString:text options:0 range:NSMakeRange(0, text.length)];
                        
                        if (alphaNumCount == 0) {
                            // No Chinese and No AlphaNumeric -> Pure Emoji/Symbols/Spam
                            return YES;
                        }
                    }
                }

                // 1.5 Custom Regex Filter Logic
                if ([WDDManager enableRegexFilter]) {
                    NSString *regexesStr = [WDDManager replyRegexes];
                    if (regexesStr != nil && regexesStr.length > 0) {
                        static NSString *cachedRegexesStr = nil;
                        static NSArray<NSRegularExpression *> *cachedRegexObjects = nil;
                        static NSObject *lockObj = nil;
                        static dispatch_once_t lockOnce;
                        dispatch_once(&lockOnce, ^{
                            lockObj = [[NSObject alloc] init];
                        });
                        
                        @synchronized(lockObj) {
                            if (![regexesStr isEqualToString:cachedRegexesStr]) {
                                cachedRegexesStr = [regexesStr copy];
                                NSMutableArray *compiledArray = [NSMutableArray array];
                                NSArray *lines = [regexesStr componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
                                for (NSString *line in lines) {
                                    NSString *pattern = [line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                                    if (pattern.length > 0) {
                                        NSError *error = nil;
                                        NSRegularExpression *customRegex = [NSRegularExpression regularExpressionWithPattern:pattern
                                                                                                                     options:NSRegularExpressionDotMatchesLineSeparators
                                                                                                                       error:&error];
                                        if (!error && customRegex != nil) {
                                            [compiledArray addObject:customRegex];
                                        }
                                    }
                                }
                                cachedRegexObjects = [compiledArray copy];
                            }
                        }
                        
                        for (NSRegularExpression *customRegex in cachedRegexObjects) {
                            NSUInteger matchCount = [customRegex numberOfMatchesInString:text options:0 range:NSMakeRange(0, text.length)];
                            if (matchCount > 0) {
                                return YES;
                            }
                        }
                    }
                }

                // 2. Keyword Filter Logic
                if ([WDDManager enableReplyFilter]) {
                    NSString *keywordsStr = [WDDManager replyKeywords];
                    if (keywordsStr != nil && keywordsStr.length > 0) {
                        // Support both English and Chinese commas
                        NSArray *keywords = [keywordsStr componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@",，"]];
                        int totalMatches = 0;
                        for (NSString *keyword in keywords) {
                            NSString *trimmed = [keyword stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                            if (trimmed.length > 0 && [text rangeOfString:trimmed options:NSCaseInsensitiveSearch].location != NSNotFound) {
                                totalMatches++;
                            }
                        }
                        // Match if any keyword is found
                        if (totalMatches > 0) {
                            return YES;
                        }
                    }
                }
            }
        }
    }
    return NO;
}

%hook TFNItemsDataViewController
- (id)tableViewCellForItem:(id)arg1 atIndexPath:(id)arg2 {
    UITableViewCell *_orig = %orig;
    id tweet = [self itemAtIndexPath:arg2];
    if (shouldHideTweetByKeywords(tweet)) {
        [_orig setHidden:YES];
    }
    return _orig;
}
- (double)tableView:(id)arg1 heightForRowAtIndexPath:(id)arg2 {
    id tweet = [self itemAtIndexPath:arg2];
    if (shouldHideTweetByKeywords(tweet)) {
        return 0;
    }
    return %orig;
}
%end

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

static BOOL isViewModelReply(id viewModel) {
    if (!viewModel) return NO;
    if ([viewModel respondsToSelector:@selector(isReply)]) {
        if (((BOOL (*)(id, SEL))objc_msgSend)(viewModel, @selector(isReply))) {
            return YES;
        }
    }
    if ([viewModel respondsToSelector:@selector(inReplyToScreenName)]) {
        if (((id (*)(id, SEL))objc_msgSend)(viewModel, @selector(inReplyToScreenName)) != nil) {
            return YES;
        }
    }
    if ([viewModel respondsToSelector:@selector(status)]) {
        id status = ((id (*)(id, SEL))objc_msgSend)(viewModel, @selector(status));
        if (status && ![status isKindOfClass:[NSNumber class]]) { // Avoid AVContentKeyRequestStatus conflict
            if ([status respondsToSelector:@selector(isReply)]) {
                if (((BOOL (*)(id, SEL))objc_msgSend)(status, @selector(isReply))) {
                    return YES;
                }
            }
            if ([status respondsToSelector:@selector(inReplyToScreenName)]) {
                if (((id (*)(id, SEL))objc_msgSend)(status, @selector(inReplyToScreenName)) != nil) {
                    return YES;
                }
            }
        }
    }
    return NO;
}

// Helper: detect if a subview is a conversation connector line.
static BOOL isConnectorLineView(UIView *subview) {
    if (!subview) return NO;
    NSString *className = NSStringFromClass([subview class]);
    if ([className rangeOfString:@"ConversationConnectorView"].location != NSNotFound ||
        [className rangeOfString:@"T1StandardStatusConversationConnectorsView"].location != NSNotFound ||
        [className rangeOfString:@"T1ConversationTreeConnectorsView"].location != NSNotFound ||
        [className rangeOfString:@"T1CurvedLine"].location != NSNotFound) {
        return YES;
    }
    if ([className rangeOfString:@"TFNRoundedCornerView"].location != NSNotFound) {
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
            NSString *className = NSStringFromClass([subview class]);
            if ([className rangeOfString:@"SocialContext" options:NSCaseInsensitiveSearch].location != NSNotFound) {
                if (isViewModelReply(viewModel)) {
                    subview.hidden = YES;
                    subview.alpha = 0.0;
                    CGRect f = subview.frame;
                    f.size.height = 0.0;
                    subview.frame = f;
                }
            } else if ([className rangeOfString:@"TweetContext" options:NSCaseInsensitiveSearch].location != NSNotFound ||
                       [className rangeOfString:@"ConversationContext" options:NSCaseInsensitiveSearch].location != NSNotFound) {
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

static BOOL isCurrentViewControllerDetails(UIViewController *vc) {
    if (!vc) return NO;
    
    // 1. Check conversationFocalStatusID
    if ([vc respondsToSelector:@selector(conversationFocalStatusID)]) {
        @try {
            long long focalID = ((long long (*)(id, SEL))objc_msgSend)(vc, @selector(conversationFocalStatusID));
            if (focalID != 0) {
                return YES;
            }
        } @catch (NSException *e) {}
    }
    
    // 2. Check isConversationFocalStatus
    if ([vc respondsToSelector:@selector(isConversationFocalStatus)]) {
        @try {
            BOOL isFocal = ((BOOL (*)(id, SEL))objc_msgSend)(vc, @selector(isConversationFocalStatus));
            if (isFocal) {
                return YES;
            }
        } @catch (NSException *e) {}
    }
    
    // 3. Check timeline property class name (for T1URTViewController with URTConversationTimeline)
    if ([vc respondsToSelector:@selector(timeline)]) {
        @try {
            id timeline = ((id (*)(id, SEL))objc_msgSend)(vc, @selector(timeline));
            if (timeline) {
                NSString *timelineClassName = NSStringFromClass([timeline class]);
                if ([timelineClassName rangeOfString:@"Conversation" options:NSCaseInsensitiveSearch].location != NSNotFound) {
                    return YES;
                }
            }
        } @catch (NSException *e) {}
    }

    // 4. Check scribeContext property (for tweet_detail/conversation pages)
    if ([vc respondsToSelector:@selector(scribeContext)]) {
        @try {
            id scribeContext = ((id (*)(id, SEL))objc_msgSend)(vc, @selector(scribeContext));
            if (scribeContext) {
                NSString *description = [scribeContext description];
                if ([description rangeOfString:@"tweet_detail" options:NSCaseInsensitiveSearch].location != NSNotFound ||
                    [description rangeOfString:@"conversation" options:NSCaseInsensitiveSearch].location != NSNotFound) {
                    return YES;
                }
            }
        } @catch (NSException *e) {}
    }
    
    // 5. Check class name of the view controller
    NSString *className = NSStringFromClass([vc class]);
    if ([className rangeOfString:@"Detail" options:NSCaseInsensitiveSearch].location != NSNotFound ||
        [className rangeOfString:@"Focal" options:NSCaseInsensitiveSearch].location != NSNotFound ||
        [className rangeOfString:@"Conversation" options:NSCaseInsensitiveSearch].location != NSNotFound) {
        return YES;
    }
    
    for (UIViewController *child in vc.childViewControllers) {
        if (isCurrentViewControllerDetails(child)) {
            return YES;
        }
    }
    
    return NO;
}

static BOOL isCurrentActiveContextDetail(void) {
    @try {
        UIWindow *window = nil;
        if (@available(iOS 13.0, *)) {
            for (UIWindowScene *scene in [UIApplication sharedApplication].connectedScenes) {
                if (scene.activationState == UISceneActivationStateForegroundActive) {
                    for (UIWindow *w in scene.windows) {
                        if (w.isKeyWindow) {
                            window = w;
                            break;
                        }
                    }
                }
                if (window) break;
            }
        }
        if (!window) {
            window = [UIApplication sharedApplication].keyWindow;
        }
        UIViewController *vc = window.rootViewController;
        while (vc) {
            if ([vc isKindOfClass:[UINavigationController class]]) {
                UINavigationController *nav = (UINavigationController *)vc;
                // Proactively check topViewController during transition
                UIViewController *top = nav.topViewController;
                if (top && isCurrentViewControllerDetails(top)) {
                    return YES;
                }
                vc = nav.visibleViewController;
            } else if ([vc isKindOfClass:[UITabBarController class]]) {
                vc = [(UITabBarController *)vc selectedViewController];
            } else if (vc.presentedViewController) {
                vc = vc.presentedViewController;
            } else {
                break;
            }
        }
        if (vc) {
            return isCurrentViewControllerDetails(vc);
        }
    } @catch (NSException *e) {}
    return NO;
}

static UIViewController *viewControllerForView(UIView *view) {
    UIResponder *responder = view;
    while (responder) {
        if ([responder isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)responder;
        }
        responder = [responder nextResponder];
    }
    return nil;
}

static BOOL isFocalContext(UIView *view) {
    if (view) {
        // 1. Walk superview chain for cell/view class containing Focal or Detail
        UIView *temp = view;
        while (temp) {
            NSString *className = NSStringFromClass([temp class]);
            if ([className rangeOfString:@"Focal" options:NSCaseInsensitiveSearch].location != NSNotFound ||
                [className rangeOfString:@"Detail" options:NSCaseInsensitiveSearch].location != NSNotFound) {
                return YES;
            }
            temp = temp.superview;
        }
        
        // 2. Walk responder chain to check owning view controller
        UIViewController *vc = viewControllerForView(view);
        if (vc && isCurrentViewControllerDetails(vc)) {
            return YES;
        }
    }
    
    // 3. Thread local flag set during layout state generation
    NSMutableDictionary *threadDict = [[NSThread currentThread] threadDictionary];
    if ([threadDict[@"WDDIsFocalLayout"] boolValue]) {
        return YES;
    }
    
    // 4. Global active controller fallback
    return isCurrentActiveContextDetail();
}

// MARK: - Hide Translation Banner
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
        if (isFocalContext(nil)) {
            return %orig;
        }
        return NO;
    }
    return %orig;
}
- (void)setTranslatable:(BOOL)translatable {
    if ([WDDManager hideTranslationNotice]) {
        if (isFocalContext(nil)) {
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
        if (isFocalContext(nil)) {
            return %orig;
        }
        return NO;
    }
    return %orig;
}
- (BOOL)shouldBeVisibleForViewModel:(id)viewModel displayType:(long long)displayType {
    if ([WDDManager hideTranslationNotice]) {
        if (isFocalContext(nil)) {
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
        if (isFocalContext(nil)) {
            return %orig;
        }
        return NO;
    }
    return %orig;
}
- (BOOL)shouldBeVisibleForViewModel:(id)viewModel displayType:(long long)displayType {
    if ([WDDManager hideTranslationNotice]) {
        if (isFocalContext(nil)) {
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
        if (isFocalContext(nil)) {
            return %orig;
        }
        return NO;
    }
    return %orig;
}
- (BOOL)shouldBeVisibleForViewModel:(id)viewModel displayType:(long long)displayType {
    if ([WDDManager hideTranslationNotice]) {
        if (isFocalContext(nil)) {
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
        if (isFocalContext(nil)) {
            return %orig;
        }
        return NO;
    }
    return %orig;
}
- (BOOL)shouldBeVisibleForViewModel:(id)viewModel displayType:(long long)displayType {
    if ([WDDManager hideTranslationNotice]) {
        if (isFocalContext(nil)) {
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
        if (!isFocalContext((UIView *)result)) {
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
        if (!isFocalContext((UIView *)result)) {
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
        if (!isFocalContext(view)) {
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
        if (!isFocalContext((UIView *)self)) {
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
    if ([WDDManager hideReplyToIndicator] && isViewModelReply(viewModel)) {
        return NO;
    }
    return %orig;
}
- (BOOL)shouldBeVisibleForViewModel:(id)viewModel displayType:(id)displayType {
    if ([WDDManager hideReplyToIndicator] && isViewModelReply(viewModel)) {
        return NO;
    }
    return %orig;
}
%end

%end

// ==============================
// Settings Page Entry Injection
// ==============================

%hook T1GenericSettingsViewController
- (void)viewWillAppear:(BOOL)arg1 {
    %orig;
    
    // Use associated object to prevent duplicate entries
    if (objc_getAssociatedObject(self, @selector(viewWillAppear:)) != nil) {
        return;
    }
    objc_setAssociatedObject(self, @selector(viewWillAppear:), @YES, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

    TFNItemsDataViewControllerBackingStore *backingStore = self.backingStore;
    NSUInteger sectionCount = [self.sections count];
    if (sectionCount >= 1) {
        TFNSettingsNavigationItem *wddSettings = [[%c(TFNSettingsNavigationItem) alloc] initWithTitle:@"WddTwitter" detail:@"自定义推特过滤与界面调整" iconName:nil controllerFactory:^UIViewController *{
            return [[WDDSettingsViewController alloc] initWithAccount:self.account];
        }];

        // Try setting a gear icon
        UIImage *settingsIcon = [UIImage systemImageNamed:@"gearshape.fill"];
        if (settingsIcon) {
            [wddSettings setValue:settingsIcon forKey:@"_icon"];
        }

        if ([backingStore respondsToSelector:@selector(insertSection:atIndex:)]) {
            [backingStore insertSection:0 atIndex:sectionCount];
        } else {
            [backingStore _tfn_insertSection:0 atIndex:sectionCount];
        }
        
        if ([backingStore respondsToSelector:@selector(insertItem:atIndexPath:)]) {
            [backingStore insertItem:wddSettings atIndexPath:[NSIndexPath indexPathForRow:0 inSection:sectionCount]];
        } else {
            [backingStore _tfn_insertItem:wddSettings atIndexPath:[NSIndexPath indexPathForRow:0 inSection:sectionCount]];
        }
    }
}
%end

%hook T1SettingsViewController
- (void)viewWillAppear:(BOOL)arg1 {
    %orig;
    
    if (objc_getAssociatedObject(self, @selector(viewWillAppear:)) != nil) {
        return;
    }
    objc_setAssociatedObject(self, @selector(viewWillAppear:), @YES, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

    NSUInteger sectionCount = [self.sections count];
    if (sectionCount >= 1) {
        TFNItemsDataViewControllerBackingStore *backingStore = self.backingStore;
        [backingStore insertSection:0 atIndex:sectionCount];
        [backingStore insertItem:@"Row 0" atIndexPath:[NSIndexPath indexPathForRow:0 inSection:sectionCount]];
        [backingStore insertItem:@"Row 1" atIndexPath:[NSIndexPath indexPathForRow:1 inSection:sectionCount]];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger customSectionIndex = [self.sections count] - 1;
    if (indexPath.section == customSectionIndex && indexPath.row == 1) {
        TFNTextCell *tweakCell = [[%c(TFNTextCell) alloc] init];
        [tweakCell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        [tweakCell.textLabel setText:@"WddTwitter"];
        return tweakCell;
    } else if (indexPath.section == customSectionIndex && indexPath.row == 0) {
        TFNTextCell *headerCell = [[%c(TFNTextCell) alloc] init];
        [headerCell setBackgroundColor:[UIColor clearColor]];
        headerCell.textLabel.textColor = [UIColor colorWithRed:0.40 green:0.47 blue:0.53 alpha:1.0];
        [headerCell.textLabel setText:@"王导导定制功能"];
        return headerCell;
    }
    return %orig;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger customSectionIndex = [self.sections count] - 1;
    if (indexPath.section == customSectionIndex && indexPath.row == 1) {
        WDDSettingsViewController *vc = [[WDDSettingsViewController alloc] initWithAccount:self.account];
        [self.navigationController pushViewController:vc animated:YES];
    } else {
        %orig;
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
            NSString *className = NSStringFromClass([subview class]);
            if ([className rangeOfString:@"Avatar" options:NSCaseInsensitiveSearch].location != NSNotFound) {
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

// ==============================
// View Count Hiding Logic
// ==============================

static void swizzleMethod(Class cls, SEL sel, IMP newImp, NSString *origPrefix) {
    if (!cls || !sel || !newImp) return;
    
    BOOL definesMethod = NO;
    unsigned int count = 0;
    Method *methods = class_copyMethodList(cls, &count);
    if (methods) {
        for (unsigned int i = 0; i < count; i++) {
            if (method_getName(methods[i]) == sel) {
                definesMethod = YES;
                break;
            }
        }
        free(methods);
    }
    
    if (!definesMethod) {
        return;
    }
    
    Method method = class_getInstanceMethod(cls, sel);
    if (!method) return;
    
    IMP origImp = method_getImplementation(method);
    const char *types = method_getTypeEncoding(method);
    
    NSString *origSelName = [NSString stringWithFormat:@"%@%@", origPrefix, NSStringFromSelector(sel)];
    origSelName = [origSelName stringByReplacingOccurrencesOfString:@":" withString:@"_"];
    SEL origSel = sel_registerName([origSelName UTF8String]);
    
    class_addMethod(cls, origSel, origImp, types);
    class_replaceMethod(cls, sel, newImp, types);
}

static BOOL custom_isShowViewCountTopRightEnabled(id self, SEL _cmd) {
    if ([WDDManager hideTimelineViewCount]) {
        return NO;
    }
    SEL origSel = sel_registerName("wdd_orig_isShowViewCountTopRightEnabled");
    if ([self respondsToSelector:origSel]) {
        return ((BOOL (*)(id, SEL))objc_msgSend)(self, origSel);
    }
    return NO;
}

static BOOL custom_isViewCountHomeTimelineEnabled(id self, SEL _cmd) {
    if ([WDDManager hideTimelineViewCount]) {
        return NO;
    }
    SEL origSel = sel_registerName("wdd_orig_isViewCountHomeTimelineEnabled");
    if ([self respondsToSelector:origSel]) {
        return ((BOOL (*)(id, SEL))objc_msgSend)(self, origSel);
    }
    return NO;
}

static BOOL custom_shouldShowViewCountFor_viewModel_isKnownFocal(id self, SEL _cmd, id status, id viewModel, BOOL isKnownFocal) {
    if ([WDDManager hideTimelineViewCount]) {
        return NO;
    }
    SEL origSel = sel_registerName("wdd_orig_shouldShowViewCountFor_viewModel_isKnownFocal");
    if ([self respondsToSelector:origSel]) {
        return ((BOOL (*)(id, SEL, id, id, BOOL))objc_msgSend)(self, origSel, status, viewModel, isKnownFocal);
    }
    return NO;
}

static void hookViewCountSelectorsIfNeeded() {
    int numClasses = objc_getClassList(NULL, 0);
    if (numClasses <= 0) return;
    
    Class *classes = (Class *)malloc(sizeof(Class) * numClasses);
    numClasses = objc_getClassList(classes, numClasses);
    
    SEL isShowViewCountTopRightSel = sel_registerName("isShowViewCountTopRightEnabled");
    SEL isViewCountHomeTimelineSel = sel_registerName("isViewCountHomeTimelineEnabled");
    SEL shouldShowViewCountSel = sel_registerName("shouldShowViewCountFor:viewModel:isKnownFocal:");
    
    for (int i = 0; i < numClasses; i++) {
        Class cls = classes[i];
        if (!cls) continue;
        
        swizzleMethod(cls, isShowViewCountTopRightSel, (IMP)custom_isShowViewCountTopRightEnabled, @"wdd_orig_");
        swizzleMethod(cls, isViewCountHomeTimelineSel, (IMP)custom_isViewCountHomeTimelineEnabled, @"wdd_orig_");
        swizzleMethod(cls, shouldShowViewCountSel, (IMP)custom_shouldShowViewCountFor_viewModel_isKnownFocal, @"wdd_orig_");
        
        Class metaCls = object_getClass(cls);
        if (metaCls && metaCls != cls) {
            swizzleMethod(metaCls, isShowViewCountTopRightSel, (IMP)custom_isShowViewCountTopRightEnabled, @"wdd_orig_");
            swizzleMethod(metaCls, isViewCountHomeTimelineSel, (IMP)custom_isViewCountHomeTimelineEnabled, @"wdd_orig_");
            swizzleMethod(metaCls, shouldShowViewCountSel, (IMP)custom_shouldShowViewCountFor_viewModel_isKnownFocal, @"wdd_orig_");
        }
    }
    free(classes);
    NSLog(@"[wddtwitter] Finished dynamic swizzling for view count selectors.");
}

// ==============================
// Disable Long-Press Menu Logic
// ==============================

static BOOL isTargetCellOrStatusView(UIView *view) {
    if (!view) return NO;
    NSString *className = NSStringFromClass([view class]);
    if ([className isEqualToString:@"T1StatusView"] ||
        [className isEqualToString:@"T1StandardStatusView"] ||
        [view isKindOfClass:objc_getClass("UITableViewCell")]) {
        return YES;
    }
    UIView *sup = view.superview;
    if (sup && [sup isKindOfClass:objc_getClass("UITableViewCell")]) {
        return YES;
    }
    return NO;
}

%hook UIView
- (void)addGestureRecognizer:(UIGestureRecognizer *)gesture {
    if ([WDDManager disableLongPressMenu]) {
        if ([gesture isKindOfClass:[UILongPressGestureRecognizer class]]) {
            if (isTargetCellOrStatusView(self)) {
                return;
            }
        }
    }
    %orig(gesture);
}

- (void)addInteraction:(id)interaction {
    if ([WDDManager disableLongPressMenu]) {
        if ([interaction isKindOfClass:objc_getClass("UIContextMenuInteraction")]) {
            if (isTargetCellOrStatusView(self)) {
                return;
            }
        }
    }
    %orig(interaction);
}
%end

%hook TFNDataViewController
- (id)tableView:(id)arg1 contextMenuConfigurationForRowAtIndexPath:(id)arg2 point:(CGPoint)arg3 {
    if ([WDDManager disableLongPressMenu]) {
        return nil;
    }
    return %orig(arg1, arg2, arg3);
}
- (id)collectionView:(id)arg1 contextMenuConfigurationForItemAtIndexPath:(id)arg2 point:(CGPoint)arg3 {
    if ([WDDManager disableLongPressMenu]) {
        return nil;
    }
    return %orig(arg1, arg2, arg3);
}
- (id)collectionView:(id)arg1 contextMenuConfigurationForItemsAtIndexPaths:(id)arg2 point:(CGPoint)arg3 {
    if ([WDDManager disableLongPressMenu]) {
        return nil;
    }
    return %orig(arg1, arg2, arg3);
}
%end

%hook TFNItemsDataViewController
- (id)tableView:(id)arg1 contextMenuConfigurationForRowAtIndexPath:(id)arg2 point:(CGPoint)arg3 {
    if ([WDDManager disableLongPressMenu]) {
        return nil;
    }
    return %orig(arg1, arg2, arg3);
}
- (id)collectionView:(id)arg1 contextMenuConfigurationForItemAtIndexPath:(id)arg2 point:(CGPoint)arg3 {
    if ([WDDManager disableLongPressMenu]) {
        return nil;
    }
    return %orig(arg1, arg2, arg3);
}
- (id)collectionView:(id)arg1 contextMenuConfigurationForItemsAtIndexPaths:(id)arg2 point:(CGPoint)arg3 {
    if ([WDDManager disableLongPressMenu]) {
        return nil;
    }
    return %orig(arg1, arg2, arg3);
}
- (void)cellLongPressWithGesture:(id)arg1 {
    if ([WDDManager disableLongPressMenu]) return;
    %orig(arg1);
}
- (void)cellLongPressPreviewWithGesture:(id)arg1 {
    if ([WDDManager disableLongPressMenu]) return;
    %orig(arg1);
}
- (void)cellLongPressRecordWithGesture:(id)arg1 {
    if ([WDDManager disableLongPressMenu]) return;
    %orig(arg1);
}
%end

%ctor {
    NSLog(@"[wddtwitter] WDDTweak.x constructor loaded!");
    %init;
    %init(TimelineTranslation);
    hookViewCountSelectorsIfNeeded();
}



