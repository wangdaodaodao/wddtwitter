#import "WDDManager.h"
#import "WDDLayoutShared.h"
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <objc/runtime.h>

static NSRegularExpression *WDDStripSourceRegex(void) {
    static NSRegularExpression *regex = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        NSString *pattern = @"(?:\\A|[ \\t]*\\r?\\n)+[ \\t]*(?:来自|via)[ \\t\u00a0]+[A-Za-z0-9._\\-]+\\.[A-Za-z]{2,}[ \\t\\r\\n]*\\z";
        regex = [NSRegularExpression regularExpressionWithPattern:pattern
                                                          options:NSRegularExpressionCaseInsensitive
                                                            error:NULL];
    });
    return regex;
}

static BOOL WDDTextMayContainSourceLine(NSString *text) {
    if (text.length < 4) return NO;

    NSUInteger tailLength = MIN(text.length, (NSUInteger)160);
    NSRange tail = NSMakeRange(text.length - tailLength, tailLength);

    if ([text rangeOfString:@"来自" options:0 range:tail].location != NSNotFound) return YES;
    if ([text rangeOfString:@"via " options:NSCaseInsensitiveSearch range:tail].location != NSNotFound) return YES;
    return NO;
}

static NSString *WDDStripSourceLine(NSString *text) {
    if (![text isKindOfClass:[NSString class]]) return text;
    if (!WDDTextMayContainSourceLine(text)) return text;

    NSRegularExpression *regex = WDDStripSourceRegex();
    if (!regex) return text;

    NSRange full = NSMakeRange(0, text.length);
    NSTextCheckingResult *match = [regex firstMatchInString:text options:0 range:full];
    if (!match || match.range.location == NSNotFound || match.range.length == 0) return text;

    return [text stringByReplacingCharactersInRange:match.range withString:@""];
}

static NSAttributedString *WDDStripSourceLineAttributed(NSAttributedString *text) {
    if (![text isKindOfClass:[NSAttributedString class]] || text.length == 0) return text;

    NSString *plain = text.string;
    NSString *stripped = WDDStripSourceLine(plain);
    if (stripped == plain || [stripped isEqualToString:plain]) return text;
    if (stripped.length >= plain.length) return text;

    NSMutableAttributedString *mutable = [text mutableCopy];
    [mutable deleteCharactersInRange:NSMakeRange(stripped.length, plain.length - stripped.length)];
    return [mutable copy];
}

static BOOL WDDReadRectIvar(id object, const char *name, CGRect *out) {
    if (!object || !name || !out) return NO;

    Ivar ivar = class_getInstanceVariable([object class], name);
    if (!ivar) return NO;

    const char *type = ivar_getTypeEncoding(ivar);
    if (!type || strncmp(type, "{CGRect=", 8) != 0) return NO;

    *out = *(CGRect *)((uint8_t *)(__bridge void *)object + ivar_getOffset(ivar));
    return YES;
}

static CGRect WDDCardStateFrame(id state, NSString *key) {
    if (!state || key.length == 0) return CGRectZero;
    if (![state respondsToSelector:NSSelectorFromString(key)]) return CGRectZero;
    @try {
        id value = [state valueForKey:key];
        if ([value isKindOfClass:[NSValue class]]) return [value CGRectValue];
    } @catch (__unused NSException *e) {}
    return CGRectZero;
}

static BOOL WDDTimelineMediaSuppressed(void) {
    return [WDDManager hideTimelineImages] || [WDDManager hideAllMedia];
}

static BOOL WDDIsWebsiteOnlyCardState(id state) {
    if (!state) return NO;

    CGRect website = CGRectZero;
    if (!WDDReadRectIvar(state, "_websiteFrame", &website)) return NO;
    if (CGRectIsEmpty(website)) return NO;

    if (!CGRectIsEmpty(WDDCardStateFrame(state, @"titleFrame"))) return NO;
    if (!CGRectIsEmpty(WDDCardStateFrame(state, @"detailTextFrame"))) return NO;

    if (!CGRectIsEmpty(WDDCardStateFrame(state, @"mediaFrame"))) {
        if (!WDDTimelineMediaSuppressed()) return NO;
    }

    return YES;
}

