//
//  WDDUtils.m
//  wddtwitter
//

#import "WDDUtils.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import <string.h>

// ---------------------------------------------------------------
// 类名匹配的快速实现
//
// 旧写法 NSStringFromClass(cls) + rangeOfString:NSCaseInsensitiveSearch 会在每次
// 调用时新建一个 NSString，再做一次大小写不敏感扫描。这些检查位于 setFrame: /
// layoutSubviews / sizeThatFits: / intrinsicContentSize 等超热路径，滚动时每秒
// 可能被调用上千次，沿 superview 链还要乘上十几层。
//
// class_getName() 直接返回类对象里已有的 const char *，零分配；
// strcasestr 是 libc 的大小写不敏感子串查找。两者组合的开销比旧写法低两个数量级，
// 判定结果完全一致。
// ---------------------------------------------------------------
static inline BOOL WDDClassNameContains(Class cls, const char *needle) {
    if (!cls || !needle) return NO;
    const char *name = class_getName(cls);
    return name ? (strcasestr(name, needle) != NULL) : NO;
}

static inline BOOL WDDClassNameContains3(Class cls, const char *a, const char *b, const char *c) {
    if (!cls) return NO;
    const char *name = class_getName(cls);
    if (!name) return NO;
    if (a && strcasestr(name, a)) return YES;
    if (b && strcasestr(name, b)) return YES;
    if (c && strcasestr(name, c)) return YES;
    return NO;
}

BOOL WDDIsViewModelReply(id viewModel) {
    if (!viewModel) return NO;
    if ([viewModel respondsToSelector:@selector(isReply)]) {
        if (((BOOL (*)(id, SEL))objc_msgSend)(viewModel, @selector(isReply))) {
            return YES;
        }
    }
    if ([viewModel respondsToSelector:@selector(inReplyToScreenName)]) {
        if (((id (*)(id, SEL))objc_msgSend)(viewModel, @selector(inReplyToScreenName)) != nil) {
            return YES;
        }
    }
    if ([viewModel respondsToSelector:@selector(status)]) {
        id status = ((id (*)(id, SEL))objc_msgSend)(viewModel, @selector(status));
        if (status && ![status isKindOfClass:[NSNumber class]]) { // Avoid AVContentKeyRequestStatus conflict
            if ([status respondsToSelector:@selector(isReply)]) {
                if (((BOOL (*)(id, SEL))objc_msgSend)(status, @selector(isReply))) {
                    return YES;
                }
            }
            if ([status respondsToSelector:@selector(inReplyToScreenName)]) {
                if (((id (*)(id, SEL))objc_msgSend)(status, @selector(inReplyToScreenName)) != nil) {
                    return YES;
                }
            }
        }
    }
    return NO;
}
__weak UIViewController *WDDActiveViewController = nil;
BOOL WDDActiveViewControllerIsDetail = NO;

