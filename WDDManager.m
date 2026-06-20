//
//  WDDManager.m
//  wddtwitter
//

#import "WDDManager.h"

static NSInteger _filterConfigVersion = 0;

static BOOL _hideAuthorName;
static BOOL _hideAvatar;
static BOOL _hideBlueVerified;
static BOOL _hideTranslationNotice;
static BOOL _hideReplyToIndicator;
static BOOL _enableReplyFilter;
static NSString *_replyKeywords;
static BOOL _enableEmojiFilter;
static BOOL _enableRegexFilter;
static NSString *_replyRegexes;
static BOOL _enableSingleImageSizing;
static BOOL _hideAccountLabels;
static BOOL _hideDisclosureLabels;
static BOOL _hideTimelineViewCount;
static BOOL _disableLongPressMenu;
static BOOL _hideGrokButtons;

@implementation WDDManager

+ (void)initialize {
    if (self == [WDDManager class]) {
        [self reloadSettingsCache];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(reloadSettingsCache)
                                                     name:NSUserDefaultsDidChangeNotification
                                                   object:nil];
    }
}

+ (void)reloadSettingsCache {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    BOOL newEnableReply = [defaults boolForKey:@"enable_reply_filter"];
    BOOL newEnableEmoji = [defaults boolForKey:@"enable_emoji_filter"];
    BOOL newEnableRegex = [defaults boolForKey:@"enable_regex_filter"];
    NSString *newKeywords = [defaults stringForKey:@"reply_keywords"];
    NSString *newRegexes = [defaults stringForKey:@"reply_regexes"];
    
    // Invalidate caches if any filter criteria change
    if (_enableReplyFilter != newEnableReply ||
        _enableEmojiFilter != newEnableEmoji ||
        _enableRegexFilter != newEnableRegex ||
        ![_replyKeywords isEqualToString:newKeywords] ||
        ![_replyRegexes isEqualToString:newRegexes]) {
        _filterConfigVersion++;
    }
    
    _hideAuthorName = [defaults boolForKey:@"hide_author_name"];
    _hideAvatar = [defaults boolForKey:@"hide_avatar"];
    _hideBlueVerified = [defaults boolForKey:@"hide_blue_verified"];
    _hideTranslationNotice = [defaults boolForKey:@"wdd_hide_translation_notice"];
    _hideReplyToIndicator = [defaults boolForKey:@"wdd_hide_reply_to_indicator"];
    _enableReplyFilter = newEnableReply;
    _replyKeywords = [newKeywords copy];
    _enableEmojiFilter = newEnableEmoji;
    _enableRegexFilter = newEnableRegex;
    _replyRegexes = [newRegexes copy];
    _enableSingleImageSizing = [defaults boolForKey:@"wdd_enable_single_image_sizing"];
    _hideAccountLabels = [defaults boolForKey:@"wdd_hide_account_labels"];
    _hideDisclosureLabels = [defaults boolForKey:@"wdd_hide_disclosure_labels"];
    _hideTimelineViewCount = [defaults boolForKey:@"wdd_hide_timeline_view_count"];
    _disableLongPressMenu = [defaults boolForKey:@"wdd_disable_long_press_menu"];
    _hideGrokButtons = [defaults boolForKey:@"wdd_hide_grok_buttons"];
}

+ (NSInteger)filterConfigVersion {
    return _filterConfigVersion;
}

+ (BOOL)hideAuthorName {
    return _hideAuthorName;
}

+ (BOOL)hideAvatar {
    return _hideAvatar;
}

+ (BOOL)hideBlueVerified {
    return _hideBlueVerified;
}

+ (BOOL)hideTranslationNotice {
    return _hideTranslationNotice;
}

+ (BOOL)hideReplyToIndicator {
    return _hideReplyToIndicator;
}

+ (BOOL)enableReplyFilter {
    return _enableReplyFilter;
}

+ (NSString *)replyKeywords {
    return _replyKeywords;
}

+ (BOOL)enableEmojiFilter {
    return _enableEmojiFilter;
}

+ (BOOL)enableRegexFilter {
    return _enableRegexFilter;
}

+ (NSString *)replyRegexes {
    return _replyRegexes;
}

+ (BOOL)enableSingleImageSizing {
    return _enableSingleImageSizing;
}

+ (BOOL)hideAccountLabels {
    return _hideAccountLabels;
}

+ (BOOL)hideDisclosureLabels {
    return _hideDisclosureLabels;
}

+ (BOOL)hideTimelineViewCount {
    return _hideTimelineViewCount;
}

+ (BOOL)disableLongPressMenu {
    return _disableLongPressMenu;
}

+ (BOOL)hideGrokButtons {
    return _hideGrokButtons;
}

@end
