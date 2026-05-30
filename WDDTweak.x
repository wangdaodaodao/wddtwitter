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
                    // Check for Chinese characters
                    NSRegularExpression *chineseRegex = [NSRegularExpression regularExpressionWithPattern:@"[\\u4e00-\\u9fa5]" options:0 error:NULL];
                    NSUInteger chineseCount = [chineseRegex numberOfMatchesInString:text options:0 range:NSMakeRange(0, text.length)];
                    
                    if (chineseCount == 0) {
                        // Check if it has more than 3 emojis
                        NSRegularExpression *emojiRegex = [NSRegularExpression regularExpressionWithPattern:@"\\p{Emoji_Presentation}|\\p{Emoji}\\uFE0F" options:0 error:NULL];
                        NSUInteger emojiCount = [emojiRegex numberOfMatchesInString:text options:0 range:NSMakeRange(0, text.length)];
                        if (emojiCount > 3) {
                            return YES;
                        }
                        
                        // If no Chinese and <= 3 emojis, check for letters/numbers
                        NSRegularExpression *alphaNumRegex = [NSRegularExpression regularExpressionWithPattern:@"[a-zA-Z0-9]" options:0 error:NULL];
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
                        NSArray *lines = [regexesStr componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
                        for (NSString *line in lines) {
                            NSString *pattern = [line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                            if (pattern.length > 0) {
                                NSError *error = nil;
                                NSRegularExpression *customRegex = [NSRegularExpression regularExpressionWithPattern:pattern
                                                                                                             options:NSRegularExpressionDotMatchesLineSeparators
                                                                                                               error:&error];
                                if (!error && customRegex != nil) {
                                    NSUInteger matchCount = [customRegex numberOfMatchesInString:text options:0 range:NSMakeRange(0, text.length)];
                                    if (matchCount > 0) {
                                        return YES;
                                    }
                                }
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

%hook T1StatusView
- (void)setFrame:(CGRect)frame {
    if ([WDDManager hideAvatar]) {
        frame.size.width = [UIScreen mainScreen].bounds.size.width;
    }
    %orig(frame);
}

- (void)layoutSubviews {
    %orig;
    if ([WDDManager hideReplyToIndicator]) {
        id viewModel = nil;
        if ([(id)self respondsToSelector:@selector(viewModel)]) {
            viewModel = [(id)self viewModel];
        }
        for (UIView *subview in ((UIView *)self).subviews) {
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
        for (UIView *subview in ((UIView *)self).subviews) {
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
                    f.size.width = ((UIView *)self).bounds.size.width - (margin * 2);
                    subview.frame = f;
                    [((UIView *)self) bringSubviewToFront:subview];
                }
            }
        }
    }
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
    if ([WDDManager hideReplyToIndicator]) {
        id viewModel = nil;
        if ([(id)self respondsToSelector:@selector(viewModel)]) {
            viewModel = [(id)self viewModel];
        }
        for (UIView *subview in ((UIView *)self).subviews) {
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
        for (UIView *subview in ((UIView *)self).subviews) {
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
                    f.size.width = ((UIView *)self).bounds.size.width - (margin * 2);
                    subview.frame = f;
                    [((UIView *)self) bringSubviewToFront:subview];
                }
            }
        }
    }
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

// MARK: - Hide Translation Banner
%group TimelineTranslation

%hook T1StandardStatusTranslateLayoutState
- (BOOL)isTranslatable {
    return [WDDManager hideTranslationNotice] ? NO : %orig;
}
- (void)setTranslatable:(BOOL)translatable {
    %orig([WDDManager hideTranslationNotice] ? NO : translatable);
}
%end

%hook T1StandardStatusTranslateAdapter
- (BOOL)shouldBeVisibleForViewModel:(id)viewModel {
    return [WDDManager hideTranslationNotice] ? NO : %orig;
}
- (BOOL)shouldBeVisibleForViewModel:(id)viewModel displayType:(id)displayType {
    return [WDDManager hideTranslationNotice] ? NO : %orig;
}
%end

%hook T1StandardStatusGrokTranslateButtonViewAdapter
- (BOOL)shouldBeVisibleForViewModel:(id)viewModel {
    return [WDDManager hideTranslationNotice] ? NO : %orig;
}
- (BOOL)shouldBeVisibleForViewModel:(id)viewModel displayType:(id)displayType {
    return [WDDManager hideTranslationNotice] ? NO : %orig;
}
%end

%hook T1StandardStatusGrokAutoTranslateAnnotationViewAdapter
- (BOOL)shouldBeVisibleForViewModel:(id)viewModel {
    return [WDDManager hideTranslationNotice] ? NO : %orig;
}
- (BOOL)shouldBeVisibleForViewModel:(id)viewModel displayType:(id)displayType {
    return [WDDManager hideTranslationNotice] ? NO : %orig;
}
%end

%hook T1StandardStatusGrokAutoTranslateToggleViewAdapter
- (BOOL)shouldBeVisibleForViewModel:(id)viewModel {
    return [WDDManager hideTranslationNotice] ? NO : %orig;
}
- (BOOL)shouldBeVisibleForViewModel:(id)viewModel displayType:(id)displayType {
    return [WDDManager hideTranslationNotice] ? NO : %orig;
}
%end

%hook T1StandardStatusTranslateView
- (id)initWithFrame:(CGRect)frame {
    id result = %orig(frame);
    if (result && [WDDManager hideTranslationNotice]) {
        UIView *view = (UIView *)result;
        view.hidden = YES;
        view.alpha = 0.0;
    }
    return result;
}

- (id)init {
    id result = %orig;
    if (result && [WDDManager hideTranslationNotice]) {
        UIView *view = (UIView *)result;
        view.hidden = YES;
        view.alpha = 0.0;
    }
    return result;
}

- (void)layoutSubviews {
    %orig;
    if ([WDDManager hideTranslationNotice]) {
        UIView *view = (UIView *)self;
        view.hidden = YES;
        view.alpha = 0.0;
    }
}

- (CGSize)sizeThatFits:(CGSize)size {
    if ([WDDManager hideTranslationNotice]) {
        return CGSizeZero;
    }
    return %orig;
}
%end

%hook T1StandardStatusGrokTranslationFeedbackViewAdapter
- (BOOL)shouldBeVisibleForViewModel:(id)viewModel {
    return [WDDManager hideTranslationNotice] ? NO : %orig;
}
- (BOOL)shouldBeVisibleForViewModel:(id)viewModel displayType:(id)displayType {
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
        TFNSettingsNavigationItem *wddSettings = [[%c(TFNSettingsNavigationItem) alloc] initWithTitle:@"王导导增强设置" detail:@"自定义推特过滤与界面调整" iconName:nil controllerFactory:^UIViewController *{
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
        [tweakCell.textLabel setText:@"王导导增强设置"];
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

%ctor {
    NSLog(@"[wddtwitter] WDDTweak.x constructor loaded!");
    %init;
    %init(TimelineTranslation);
}


