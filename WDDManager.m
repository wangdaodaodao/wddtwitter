//
//  WDDManager.m
//  wddtwitter
//

#import "WDDManager.h"

@implementation WDDManager

+ (BOOL)hideAuthorName {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"hide_author_name"];
}

+ (BOOL)hideAvatar {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"hide_avatar"];
}

+ (BOOL)hideBlueVerified {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"hide_blue_verified"];
}

+ (BOOL)hideTranslationNotice {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"wdd_hide_translation_notice"];
}

+ (BOOL)hideReplyToIndicator {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"wdd_hide_reply_to_indicator"];
}

+ (BOOL)enableReplyFilter {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"enable_reply_filter"];
}

+ (NSString *)replyKeywords {
    return [[NSUserDefaults standardUserDefaults] stringForKey:@"reply_keywords"];
}

+ (BOOL)enableEmojiFilter {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"enable_emoji_filter"];
}

+ (BOOL)enableRegexFilter {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"enable_regex_filter"];
}

+ (NSString *)replyRegexes {
    return [[NSUserDefaults standardUserDefaults] stringForKey:@"reply_regexes"];
}

@end
