#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import <objc/message.h>
#import <string.h>

extern _Thread_local BOOL g_isCalculatingQuotedLayout;
extern _Thread_local BOOL g_hasAdjustedQuotedWidth;

static inline BOOL WDDClassContains(Class cls, const char *needle) {
    if (!cls || !needle) return NO;
    const char *name = class_getName(cls);
    return name ? (strcasestr(name, needle) != NULL) : NO;
}

BOOL isAvatarClass(Class cls);

id WDDValueForKeySafe(id object, NSString *key);
NSString *WDDPlainTextOf(id text);
BOOL WDDIsProbableSpamText(id text);
void WDDSyncSpamCellContent(UIView *cell, BOOL hide);
BOOL WDDViewTreeShowsProbableSpam(UIView *view, NSInteger depth);
void makeImageViewsAspectFill(UIView *view, CGRect rect);
BOOL WDDApplyMediaHidden(UIView *view, BOOL hide);
