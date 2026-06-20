#import "WDDManager.h"
#import "TWHeaders.h"
#import <objc/runtime.h>
#import <objc/message.h>

// ==============================
// Keyword Filtering Logic
// ==============================

static BOOL shouldHideTweetByKeywords(id item) {
    id status = item;
    if ([item respondsToSelector:@selector(status)]) {
        status = ((id (*)(id, SEL))objc_msgSend)(item, @selector(status));
    }
    
    if (!status) return NO;
    
    // Check cache validity against current settings version
    static char kWDDTweetHideCacheKey;
    static char kWDDTweetHideVersionKey;
    
    NSInteger currentVersion = [WDDManager filterConfigVersion];
    NSNumber *cachedResult = objc_getAssociatedObject(status, &kWDDTweetHideCacheKey);
    NSNumber *cachedVersion = objc_getAssociatedObject(status, &kWDDTweetHideVersionKey);
    
    if (cachedResult != nil && cachedVersion != nil && [cachedVersion integerValue] == currentVersion) {
        return [cachedResult boolValue];
    }
    
    BOOL shouldHide = NO;
    if ([status respondsToSelector:@selector(isReply)]) {
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
                            shouldHide = YES;
                        } else {
                            // If no Chinese and <= 3 emojis, check for letters/numbers
                            NSUInteger alphaNumCount = [alphaNumRegex numberOfMatchesInString:text options:0 range:NSMakeRange(0, text.length)];
                            if (alphaNumCount == 0) {
                                // No Chinese and No AlphaNumeric -> Pure Emoji/Symbols/Spam
                                shouldHide = YES;
                            }
                        }
                    }
                }

                // 1.5 Custom Regex Filter Logic
                if (!shouldHide && [WDDManager enableRegexFilter]) {
                    NSString *regexesStr = [WDDManager replyRegexes];
                    if (regexesStr != nil && regexesStr.length > 0) {
                        static NSString *cachedRegexesStr = nil;
                        static NSArray<NSRegularExpression *> *cachedRegexObjects = nil;
                        static NSObject *lockObj = nil;
                        static dispatch_once_t onceTokenLock;
                        dispatch_once(&onceTokenLock, ^{
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
                                shouldHide = YES;
                                break;
                            }
                        }
                    }
                }

                // 2. Keyword Filter Logic
                if (!shouldHide && [WDDManager enableReplyFilter]) {
                    NSString *keywordsStr = [WDDManager replyKeywords];
                    if (keywordsStr != nil && keywordsStr.length > 0) {
                        // Support both English and Chinese commas
                        NSArray *keywords = [keywordsStr componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@",，"]];
                        int totalMatches = 0;
                        for (NSString *keyword in keywords) {
                            NSString *trimmed = [keyword stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                            if (trimmed.length > 0 && [text rangeOfString:trimmed options:NSCaseInsensitiveSearch].location != NSNotFound) {
                                totalMatches++;
                                break;
                            }
                        }
                        // Match if any keyword is found
                        if (totalMatches > 0) {
                            shouldHide = YES;
                        }
                    }
                }
            }
        }
    }
    
    // Save to cache
    objc_setAssociatedObject(status, &kWDDTweetHideCacheKey, @(shouldHide), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(status, &kWDDTweetHideVersionKey, @(currentVersion), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    return shouldHide;
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
