
#import "WDDUtils.h"
#import "WDDManager.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import <string.h>

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
        if (status && ![status isKindOfClass:[NSNumber class]]) {
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

    UIViewController *p = vc.parentViewController;
    while (p) {
        if (WDDClassNameContains3(object_getClass(p), "Detail", "Focal", "Conversation")) {
            return YES;
        }
        p = p.parentViewController;
    }

    if ([vc respondsToSelector:@selector(conversationFocalStatusID)]) {
        @try {
            long long focalID = ((long long (*)(id, SEL))objc_msgSend)(vc, @selector(conversationFocalStatusID));
            if (focalID != 0) {
                return YES;
            }
        } @catch (NSException *e) {}
    }

    if ([vc respondsToSelector:@selector(isConversationFocalStatus)]) {
        @try {
            BOOL isFocal = ((BOOL (*)(id, SEL))objc_msgSend)(vc, @selector(isConversationFocalStatus));
            if (isFocal) {
                return YES;
            }
        } @catch (NSException *e) {}
    }

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

    NSMutableDictionary *threadDict = [[NSThread currentThread] threadDictionary];
    if ([threadDict[@"WDDIsFocalLayout"] boolValue]) {
        return YES;
    }

    if (view) {

        UIView *temp = view;
        while (temp) {
            if (WDDClassNameContains(object_getClass(temp), "Focal") ||
                WDDClassNameContains(object_getClass(temp), "Detail")) {
                return YES;
            }
            temp = temp.superview;
        }

        UIViewController *vc = WDDViewControllerForView(view);
        if (vc && isCurrentViewControllerDetails(vc)) {
            return YES;
        }
    }

    return WDDActiveViewControllerIsDetail;
}

BOOL WDDIsInFocalLayout(void) {
    NSMutableDictionary *threadDict = [[NSThread currentThread] threadDictionary];
    return [threadDict[@"WDDIsFocalLayout"] boolValue];
}

static BOOL WDDClassNameLooksLikeMediaViewer(Class cls) {
    if (!cls) return NO;
    const char *name = class_getName(cls);
    if (!name) return NO;

    if (strcasestr(name, "ComponentView") ||
        strcasestr(name, "LayoutState") ||
        strcasestr(name, "LayoutDelegate") ||
        strcasestr(name, "Cell") ||
        strcasestr(name, "StatusView") ||
        strcasestr(name, "Adapter") ||
        strcasestr(name, "ViewModel")) {
        return NO;
    }

    static const char *keys[] = {
        "Immersive",
        "PhotoGallery", "PhotoViewer", "PhotoBrowser", "PhotoPreview",
        "MediaViewer", "MediaGallery", "MediaPreview", "MediaBrowser",
        "ImageGallery", "ImageViewer",
        "Lightbox", "LightBox",
        "FullScreen", "Fullscreen"
    };
    for (size_t i = 0; i < sizeof(keys) / sizeof(keys[0]); i++) {
        if (strcasestr(name, keys[i])) return YES;
    }
    return NO;
}

BOOL WDDIsMediaViewerController(UIViewController *vc) {
    while (vc) {
        if (WDDClassNameLooksLikeMediaViewer(object_getClass(vc))) return YES;
        vc = vc.parentViewController;
    }
    return NO;
}

BOOL WDDIsMediaViewerContext(UIView *view) {
    if (WDDIsMediaViewerController(WDDActiveViewController)) return YES;

    if (view) {
        UIView *temp = view;
        while (temp) {
            if (WDDClassNameLooksLikeMediaViewer(object_getClass(temp))) return YES;
            temp = temp.superview;
        }

        if (WDDIsMediaViewerController(WDDViewControllerForView(view))) return YES;

        UIViewController *presented = view.window.rootViewController;
        while (presented) {
            if (WDDClassNameLooksLikeMediaViewer(object_getClass(presented))) return YES;
            presented = presented.presentedViewController;
        }
    }

    return NO;
}

BOOL WDDIsFocalStatusView(UIView *view) {
    UIView *temp = view;
    while (temp) {
        if (WDDClassNameContains(object_getClass(temp), "Focal")) return YES;
        temp = temp.superview;
    }
    return NO;
}

BOOL WDDShouldHideTimelineMedia(UIView *view) {
    BOOL hideAll = [WDDManager hideAllMedia];
    BOOL hideTimeline = [WDDManager hideTimelineImages];
    if (!hideAll && !hideTimeline) return NO;
    if (WDDIsMediaViewerContext(view)) return NO;
    if (hideAll) return YES;
    if (WDDIsInFocalLayout()) return NO;
    if (view && WDDIsFocalStatusView(view)) return NO;
    if (WDDIsFocalContext(view)) return NO;
    return YES;
}

BOOL WDDShouldHideTranslation(void) {
    return [WDDManager hideTranslationNotice];
}
