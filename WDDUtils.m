//
//  WDDUtils.m
//  wddtwitter
//

#import "WDDUtils.h"
#import <objc/runtime.h>
#import <objc/message.h>

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
                        NSString *className = NSStringFromClass([w class]);
                        // 绝对不能遍历任何与键盘、输入法有关的特殊窗口，以防导致远程输入法连接断开/重置
                        if ([className rangeOfString:@"Keyboard" options:NSCaseInsensitiveSearch].location != NSNotFound ||
                            [className rangeOfString:@"TextInput" options:NSCaseInsensitiveSearch].location != NSNotFound) {
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
                            NSString *className = NSStringFromClass([w class]);
                            if ([className rangeOfString:@"Keyboard" options:NSCaseInsensitiveSearch].location == NSNotFound &&
                                [className rangeOfString:@"TextInput" options:NSCaseInsensitiveSearch].location == NSNotFound) {
                                window = w;
                                break;
                            }
                        }
                    }
                }
                if (window) break;
            }
        }
        if (!window) {
            UIWindow *kw = [UIApplication sharedApplication].keyWindow;
            NSString *className = NSStringFromClass([kw class]);
            if ([className rangeOfString:@"Keyboard" options:NSCaseInsensitiveSearch].location == NSNotFound &&
                [className rangeOfString:@"TextInput" options:NSCaseInsensitiveSearch].location == NSNotFound) {
                window = kw;
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
    if (view) {
        // 1. Walk superview chain for cell/view class containing Focal or Detail
        UIView *temp = view;
        while (temp) {
            NSString *className = NSStringFromClass([temp class]);
            if ([className rangeOfString:@"Focal" options:NSCaseInsensitiveSearch].location != NSNotFound ||
                [className rangeOfString:@"Detail" options:NSCaseInsensitiveSearch].location != NSNotFound) {
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
    
    // 3. Thread local flag set during layout state generation
    NSMutableDictionary *threadDict = [[NSThread currentThread] threadDictionary];
    if ([threadDict[@"WDDIsFocalLayout"] boolValue]) {
        return YES;
    }
    
    // 4. Global active controller fallback (Thread-safe reading of cached boolean)
    return WDDActiveViewControllerIsDetail;
}
