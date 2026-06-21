#import "WDDManager.h"
#import <objc/runtime.h>

// ==============================
// View Count Hiding Logic
// ==============================

// 静态 Hook T1GraphQLFeatures (控制时间线浏览量是否请求及显示)
%hook T1GraphQLFeatures

- (BOOL)isViewCountHomeTimelineEnabled {
    if ([WDDManager hideTimelineViewCount]) {
        return NO;
    }
    return %orig;
}

%end

// 静态 Hook TPSTwitterFeatureSwitches (从根源上禁用浏览量 Feature Switches)
%hook TPSTwitterFeatureSwitches

- (BOOL)boolForKey:(NSString *)key {
    if ([WDDManager hideTimelineViewCount]) {
        if ([key isEqualToString:@"view_counts_public_visibility_enabled"] ||
            [key isEqualToString:@"view_counts_everywhere_api_enabled"] ||
            [key isEqualToString:@"view_counts_author_visibility_enabled"] ||
            [key isEqualToString:@"isViewCountsAPIEnabled"] ||
            [key isEqualToString:@"shouldRequestViewCountsThroughAllFeatureSwitchGatedAPIs"] ||
            [key isEqualToString:@"ios_show_inline_actions_show_view_count_top_right_enabled"]) {
            return NO;
        }
    }
    return %orig;
}

%end