static id WDDCardViewLayoutState(id cardView) {
    if (!cardView) return nil;
    SEL sel = NSSelectorFromString(@"layoutState");
    if (![cardView respondsToSelector:sel]) return nil;
    @try {
        return ((id (*)(id, SEL))objc_msgSend)(cardView, sel);
    } @catch (__unused NSException *e) {}
    return nil;
}

static BOOL WDDShouldCollapseCardView(id cardView) {
    if (![WDDManager hideSourceAttribution]) return NO;
    return WDDIsWebsiteOnlyCardState(WDDCardViewLayoutState(cardView));
}

static Class WDDVanityViewClass(void) {
    static Class cls = nil;
    if (!cls) cls = objc_getClass("T1UnifiedCardVanityView");
    return cls;
}

static BOOL WDDViewTreeHasText(UIView *root) {
    if (!root || root.hidden || root.alpha < 0.01) return NO;

    if ([root isKindOfClass:[UILabel class]]) {
        UILabel *label = (UILabel *)root;
        if (label.text.length > 0 || label.attributedText.length > 0) return YES;
    } else if ([root isKindOfClass:[UITextView class]]) {
        UITextView *textView = (UITextView *)root;
        if (textView.text.length > 0 || textView.attributedText.length > 0) return YES;
    }

    for (UIView *subview in root.subviews) {
        if (WDDViewTreeHasText(subview)) return YES;
    }
    return NO;
}

static const void *WDDStrippedLabelKey = &WDDStrippedLabelKey;

static BOOL WDDViewTreeHasStrippedLabel(UIView *root) {
    if (!root) return NO;
    if (objc_getAssociatedObject(root, WDDStrippedLabelKey)) return YES;

    for (UIView *subview in root.subviews) {
        if (WDDViewTreeHasStrippedLabel(subview)) return YES;
    }
    return NO;
}

static BOOL WDDViewTreeHasVisibleImage(UIView *root) {
    if (!root || root.hidden || root.alpha < 0.01) return NO;

    if ([root isKindOfClass:[UIImageView class]] &&
        root.bounds.size.width > 2.0 &&
        root.bounds.size.height > 2.0) {
        return YES;
    }

    for (UIView *subview in root.subviews) {
        if (WDDViewTreeHasVisibleImage(subview)) return YES;
    }
    return NO;
}

static void WDDHideEmptyBars(UIView *root, BOOL hide) {
    CGFloat parentWidth = root.bounds.size.width;

    for (UIView *subview in root.subviews) {
        if (!hide) {
            WDDApplyMediaHidden(subview, NO);
        } else {
            UIColor *background = subview.backgroundColor;
            BOOL hasBackground = background && CGColorGetAlpha(background.CGColor) > 0.05;
            BOOL hasBorder = subview.layer.borderWidth > 0.5;
            CGFloat height = subview.bounds.size.height;
            CGFloat width = subview.bounds.size.width;
            BOOL barSized = height > 12.0 && height <= 32.0;
            BOOL wideEnough = parentWidth <= 0.0 || width >= parentWidth * 0.6;
            BOOL noText = !WDDViewTreeHasText(subview);

            if ((hasBackground || hasBorder) && barSized && wideEnough && noText) {
                WDDApplyMediaHidden(subview, YES);
            }
        }

        WDDHideEmptyBars(subview, hide);
    }
}

static void WDDApplySourceContainerHidden(UIView *label, BOOL hide) {
    UIView *node = label.superview;
    NSInteger depth = 0;

    while (node && depth < 6) {
        if (!hide) {
            WDDApplyMediaHidden(node, NO);
        } else {
            UIColor *background = node.backgroundColor;
            BOOL hasBackground = background && CGColorGetAlpha(background.CGColor) > 0.05;
            BOOL hasBorder = node.layer.borderWidth > 0.5;

            if (hasBackground || hasBorder) {
                if (WDDViewTreeHasVisibleImage(node)) return;
                if (node.bounds.size.height <= 120.0) {
                    WDDApplyMediaHidden(node, YES);
                }
                return;
            }
        }

        node = node.superview;
        depth++;
    }
}

