//
//  WDDManager.m
//  wddtwitter
//

#import "WDDManager.h"

// ==============================
// Plist-based settings persistence
// Bypasses NSUserDefaults entirely for maximum reliability
// ==============================

// ⚠️ 临时测试开关：忽略已存配置，强制开启若干视觉特征明显的功能。
// 用途：设置页入口失效时验证 tweak 是否加载、hook 是否生效。
// 验证完成后请改回 0。
#define WDD_FORCE_TEST_DEFAULTS 0

static NSDictionary *WDDTestForcedDefaults(void) {
    static NSDictionary *table = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        table = @{
            @"hide_blue_verified"            : @YES,   // 去蓝标
            @"wdd_hide_timeline_view_count"  : @YES,   // 隐藏时间线浏览量
            @"wdd_hide_translation_notice"   : @YES,   // 隐藏翻译提示
            @"wdd_hide_grok_buttons"         : @YES,   // 隐藏 Grok 按钮
        };
    });
    return table;
}

static NSString *_prefsPath = nil;
static NSMutableDictionary *_prefsCache = nil;
static NSInteger _filterConfigVersion = 0;
static BOOL _lastEnableReply;
static BOOL _lastEnableEmoji;
static BOOL _lastEnableRegex;
static NSString *_lastKeywords;
static NSString *_lastRegexes;

// ---------------------------------------------------------------
// 热点开关缓存
//
// hideTimelineImages / enableSingleImageSizing 这两个开关在布局、setFrame:、
// sizeThatFits:、intrinsicContentSize 等超热路径里被读取，一秒可能几千次。
// 每次都走「字符串键查 NSMutableDictionary」纯属浪费，这里缓存成两个静态 BOOL，
// 只在配置真正变化时刷新。语义与 boolForKey: 完全一致。
// ---------------------------------------------------------------
static BOOL _hotCacheHideTimelineImages = NO;
static BOOL _hotCacheHideAllMedia = NO;
static BOOL _hotCacheEnableSingleImageSizing = NO;

static void WDDRefreshHotCache(void) {
    _hotCacheHideTimelineImages = [_prefsCache[@"wdd_hide_timeline_images"] boolValue];
    _hotCacheHideAllMedia = [_prefsCache[@"wdd_hide_all_media"] boolValue];
    _hotCacheEnableSingleImageSizing = [_prefsCache[@"wdd_enable_single_image_sizing"] boolValue];
}

static void WDDEnsurePrefs(void) {
    if (_prefsPath) return;
    
    NSString *libDir = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) firstObject];
    _prefsPath = [libDir stringByAppendingPathComponent:@"WDDTwitterPrefs.plist"];
    
    NSDictionary *onDisk = [NSDictionary dictionaryWithContentsOfFile:_prefsPath];
    if (onDisk) {
        _prefsCache = [onDisk mutableCopy];
    } else {
        _prefsCache = [NSMutableDictionary new];
        
        // One-time migration from NSUserDefaults (standardUserDefaults)
        NSUserDefaults *oldDefaults = [NSUserDefaults standardUserDefaults];
        NSArray *boolKeys = @[
            @"hide_author_name", @"hide_avatar", @"hide_blue_verified",
            @"wdd_hide_translation_notice", @"wdd_hide_grok_buttons",
            @"wdd_hide_reply_to_indicator", @"wdd_enable_single_image_sizing",
            @"wdd_hide_account_labels", @"wdd_hide_disclosure_labels",
            @"wdd_hide_timeline_view_count", @"wdd_disable_long_press_menu",
            @"wdd_hide_timeline_images",
            @"wdd_hide_all_media",
            @"enable_reply_filter", @"enable_emoji_filter", @"enable_regex_filter"
        ];
        NSArray *stringKeys = @[@"reply_keywords", @"reply_regexes"];
        
        for (NSString *key in boolKeys) {
            if ([oldDefaults objectForKey:key] != nil) {
                _prefsCache[key] = @([oldDefaults boolForKey:key]);
            }
        }
        for (NSString *key in stringKeys) {
            NSString *val = [oldDefaults stringForKey:key];
            if (val) {
                _prefsCache[key] = val;
            }
        }
        
        // Also try migration from suite-based defaults (previous fix attempt)
        NSUserDefaults *suiteDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"com.wangdaodao.wddtwitter"];
        for (NSString *key in boolKeys) {
            if ([suiteDefaults objectForKey:key] != nil && _prefsCache[key] == nil) {
                _prefsCache[key] = @([suiteDefaults boolForKey:key]);
            }
        }
        for (NSString *key in stringKeys) {
            NSString *val = [suiteDefaults stringForKey:key];
            if (val && _prefsCache[key] == nil) {
                _prefsCache[key] = val;
            }
        }
        
        [_prefsCache writeToFile:_prefsPath atomically:YES];
    }
    WDDRefreshHotCache();
}

static void WDDSavePrefs(void) {
    [_prefsCache writeToFile:_prefsPath atomically:YES];
}

@implementation WDDManager

