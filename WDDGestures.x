#import <UIKit/UIKit.h>
#import "WDDManager.h"
#import "TWHeaders.h"
#import <objc/runtime.h>

// ==============================
// Disable Long-Press Menu Logic
// ==============================

static BOOL isTargetCellOrStatusView(UIView *view) {
    if (!view) return NO;
    
    static Class t1StatusViewClass = nil;
    static Class t1StandardStatusViewClass = nil;
    static Class tableViewCellClass = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        t1StatusViewClass = objc_getClass("T1StatusView");
        t1StandardStatusViewClass = objc_getClass("T1StandardStatusView");
        tableViewCellClass = objc_getClass("UITableViewCell");
    });
    
    if ([view isKindOfClass:t1StatusViewClass] || 
        [view isKindOfClass:t1StandardStatusViewClass] || 
        [view isKindOfClass:tableViewCellClass]) {
        return YES;
    }
    
    UIView *sup = view.superview;
    if (sup && [sup isKindOfClass:tableViewCellClass]) {
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