static void WDDHideVanityViews(UIView *root, BOOL hide) {
    Class vanityClass = WDDVanityViewClass();
    if (!vanityClass) return;

    for (UIView *subview in root.subviews) {
        if ([subview isKindOfClass:vanityClass]) {
            WDDApplyMediaHidden(subview, hide);
        }
        WDDHideVanityViews(subview, hide);
    }
}

%hook T1UnifiedCardVanityView
+ (CGSize)preferredSizeForMaxWidth:(CGFloat)width {
    if ([WDDManager hideSourceAttribution]) return CGSizeZero;
    return %orig;
}

- (void)layoutSubviews {
    %orig;
    WDDApplyMediaHidden((UIView *)self, [WDDManager hideSourceAttribution]);
}
%end

static NSArray *WDDUnifiedCardComponentViews(UIView *card) {
    id value = WDDValueForKeySafe(card, @"allComponentViews");
    if ([value isKindOfClass:[NSArray class]]) return value;
    if ([value isKindOfClass:[NSSet class]]) return [(NSSet *)value allObjects];
    return nil;
}

static void WDDCollapseUnifiedCardFooter(UIView *card) {
    if (!card) return;

    UIView *footer = WDDValueForKeySafe(card, @"footerView");
    if ([footer isKindOfClass:[UIView class]] &&
        !footer.hidden &&
        footer.alpha > 0.01 &&
        footer.bounds.size.height > 0.5) {
        return;
    }

    UIView *container = nil;
    for (UIView *subview in card.subviews) {
        if (subview.layer.borderWidth > 0.2) {
            container = subview;
            break;
        }
    }
    if (!container) return;

    NSArray *components = WDDUnifiedCardComponentViews(card);
    if (components.count == 0) return;

    CGFloat bottom = 0.0;
    for (id item in components) {
        if (![item isKindOfClass:[UIView class]]) continue;
        UIView *component = (UIView *)item;
        if (component.hidden || component.alpha < 0.01) continue;
        if (component.bounds.size.height <= 0.5) continue;
        CGRect rect = [component convertRect:component.bounds toView:container];
        bottom = MAX(bottom, CGRectGetMaxY(rect));
    }

    if (bottom <= 0.0) return;
    if (bottom >= container.bounds.size.height - 0.5) return;

    CGRect frame = container.frame;
    frame.size.height = bottom;
    container.frame = frame;
}

%hook T1UnifiedCardView
+ (CGSize)containerViewSizeWithUnifiedCard:(id)unifiedCard features:(id)features shouldHideFooter:(BOOL)shouldHideFooter maxWidth:(CGFloat)maxWidth layoutSize:(CGSize)layoutSize {
    if ([WDDManager hideSourceAttribution]) shouldHideFooter = YES;
    return %orig(unifiedCard, features, shouldHideFooter, maxWidth, layoutSize);
}

- (void)layoutSubviews {
    %orig;

    UIView *card = (UIView *)self;

    BOOL hideSource = [WDDManager hideSourceAttribution];
    WDDHideVanityViews(card, hideSource);
    WDDHideEmptyBars(card, hideSource);
    if (hideSource) WDDCollapseUnifiedCardFooter(card);

    if (!hideSource) {
        WDDApplyMediaHidden(card, NO);
        return;
    }

    BOOL tiny = card.bounds.size.height > 0.0 && card.bounds.size.height <= 44.0;
    BOOL empty = WDDTimelineMediaSuppressed() && !WDDViewTreeHasText(card);
    BOOL sourceOnly = WDDViewTreeHasStrippedLabel(card) && !WDDViewTreeHasVisibleImage(card);
    WDDApplyMediaHidden(card, tiny || empty || sourceOnly);
}
%end

%hook T1WebCardViewLayoutState
- (CGSize)size {
    if ([WDDManager hideSourceAttribution] && WDDIsWebsiteOnlyCardState(self)) {
        return CGSizeZero;
    }
    return %orig;
}

