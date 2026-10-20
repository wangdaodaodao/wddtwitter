#import "WDDManager.h"
#import "WDDUtils.h"
#import "TWHeaders.h"
#import "WDDLayoutShared.h"

static void WDDHideShowMoreConnector(UIView *host, NSString *key) {
    if (!host || key.length == 0) return;
    id target = nil;
    @try {
        target = [host valueForKey:key];
    } @catch (__unused NSException *e) {
        target = nil;
    }
    if (![target isKindOfClass:[UIView class]]) return;
    UIView *view = (UIView *)target;
    view.hidden = YES;
    view.alpha = 0.0;
}

static BOOL WDDIsConnectorDecorView(UIView *view) {
    if (!view) return NO;
    NSString *name = NSStringFromClass([view class]);
    if ([name rangeOfString:@"Connector"].location != NSNotFound) return YES;
    if ([name rangeOfString:@"Ellipsis"].location != NSNotFound) return YES;
    return NO;
}

static void WDDCollectLabels(UIView *view, NSMutableArray *labels, NSInteger depth) {
    if (!view || depth > 3) return;
    for (UIView *subview in view.subviews) {
        if ([subview isKindOfClass:[UILabel class]]) {
            [labels addObject:subview];
        }
        if (subview.subviews.count > 0) {
            WDDCollectLabels(subview, labels, depth + 1);
        }
    }
}

static void WDDTidyShowMoreCellLayout(UITableViewCell *cell) {
    if (!cell) return;

    WDDHideShowMoreConnector(cell, @"connectorTopView");
    WDDHideShowMoreConnector(cell, @"connectorEllipsisView");
    WDDHideShowMoreConnector(cell, @"connectorBottomView");

    CGFloat width = cell.bounds.size.width - 24.0;
    if (width <= 0) return;

    NSMutableArray *labels = [NSMutableArray array];
    WDDCollectLabels(cell, labels, 0);

    for (UIView *subview in cell.subviews) {
        if (WDDIsConnectorDecorView(subview)) {
            subview.hidden = YES;
            subview.alpha = 0.0;
        }
    }

    for (UILabel *label in labels) {
        if (label.text.length == 0) continue;
        CGRect frame = label.frame;
        frame.origin.x = 12.0;
        frame.size.width = width;
        if (frame.origin.y > 12.0) {
            frame.origin.y = 6.0;
        }
        label.frame = frame;
        label.textAlignment = NSTextAlignmentLeft;
    }
}

%hook T1ConversationShowMoreCell
- (void)layoutSubviews {
    %orig;
    if ([WDDManager hideAvatar]) {
        WDDTidyShowMoreCellLayout((UITableViewCell *)self);
    }
}
%end

%hook TFNTextCell
+ (CGFloat)heightForStyle:(long long)style text:(id)text multipleLines:(BOOL)multipleLines detailText:(id)detailText multipleLines:(BOOL)detailMultipleLines tableWidth:(CGFloat)tableWidth contentEdgeInsets:(UIEdgeInsets)contentEdgeInsets {
    if (WDDShouldHideProbableSpam() && (WDDIsProbableSpamText(text) || WDDIsProbableSpamText(detailText))) {
        return 0.0;
    }
    return %orig;
}

+ (CGFloat)estimatedHeightForStyle:(long long)style text:(id)text multipleLines:(BOOL)multipleLines detailText:(id)detailText multipleLines:(BOOL)detailMultipleLines tableWidth:(CGFloat)tableWidth contentEdgeInsets:(UIEdgeInsets)contentEdgeInsets {
    if (WDDShouldHideProbableSpam() && (WDDIsProbableSpamText(text) || WDDIsProbableSpamText(detailText))) {
        return 0.0;
    }
    return %orig;
}

+ (CGFloat)_heightForStyle:(long long)style text:(id)text font:(id)font multipleLines:(BOOL)multipleLines detailText:(id)detailText font:(id)detailFont multipleLines:(BOOL)detailMultipleLines padding:(UIEdgeInsets)padding icon:(id)icon horizontalIconPadding:(UIEdgeInsets)horizontalIconPadding badgeText:(id)badgeText tableWidth:(CGFloat)tableWidth contentEdgeInsets:(UIEdgeInsets)contentEdgeInsets estimated:(BOOL)estimated {
    if (WDDShouldHideProbableSpam() && (WDDIsProbableSpamText(text) || WDDIsProbableSpamText(detailText))) {
        return 0.0;
    }
    return %orig;
}
%end

%group ConversationShowMoreThreadCellHook
%hook _TtC14T1TwitterSwift30ConversationShowMoreThreadCell
- (void)layoutSubviews {
    %orig;
    BOOL hide = WDDShouldHideProbableSpam() && WDDViewTreeShowsProbableSpam((UIView *)self, 0);
    WDDSyncSpamCellContent((UIView *)self, hide);
}

- (CGSize)sizeThatFits:(CGSize)size {
    CGSize result = %orig;
    if (WDDShouldHideProbableSpam() && WDDViewTreeShowsProbableSpam((UIView *)self, 0)) {
        return CGSizeZero;
    }
    return result;
}

- (CGSize)systemLayoutSizeFittingSize:(CGSize)size {
    CGSize result = %orig;
    if (WDDShouldHideProbableSpam() && WDDViewTreeShowsProbableSpam((UIView *)self, 0)) {
        return CGSizeZero;
    }
    return result;
}
%end
%end

%ctor {
    %init;

    Class c6 = objc_getClass("T1TwitterSwift.ConversationShowMoreThreadCell");
    if (!c6) c6 = objc_getClass("_TtC14T1TwitterSwift30ConversationShowMoreThreadCell");
    if (c6) {
        %init(ConversationShowMoreThreadCellHook, _TtC14T1TwitterSwift30ConversationShowMoreThreadCell = c6);
    }
}
