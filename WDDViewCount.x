#import "WDDManager.h"
#import <objc/runtime.h>
#import <objc/message.h>

// ==============================
// View Count Hiding Logic
// ==============================

static void swizzleMethod(Class cls, SEL sel, IMP newImp, NSString *origPrefix) {
    if (!cls || !sel || !newImp) return;
    
    BOOL definesMethod = NO;
    unsigned int count = 0;
    Method *methods = class_copyMethodList(cls, &count);
    if (methods) {
        for (unsigned int i = 0; i < count; i++) {
            if (method_getName(methods[i]) == sel) {
                definesMethod = YES;
                break;
            }
        }
        free(methods);
    }
    
    if (!definesMethod) {
        return;
    }
    
    Method method = class_getInstanceMethod(cls, sel);
    if (!method) return;
    
    IMP origImp = method_getImplementation(method);
    const char *types = method_getTypeEncoding(method);
    
    NSString *origSelName = [NSString stringWithFormat:@"%@%@", origPrefix, NSStringFromSelector(sel)];
    origSelName = [origSelName stringByReplacingOccurrencesOfString:@":" withString:@"_"];
    SEL origSel = sel_registerName([origSelName UTF8String]);
    
    class_addMethod(cls, origSel, origImp, types);
    class_replaceMethod(cls, sel, newImp, types);
}

static BOOL custom_isShowViewCountTopRightEnabled(id self, SEL _cmd) {
    if ([WDDManager hideTimelineViewCount]) {
        return NO;
    }
    SEL origSel = sel_registerName("wdd_orig_isShowViewCountTopRightEnabled");
    if ([self respondsToSelector:origSel]) {
        return ((BOOL (*)(id, SEL))objc_msgSend)(self, origSel);
    }
    return NO;
}

static BOOL custom_isViewCountHomeTimelineEnabled(id self, SEL _cmd) {
    if ([WDDManager hideTimelineViewCount]) {
        return NO;
    }
    SEL origSel = sel_registerName("wdd_orig_isViewCountHomeTimelineEnabled");
    if ([self respondsToSelector:origSel]) {
        return ((BOOL (*)(id, SEL))objc_msgSend)(self, origSel);
    }
    return NO;
}

static BOOL custom_shouldShowViewCountFor_viewModel_isKnownFocal(id self, SEL _cmd, id status, id viewModel, BOOL isKnownFocal) {
    if ([WDDManager hideTimelineViewCount]) {
        return NO;
    }
    SEL origSel = sel_registerName("wdd_orig_shouldShowViewCountFor_viewModel_isKnownFocal");
    if ([self respondsToSelector:origSel]) {
        return ((BOOL (*)(id, SEL, id, id, BOOL))objc_msgSend)(self, origSel, status, viewModel, isKnownFocal);
    }
    return NO;
}

void WDDHookViewCountSelectorsIfNeeded(void) {
    int numClasses = objc_getClassList(NULL, 0);
    if (numClasses <= 0) return;
    
    Class *classes = (Class *)malloc(sizeof(Class) * numClasses);
    numClasses = objc_getClassList(classes, numClasses);
    
    SEL isShowViewCountTopRightSel = sel_registerName("isShowViewCountTopRightEnabled");
    SEL isViewCountHomeTimelineSel = sel_registerName("isViewCountHomeTimelineEnabled");
    SEL shouldShowViewCountSel = sel_registerName("shouldShowViewCountFor:viewModel:isKnownFocal:");
    
    for (int i = 0; i < numClasses; i++) {
        Class cls = classes[i];
        if (!cls) continue;
        
        swizzleMethod(cls, isShowViewCountTopRightSel, (IMP)custom_isShowViewCountTopRightEnabled, @"wdd_orig_");
        swizzleMethod(cls, isViewCountHomeTimelineSel, (IMP)custom_isViewCountHomeTimelineEnabled, @"wdd_orig_");
        swizzleMethod(cls, shouldShowViewCountSel, (IMP)custom_shouldShowViewCountFor_viewModel_isKnownFocal, @"wdd_orig_");
        
        Class metaCls = object_getClass(cls);
        if (metaCls && metaCls != cls) {
            swizzleMethod(metaCls, isShowViewCountTopRightSel, (IMP)custom_isShowViewCountTopRightEnabled, @"wdd_orig_");
            swizzleMethod(metaCls, isViewCountHomeTimelineSel, (IMP)custom_isViewCountHomeTimelineEnabled, @"wdd_orig_");
            swizzleMethod(metaCls, shouldShowViewCountSel, (IMP)custom_shouldShowViewCountFor_viewModel_isKnownFocal, @"wdd_orig_");
        }
    }
    free(classes);
    NSLog(@"[wddtwitter] Finished dynamic swizzling for view count selectors.");
}

%ctor {
    WDDHookViewCountSelectorsIfNeeded();
}
