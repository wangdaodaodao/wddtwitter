#import "WDDManager.h"
#import "WDDUtils.h"
#import "TWHeaders.h"
#import "WDDLayoutShared.h"

%hook T1CompositionStatusViewModel
- (BOOL)isFromUserVerified {
    return [WDDManager hideBlueVerified] ? NO : %orig;
}
- (BOOL)isFromUserBlueVerified {
    return [WDDManager hideBlueVerified] ? NO : %orig;
}
- (BOOL)hasMedia {
    if (WDDShouldHideTimelineMedia(nil)) {
        return NO;
    }
    return ([WDDManager enableSingleImageSizing] && g_isCalculatingQuotedLayout) ? NO : %orig;
}
- (NSArray *)inlineMediaInfos {
    if (WDDShouldHideTimelineMedia(nil)) {
        return @[];
    }
    return ([WDDManager enableSingleImageSizing] && g_isCalculatingQuotedLayout) ? @[] : %orig;
}
- (NSArray *)representedMediaEntities {
    if (WDDShouldHideTimelineMedia(nil)) {
        return @[];
    }
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
- (BOOL)hasMedia {
    if (WDDShouldHideTimelineMedia(nil)) {
        return NO;
    }
    return ([WDDManager enableSingleImageSizing] && g_isCalculatingQuotedLayout) ? NO : %orig;
}
- (NSArray *)inlineMediaInfos {
    if (WDDShouldHideTimelineMedia(nil)) {
        return @[];
    }
    return ([WDDManager enableSingleImageSizing] && g_isCalculatingQuotedLayout) ? @[] : %orig;
}
- (NSArray *)representedMediaEntities {
    if (WDDShouldHideTimelineMedia(nil)) {
        return @[];
    }
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
- (BOOL)isFromUserVerified {
    return [WDDManager hideBlueVerified] ? NO : %orig;
}
- (BOOL)isFromUserBlueVerified {
    return [WDDManager hideBlueVerified] ? NO : %orig;
}
- (BOOL)hasMedia {
    if (WDDShouldHideTimelineMedia(nil)) {
        return NO;
    }
    return ([WDDManager enableSingleImageSizing] && g_isCalculatingQuotedLayout) ? NO : %orig;
}
- (NSArray *)inlineMediaInfos {
    if (WDDShouldHideTimelineMedia(nil)) {
        return @[];
    }
    return ([WDDManager enableSingleImageSizing] && g_isCalculatingQuotedLayout) ? @[] : %orig;
}
- (NSArray *)representedMediaEntities {
    if (WDDShouldHideTimelineMedia(nil)) {
        return @[];
    }
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
    if (WDDShouldHideTimelineMedia(nil)) {
        return NO;
    }
    return ([WDDManager enableSingleImageSizing] && g_isCalculatingQuotedLayout) ? NO : %orig;
}
- (NSArray *)inlineMediaInfos {
    if (WDDShouldHideTimelineMedia(nil)) {
        return @[];
    }
    return ([WDDManager enableSingleImageSizing] && g_isCalculatingQuotedLayout) ? @[] : %orig;
}
- (NSArray *)representedMediaEntities {
    if (WDDShouldHideTimelineMedia(nil)) {
        return @[];
    }
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

%hook TTACoreStatusViewModelURT
- (BOOL)hasMedia {
    if (WDDShouldHideTimelineMedia(nil)) {
        return NO;
    }
    return ([WDDManager enableSingleImageSizing] && g_isCalculatingQuotedLayout) ? NO : %orig;
}
- (NSArray *)inlineMediaInfos {
    if (WDDShouldHideTimelineMedia(nil)) {
        return @[];
    }
    return ([WDDManager enableSingleImageSizing] && g_isCalculatingQuotedLayout) ? @[] : %orig;
}
- (NSArray *)representedMediaEntities {
    if (WDDShouldHideTimelineMedia(nil)) {
        return @[];
    }
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

%hook TwitterCoreStatusViewModelAdapter
- (BOOL)hasMedia {
    if (WDDShouldHideTimelineMedia(nil)) {
        return NO;
    }
    return ([WDDManager enableSingleImageSizing] && g_isCalculatingQuotedLayout) ? NO : %orig;
}
- (NSArray *)inlineMediaInfos {
    if (WDDShouldHideTimelineMedia(nil)) {
        return @[];
    }
    return ([WDDManager enableSingleImageSizing] && g_isCalculatingQuotedLayout) ? @[] : %orig;
}
- (NSArray *)representedMediaEntities {
    if (WDDShouldHideTimelineMedia(nil)) {
        return @[];
    }
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

%hook T1StandardStatusAffiliateBadgeViewAdapter
- (BOOL)shouldBeVisibleForViewModel:(id)viewModel {
    if ([WDDManager hideAccountLabels]) return NO;
    return %orig;
}
%end

%ctor {
    %init;
}