static BOOL isCurrentViewControllerDetails(UIViewController *vc) {
    if (!vc) return NO;
    
    // 0. Recursively check parents to support child view controllers correctly
    UIViewController *p = vc.parentViewController;
    while (p) {
        if (WDDClassNameContains3(object_getClass(p), "Detail", "Focal", "Conversation")) {
            return YES;
        }
        p = p.parentViewController;
    }
    
    // 1. Check conversationFocalStatusID
    if ([vc respondsToSelector:@selector(conversationFocalStatusID)]) {
        @try {
            long long focalID = ((long long (*)(id, SEL))objc_msgSend)(vc, @selector(conversationFocalStatusID));
            if (focalID != 0) {
                return YES;
            }
        } @catch (NSException *e) {}
    }
    
    // 2. Check isConversationFocalStatus
    if ([vc respondsToSelector:@selector(isConversationFocalStatus)]) {
        @try {
            BOOL isFocal = ((BOOL (*)(id, SEL))objc_msgSend)(vc, @selector(isConversationFocalStatus));
            if (isFocal) {
                return YES;
            }
        } @catch (NSException *e) {}
    }
    
    // 3. Check timeline property class name (for T1URTViewController with URTConversationTimeline)
    if ([vc respondsToSelector:@selector(timeline)]) {
        @try {
            id timeline = ((id (*)(id, SEL))objc_msgSend)(vc, @selector(timeline));
            if (timeline) {
                NSString *timelineClassName = NSStringFromClass([timeline class]);
                if ([timelineClassName rangeOfString:@"Conversation" options:NSCaseInsensitiveSearch].location != NSNotFound) {
                    return YES;
                }
            }
        } @catch (NSException *e) {}
    }

    // 4. Check scribeContext property (for tweet_detail/conversation pages)
    if ([vc respondsToSelector:@selector(scribeContext)]) {
        @try {
            id scribeContext = ((id (*)(id, SEL))objc_msgSend)(vc, @selector(scribeContext));
            if (scribeContext) {
                NSString *page = nil;
                if ([scribeContext respondsToSelector:@selector(scribePage)]) {
                    page = ((id (*)(id, SEL))objc_msgSend)(scribeContext, @selector(scribePage));
                }
                if (page && [page isKindOfClass:[NSString class]]) {
                    if ([page rangeOfString:@"tweet_detail" options:NSCaseInsensitiveSearch].location != NSNotFound ||
                        [page rangeOfString:@"conversation" options:NSCaseInsensitiveSearch].location != NSNotFound) {
                        return YES;
                    }
                }
            }
        } @catch (NSException *e) {}
    }
    
    // 5. Check class name of the view controller
    NSString *className = NSStringFromClass([vc class]);
    if ([className rangeOfString:@"Detail" options:NSCaseInsensitiveSearch].location != NSNotFound ||
        [className rangeOfString:@"Focal" options:NSCaseInsensitiveSearch].location != NSNotFound ||
        [className rangeOfString:@"Conversation" options:NSCaseInsensitiveSearch].location != NSNotFound) {
        return YES;
    }
    
    for (UIViewController *child in vc.childViewControllers) {
        if (isCurrentViewControllerDetails(child)) {
            return YES;
        }
    }
    
    return NO;
}

