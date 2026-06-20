//
//  WDDManager.h
//  wddtwitter
//

#import <Foundation/Foundation.h>

@interface WDDManager : NSObject
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
@end
