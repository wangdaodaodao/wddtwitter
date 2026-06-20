#import <UIKit/UIKit.h>
#import "WDDManager.h"
#import "TWHeaders.h"
#import <objc/runtime.h>

// ==============================
// Disable Long-Press Menu Logic
// ==============================

static BOOL isTargetCellOrStatusView(UIView *view) {
    if (!view) return NO;
    NSString *className = NSStringFromClass([view class]);
    if ([className isEqualToString:@"T1StatusView"] ||
        [className isEqualToString:@"T1StandardStatusView"] ||
        [view isKindOfClass:objc_getClass("UITableViewCell")]) {
        return YES;
    }
    UIView *sup = view.superview;
    if (sup && [sup isKindOfClass:objc_getClass("UITableViewCell")]) {
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