BOOL WDDIsCurrentActiveContextDetail(void) {
    // 优先使用当前已追踪且经过过滤的活动视图控制器，避免触发敏感的窗口树遍历
    UIViewController *activeVC = WDDActiveViewController;
    if (activeVC) {
        return isCurrentViewControllerDetails(activeVC);
    }

    @try {
        UIWindow *window = nil;
        if (@available(iOS 13.0, *)) {
            for (UIWindowScene *scene in [UIApplication sharedApplication].connectedScenes) {
                if (scene.activationState == UISceneActivationStateForegroundActive) {
                    for (UIWindow *w in scene.windows) {
                        Class wClass = [w class];
                        static Class remoteKeyboardClass = nil;
                        static Class textEffectsClass = nil;
                        static dispatch_once_t onceToken;
                        dispatch_once(&onceToken, ^{
                            remoteKeyboardClass = objc_getClass("UIRemoteKeyboardWindow");
                            textEffectsClass = objc_getClass("UITextEffectsWindow");
                        });
                        if ((remoteKeyboardClass && [w isKindOfClass:remoteKeyboardClass]) ||
                            (textEffectsClass && [w isKindOfClass:textEffectsClass])) {
                            continue;
                        }
                        if (w.isKeyWindow) {
                            window = w;
                            break;
                        }
                    }
                    if (!window) {
                        // 回退到该活动场景下的第一个非键盘类窗口
                        for (UIWindow *w in scene.windows) {
                            Class wClass = [w class];
                            static Class remoteKeyboardClass = nil;
                            static Class textEffectsClass = nil;
                            static dispatch_once_t onceToken;
                            dispatch_once(&onceToken, ^{
                                remoteKeyboardClass = objc_getClass("UIRemoteKeyboardWindow");
                                textEffectsClass = objc_getClass("UITextEffectsWindow");
                            });
                            if ((remoteKeyboardClass && [w isKindOfClass:remoteKeyboardClass]) ||
                                (textEffectsClass && [w isKindOfClass:textEffectsClass])) {
                                continue;
                            }
                            window = w;
                            break;
                        }
                    }
                }
                if (window) break;
            }
        }
        if (!window) {
            UIWindow *kw = [UIApplication sharedApplication].keyWindow;
            if (kw) {
                Class wClass = [kw class];
                static Class remoteKeyboardClass = nil;
                static Class textEffectsClass = nil;
                static dispatch_once_t onceToken;
                dispatch_once(&onceToken, ^{
                    remoteKeyboardClass = objc_getClass("UIRemoteKeyboardWindow");
                    textEffectsClass = objc_getClass("UITextEffectsWindow");
                });
                if (!((remoteKeyboardClass && [kw isKindOfClass:remoteKeyboardClass]) ||
                      (textEffectsClass && [kw isKindOfClass:textEffectsClass]))) {
                    window = kw;
                }
            }
        }
        if (!window && [[UIApplication sharedApplication].delegate respondsToSelector:@selector(window)]) {
            window = [[UIApplication sharedApplication].delegate performSelector:@selector(window)];
        }
        
        UIViewController *vc = window.rootViewController;
        while (vc) {
            if ([vc isKindOfClass:[UINavigationController class]]) {
                UINavigationController *nav = (UINavigationController *)vc;
                // Proactively check topViewController during transition
                UIViewController *top = nav.topViewController;
                if (top && isCurrentViewControllerDetails(top)) {
                    return YES;
                }
                UIViewController *visible = nav.visibleViewController;
                if (visible.isMovingFromParentViewController || visible.isBeingDismissed) {
                    vc = top;
                } else {
                    vc = visible;
                }
            } else if ([vc isKindOfClass:[UITabBarController class]]) {
                vc = [(UITabBarController *)vc selectedViewController];
            } else if (vc.presentedViewController && !vc.presentedViewController.isBeingDismissed) {
                vc = vc.presentedViewController;
            } else {
                break;
            }
        }
        if (vc) {
            return isCurrentViewControllerDetails(vc);
        }
    } @catch (NSException *e) {}
    return NO;
}

UIViewController *WDDViewControllerForView(UIView *view) {
    UIResponder *responder = view;
    while (responder) {
        if ([responder isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)responder;
        }
        responder = [responder nextResponder];
    }
    return nil;
}

BOOL WDDIsFocalContext(UIView *view) {
    // 0. 最便宜的一步先做：焦点推文布局生成期间打的线程标记。
    //    滚动时间线时这一步通常为 0，直接落到下面的实际判定。
    NSMutableDictionary *threadDict = [[NSThread currentThread] threadDictionary];
    if ([threadDict[@"WDDIsFocalLayout"] boolValue]) {
        return YES;
    }

    if (view) {
        // 1. 沿 superview 链找类名含 Focal / Detail 的祖先视图。
        //    用 class_getName + strcasestr，避免每层都分配一个 NSString。
        UIView *temp = view;
        while (temp) {
            if (WDDClassNameContains(object_getClass(temp), "Focal") ||
                WDDClassNameContains(object_getClass(temp), "Detail")) {
                return YES;
            }
            temp = temp.superview;
        }
        
        // 2. Walk responder chain to check owning view controller
        UIViewController *vc = WDDViewControllerForView(view);
        if (vc && isCurrentViewControllerDetails(vc)) {
            return YES;
        }
    }
    
    // 3. Global active controller fallback (Thread-safe reading of cached boolean)
    return WDDActiveViewControllerIsDetail;
}

// 精确判定：只有在「焦点推文」自己的布局生成过程中才算焦点上下文。
// 时间线 / 会话页里的回复单元格走的是 T1StandardStatusViewLayoutStateGenerator，
// 不会被标记，因此这些位置的图片功能可以正常工作。
BOOL WDDIsInFocalLayout(void) {
    NSMutableDictionary *threadDict = [[NSThread currentThread] threadDictionary];
    return [threadDict[@"WDDIsFocalLayout"] boolValue];
}