- (CGRect)imageInfoAreaBorderFrame {
    if ([WDDManager hideSourceAttribution] && WDDIsWebsiteOnlyCardState(self)) {
        return CGRectZero;
    }
    return %orig;
}

- (CGRect)websiteFrame {
    if ([WDDManager hideSourceAttribution] && WDDIsWebsiteOnlyCardState(self)) {
        return CGRectZero;
    }
    return %orig;
}
%end

%hook T1WebCardView
- (void)layoutSubviews {
    %orig;

    UIView *card = (UIView *)self;
    BOOL hideSource = [WDDManager hideSourceAttribution];
    WDDHideEmptyBars(card, hideSource);

    BOOL tiny = hideSource &&
                card.bounds.size.height > 0.0 &&
                card.bounds.size.height <= 44.0;
    BOOL sourceOnly = hideSource &&
                      WDDViewTreeHasStrippedLabel(card) &&
                      !WDDViewTreeHasVisibleImage(card);
    BOOL collapse = tiny || sourceOnly || WDDShouldCollapseCardView(self);

    WDDApplyMediaHidden(card, collapse);

    for (UIView *subview in card.subviews) {
        WDDApplyMediaHidden(subview, collapse);
    }
}
%end

%hook T1ConversationFocalStatusView
- (void)layoutSubviews {
    %orig;
    WDDHideEmptyBars((UIView *)self, [WDDManager hideSourceAttribution]);
}
%end

%hook UILabel
- (void)setText:(NSString *)text {
    if ([WDDManager hideSourceAttribution]) {
        NSString *stripped = WDDStripSourceLine(text);
        BOOL hit = (stripped != text && ![stripped isEqualToString:text]);
        BOOL hadMark = objc_getAssociatedObject(self, WDDStrippedLabelKey) != nil;
        objc_setAssociatedObject(self, WDDStrippedLabelKey, hit ? @YES : nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        text = stripped;

        if (hit || hadMark) {
            UILabel *label = self;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                WDDApplySourceContainerHidden(label, hit);
            });
        }
    }
    %orig(text);
}

- (void)setAttributedText:(NSAttributedString *)text {
    if ([WDDManager hideSourceAttribution]) {
        NSAttributedString *stripped = WDDStripSourceLineAttributed(text);
        BOOL hit = (stripped != text && ![stripped isEqualToAttributedString:text]);
        BOOL hadMark = objc_getAssociatedObject(self, WDDStrippedLabelKey) != nil;
        objc_setAssociatedObject(self, WDDStrippedLabelKey, hit ? @YES : nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        text = stripped;

        if (hit || hadMark) {
            UILabel *label = self;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                WDDApplySourceContainerHidden(label, hit);
            });
        }
    }
    %orig(text);
}
%end

%hook UITextView
- (void)setText:(NSString *)text {
    if ([WDDManager hideSourceAttribution]) {
        NSString *stripped = WDDStripSourceLine(text);
        BOOL hit = (stripped != text && ![stripped isEqualToString:text]);
        BOOL hadMark = objc_getAssociatedObject(self, WDDStrippedLabelKey) != nil;
        objc_setAssociatedObject(self, WDDStrippedLabelKey, hit ? @YES : nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        text = stripped;

        if (hit || hadMark) {
            UIView *view = self;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                WDDApplySourceContainerHidden(view, hit);
            });
        }
    }
    %orig(text);
}

- (void)setAttributedText:(NSAttributedString *)text {
    if ([WDDManager hideSourceAttribution]) {
        NSAttributedString *stripped = WDDStripSourceLineAttributed(text);
        BOOL hit = (stripped != text && ![stripped isEqualToAttributedString:text]);
        BOOL hadMark = objc_getAssociatedObject(self, WDDStrippedLabelKey) != nil;
        objc_setAssociatedObject(self, WDDStrippedLabelKey, hit ? @YES : nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        text = stripped;

        if (hit || hadMark) {
            UIView *view = self;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                WDDApplySourceContainerHidden(view, hit);
            });
        }
    }
    %orig(text);
}
%end

%ctor {
    %init;
}