+ (void)initialize {
    if (self == [WDDManager class]) {
        WDDEnsurePrefs();
        [self updateFilterVersion];
    }
}

+ (void)updateFilterVersion {
    BOOL newEnableReply = [self boolForKey:@"enable_reply_filter"];
    BOOL newEnableEmoji = [self boolForKey:@"enable_emoji_filter"];
    BOOL newEnableRegex = [self boolForKey:@"enable_regex_filter"];
    NSString *newKeywords = [self stringForKey:@"reply_keywords"];
    NSString *newRegexes = [self stringForKey:@"reply_regexes"];
    
    if (_lastEnableReply != newEnableReply ||
        _lastEnableEmoji != newEnableEmoji ||
        _lastEnableRegex != newEnableRegex ||
        ![_lastKeywords isEqualToString:newKeywords ?: @""] ||
        ![_lastRegexes isEqualToString:newRegexes ?: @""]) {
        _filterConfigVersion++;
    }
    
    _lastEnableReply = newEnableReply;
    _lastEnableEmoji = newEnableEmoji;
    _lastEnableRegex = newEnableRegex;
    _lastKeywords = [newKeywords copy] ?: @"";
    _lastRegexes = [newRegexes copy] ?: @"";
}

// ==============================
// Generic accessors
// ==============================

+ (BOOL)boolForKey:(NSString *)key {
    WDDEnsurePrefs();
#if WDD_FORCE_TEST_DEFAULTS
    NSNumber *forced = WDDTestForcedDefaults()[key];
    if (forced) {
        return YES;
    }
#endif
    return [_prefsCache[key] boolValue];
}

+ (NSString *)stringForKey:(NSString *)key {
    WDDEnsurePrefs();
    id val = _prefsCache[key];
    return [val isKindOfClass:[NSString class]] ? val : nil;
}

+ (void)setBool:(BOOL)value forKey:(NSString *)key {
    WDDEnsurePrefs();
    _prefsCache[key] = @(value);
    WDDSavePrefs();
    WDDRefreshHotCache();
    [self updateFilterVersion];
}

+ (void)setString:(NSString *)value forKey:(NSString *)key {
    WDDEnsurePrefs();
    if (value) {
        _prefsCache[key] = value;
    } else {
        [_prefsCache removeObjectForKey:key];
    }
    WDDSavePrefs();
    WDDRefreshHotCache();
    [self updateFilterVersion];
}

+ (void)removeObjectForKey:(NSString *)key {
    WDDEnsurePrefs();
    [_prefsCache removeObjectForKey:key];
    WDDSavePrefs();
    WDDRefreshHotCache();
}

// ==============================
// Convenience getters
// ==============================

+ (NSInteger)filterConfigVersion {
    return _filterConfigVersion;
}

+ (BOOL)hideAuthorName {
    return [self boolForKey:@"hide_author_name"];
}

+ (BOOL)hideAvatar {
    return [self boolForKey:@"hide_avatar"];
}

+ (BOOL)hideBlueVerified {
    return [self boolForKey:@"hide_blue_verified"];
}

+ (BOOL)hideTranslationNotice {
    return [self boolForKey:@"wdd_hide_translation_notice"];
}

+ (BOOL)hideReplyToIndicator {
    return [self boolForKey:@"wdd_hide_reply_to_indicator"];
}

+ (BOOL)enableReplyFilter {
    return [self boolForKey:@"enable_reply_filter"];
}

+ (NSString *)replyKeywords {
    return [self stringForKey:@"reply_keywords"];
}

+ (BOOL)enableEmojiFilter {
    return [self boolForKey:@"enable_emoji_filter"];
}

+ (BOOL)enableRegexFilter {
    return [self boolForKey:@"enable_regex_filter"];
}

+ (NSString *)replyRegexes {
    return [self stringForKey:@"reply_regexes"];
}

+ (BOOL)enableSingleImageSizing {
    // 热点路径：直接读缓存，不再做字符串键字典查找
    WDDEnsurePrefs();
    return _hotCacheEnableSingleImageSizing;
}

+ (BOOL)hideAccountLabels {
    return [self boolForKey:@"wdd_hide_account_labels"];
}

+ (BOOL)hideDisclosureLabels {
    return [self boolForKey:@"wdd_hide_disclosure_labels"];
}

+ (BOOL)hideTimelineViewCount {
    return [self boolForKey:@"wdd_hide_timeline_view_count"];
}

+ (BOOL)disableLongPressMenu {
    return [self boolForKey:@"wdd_disable_long_press_menu"];
}

+ (BOOL)hideGrokButtons {
    return [self boolForKey:@"wdd_hide_grok_buttons"];
}

+ (BOOL)hideTimelineImages {
    // 热点路径：直接读缓存，不再做字符串键字典查找
    WDDEnsurePrefs();
    return _hotCacheHideTimelineImages;
}

+ (BOOL)hideAllMedia {
    WDDEnsurePrefs();
    return _hotCacheHideAllMedia;
}

@end
