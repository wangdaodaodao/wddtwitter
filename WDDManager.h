//
//  WDDManager.h
//  wddtwitter
//

#import <Foundation/Foundation.h>

@interface WDDManager : NSObject
+ (BOOL)boolForKey:(NSString *)key;
+ (NSString *)stringForKey:(NSString *)key;
+ (void)setBool:(BOOL)value forKey:(NSString *)key;
+ (void)setString:(NSString *)value forKey:(NSString *)key;
+ (void)removeObjectForKey:(NSString *)key;
+ (BOOL)hideAuthorName;
+ (BOOL)hideAvatar;
+ (BOOL)hideBlueVerified;
+ (BOOL)hideTranslationNotice;
+ (BOOL)hideReplyToIndicator;
+ (BOOL)enableReplyFilter;
+ (NSString *)replyKeywords;
+ (BOOL)enableEmojiFilter;
+ (BOOL)enableRegexFilter;
+ (NSString *)replyRegexes;
+ (BOOL)enableSingleImageSizing;
+ (BOOL)hideAccountLabels;
+ (BOOL)hideDisclosureLabels;
+ (BOOL)hideTimelineViewCount;
+ (BOOL)disableLongPressMenu;
+ (BOOL)hideGrokButtons;
+ (BOOL)hideTimelineImages;
+ (NSInteger)filterConfigVersion;
@end
