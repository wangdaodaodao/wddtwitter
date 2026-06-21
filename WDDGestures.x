#import <UIKit/UIKit.h>
#import "WDDManager.h"
#import "TWHeaders.h"
#import <objc/runtime.h>

// ==============================
// Disable Long-Press Menu Logic
// ==============================

static BOOL isTargetCellOrStatusView(UIView *view) {
    if (!view) return NO;
    
    // 过滤掉键盘与文本输入系统窗口中的视图，确保不影响系统输入法
    if (view.window) {
        NSString *windowClass = NSStringFromClass([view.window class]);
        if ([windowClass rangeOfString:@"Keyboard" options:NSCaseInsensitiveSearch].location != NSNotFound ||
            [windowClass rangeOfString:@"TextInput" options:NSCaseInsensitiveSearch].location != NSNotFound) {
            return NO;
        }
    }
    
    static Class t1StatusViewClass = nil;
    static Class t1StandardStatusViewClass = nil;
    static Class tfnTableViewCellClass = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        t1StatusViewClass = objc_getClass("T1StatusView");
        t1StandardStatusViewClass = objc_getClass("T1StandardStatusView");
        tfnTableViewCellClass = objc_getClass("TFNTableViewCell");
    });
    
    if ([view isKindOfClass:t1StatusViewClass] || 
        [view isKindOfClass:t1StandardStatusViewClass] || 
        (tfnTableViewCellClass && [view isKindOfClass:tfnTableViewCellClass])) {
        return YES;
    }
    
    UIView *sup = view.superview;
    if (sup && tfnTableViewCellClass && [sup isKindOfClass:tfnTableViewCellClass]) {
        return YES;
    }
    return NO;
}

%hook UIView
- (void)addGestureRecognizer:(UIGestureRecognizer *)gesture {
    if ([WDDManager disableLongPressMenu]) {
        if ([gesture isKindOfClass:[UILongPressGestureRecognizer class]]) {
            if (isTargetCellOrStatusView(self)) {
                return;
            }
        }
    }
    %orig(gesture);
}

- (void)addInteraction:(id)interaction {
    if ([WDDManager disableLongPressMenu]) {
        if ([interaction isKindOfClass:objc_getClass("UIContextMenuInteraction")]) {
            if (isTargetCellOrStatusView(self)) {
                return;
            }
        }
    }
    %orig(interaction);
}
%end

%hook TFNDataViewController
- (id)tableView:(id)arg1 contextMenuConfigurationForRowAtIndexPath:(id)arg2 point:(CGPoint)arg3 {
    if ([WDDManager disableLongPressMenu]) {
        return nil;
    }
    return %orig(arg1, arg2, arg3);
}
- (id)collectionView:(id)arg1 contextMenuConfigurationForItemAtIndexPath:(id)arg2 point:(CGPoint)arg3 {
    if ([WDDManager disableLongPressMenu]) {
        return nil;
    }
    return %orig(arg1, arg2, arg3);
}
- (id)collectionView:(id)arg1 contextMenuConfigurationForItemsAtIndexPaths:(id)arg2 point:(CGPoint)arg3 {
    if ([WDDManager disableLongPressMenu]) {
        return nil;
    }
    return %orig(arg1, arg2, arg3);
}
%end

%hook TFNItemsDataViewController
- (id)tableView:(id)arg1 contextMenuConfigurationForRowAtIndexPath:(id)arg2 point:(CGPoint)arg3 {
    if ([WDDManager disableLongPressMenu]) {
        return nil;
    }
    return %orig(arg1, arg2, arg3);
}
- (id)collectionView:(id)arg1 contextMenuConfigurationForItemAtIndexPath:(id)arg2 point:(CGPoint)arg3 {
    if ([WDDManager disableLongPressMenu]) {
        return nil;
    }
    return %orig(arg1, arg2, arg3);
}
- (id)collectionView:(id)arg1 contextMenuConfigurationForItemsAtIndexPaths:(id)arg2 point:(CGPoint)arg3 {
    if ([WDDManager disableLongPressMenu]) {
        return nil;
    }
    return %orig(arg1, arg2, arg3);
}
- (void)cellLongPressWithGesture:(id)arg1 {
    if ([WDDManager disableLongPressMenu]) return;
    %orig(arg1);
}
- (void)cellLongPressPreviewWithGesture:(id)arg1 {
    if ([WDDManager disableLongPressMenu]) return;
    %orig(arg1);
}
- (void)cellLongPressRecordWithGesture:(id)arg1 {
    if ([WDDManager disableLongPressMenu]) return;
    %orig(arg1);
}
%end
