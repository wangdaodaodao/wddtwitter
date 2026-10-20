#import "WDDLayoutShared.h"

_Thread_local BOOL g_isCalculatingQuotedLayout = NO;
_Thread_local BOOL g_hasAdjustedQuotedWidth = NO;

BOOL isAvatarClass(Class cls) {
    return WDDClassContains(cls, "Avatar");
}

id WDDValueForKeySafe(id object, NSString *key) {
    if (!object || key.length == 0) return nil;
    @try {
        return [object valueForKey:key];
    } @catch (__unused NSException *e) {
        return nil;
    }
}

NSString *WDDPlainTextOf(id text) {
    if ([text isKindOfClass:[NSString class]]) return (NSString *)text;
    if ([text isKindOfClass:[NSAttributedString class]]) return [(NSAttributedString *)text string];
    if ([text isKindOfClass:[NSObject class]]) {
        id inner = WDDValueForKeySafe(text, @"string");
        if ([inner isKindOfClass:[NSString class]]) return inner;
        id stringValue = WDDValueForKeySafe(text, @"stringValue");
        if ([stringValue isKindOfClass:[NSString class]]) return stringValue;
    }
    return nil;
}

BOOL WDDIsProbableSpamText(id text) {
    NSString *plain = WDDPlainTextOf(text);
    if (plain.length == 0) return NO;

    BOOL hasCJK = ([plain rangeOfString:@"垃圾"].location != NSNotFound);
    BOOL hasSpam = hasCJK ? NO : ([plain rangeOfString:@"spam" options:NSCaseInsensitiveSearch].location != NSNotFound);
    if (!hasCJK && !hasSpam) return NO;

    if (hasCJK) {
        if ([plain rangeOfString:@"显示"].location != NSNotFound) return YES;
        if ([plain rangeOfString:@"可能"].location != NSNotFound) return YES;
        if ([plain rangeOfString:@"潜在"].location != NSNotFound) return YES;
        if ([plain rangeOfString:@"查看"].location != NSNotFound) return YES;
        return NO;
    }

    if ([plain rangeOfString:@"show" options:NSCaseInsensitiveSearch].location != NSNotFound) return YES;
    if ([plain rangeOfString:@"probable" options:NSCaseInsensitiveSearch].location != NSNotFound) return YES;
    if ([plain rangeOfString:@"likely" options:NSCaseInsensitiveSearch].location != NSNotFound) return YES;
    if ([plain rangeOfString:@"possible" options:NSCaseInsensitiveSearch].location != NSNotFound) return YES;
    if ([plain rangeOfString:@"potential" options:NSCaseInsensitiveSearch].location != NSNotFound) return YES;
    if ([plain rangeOfString:@"view" options:NSCaseInsensitiveSearch].location != NSNotFound) return YES;
    return NO;
}

void WDDSyncSpamCellContent(UIView *cell, BOOL hide) {
    if (!cell) return;
    if (hide) {
        cell.backgroundColor = [UIColor clearColor];
        if ([cell isKindOfClass:[UITableViewCell class]]) {
            ((UITableViewCell *)cell).contentView.backgroundColor = [UIColor clearColor];
        }
    }
    for (UIView *subview in cell.subviews) {
        subview.hidden = hide;
        subview.alpha = hide ? 0.0 : 1.0;
    }
}

BOOL WDDViewTreeShowsProbableSpam(UIView *view, NSInteger depth) {
    if (!view || depth > 4) return NO;
    if ([view isKindOfClass:[UILabel class]]) {
        UILabel *label = (UILabel *)view;
        if (WDDIsProbableSpamText(label.text)) return YES;
        if (WDDIsProbableSpamText(label.attributedText)) return YES;
    }
    for (UIView *subview in view.subviews) {
        if (WDDViewTreeShowsProbableSpam(subview, depth + 1)) return YES;
    }
    return NO;
}

void makeImageViewsAspectFill(UIView *view, CGRect rect) {
    (void)rect;
    if (!view) return;
    if ([view isKindOfClass:[UIImageView class]]) {
        if (!view.clipsToBounds) {
            view.clipsToBounds = YES;
        }
        if (view.contentMode != UIViewContentModeScaleAspectFill) {
            view.contentMode = UIViewContentModeScaleAspectFill;
        }
    }
    for (UIView *subview in view.subviews) {
        makeImageViewsAspectFill(subview, view.bounds);
    }
}
