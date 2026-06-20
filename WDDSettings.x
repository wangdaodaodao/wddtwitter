#import "WDDSettingsViewController.h"
#import "TWHeaders.h"
#import <objc/runtime.h>

// ==============================
// Settings Page Entry Injection
// ==============================

%hook T1GenericSettingsViewController
- (void)viewWillAppear:(BOOL)arg1 {
    %orig;
    
    // Use associated object to prevent duplicate entries
    if (objc_getAssociatedObject(self, @selector(viewWillAppear:)) != nil) {
        return;
    }
    objc_setAssociatedObject(self, @selector(viewWillAppear:), @YES, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

    TFNItemsDataViewControllerBackingStore *backingStore = self.backingStore;
    NSUInteger sectionCount = [self.sections count];
    if (sectionCount >= 1) {
        TFNSettingsNavigationItem *wddSettings = [[%c(TFNSettingsNavigationItem) alloc] initWithTitle:@"WddTwitter" detail:@"自定义推特过滤与界面调整" iconName:nil controllerFactory:^UIViewController *{
            return [[WDDSettingsViewController alloc] initWithAccount:self.account];
        }];

        // Try setting a gear icon
        UIImage *settingsIcon = [UIImage systemImageNamed:@"gearshape.fill"];
        if (settingsIcon) {
            [wddSettings setValue:settingsIcon forKey:@"_icon"];
        }

        if ([backingStore respondsToSelector:@selector(insertSection:atIndex:)]) {
            [backingStore insertSection:0 atIndex:sectionCount];
        } else {
            [backingStore _tfn_insertSection:0 atIndex:sectionCount];
        }
        
        if ([backingStore respondsToSelector:@selector(insertItem:atIndexPath:)]) {
            [backingStore insertItem:wddSettings atIndexPath:[NSIndexPath indexPathForRow:0 inSection:sectionCount]];
        } else {
            [backingStore _tfn_insertItem:wddSettings atIndexPath:[NSIndexPath indexPathForRow:0 inSection:sectionCount]];
        }
    }
}
%end

%hook T1SettingsViewController
- (void)viewWillAppear:(BOOL)arg1 {
    %orig;
    
    if (objc_getAssociatedObject(self, @selector(viewWillAppear:)) != nil) {
        return;
    }
    objc_setAssociatedObject(self, @selector(viewWillAppear:), @YES, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

    NSUInteger sectionCount = [self.sections count];
    if (sectionCount >= 1) {
        TFNItemsDataViewControllerBackingStore *backingStore = self.backingStore;
        [backingStore insertSection:0 atIndex:sectionCount];
        [backingStore insertItem:@"Row 0" atIndexPath:[NSIndexPath indexPathForRow:0 inSection:sectionCount]];
        [backingStore insertItem:@"Row 1" atIndexPath:[NSIndexPath indexPathForRow:1 inSection:sectionCount]];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger customSectionIndex = [self.sections count] - 1;
    if (indexPath.section == customSectionIndex && indexPath.row == 1) {
        TFNTextCell *tweakCell = [[%c(TFNTextCell) alloc] init];
        [tweakCell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        [tweakCell.textLabel setText:@"WddTwitter"];
        return tweakCell;
    } else if (indexPath.section == customSectionIndex && indexPath.row == 0) {
        TFNTextCell *headerCell = [[%c(TFNTextCell) alloc] init];
        [headerCell setBackgroundColor:[UIColor clearColor]];
        headerCell.textLabel.textColor = [UIColor colorWithRed:0.40 green:0.47 blue:0.53 alpha:1.0];
        [headerCell.textLabel setText:@"王导导定制功能"];
        return headerCell;
    }
    return %orig;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger customSectionIndex = [self.sections count] - 1;
    if (indexPath.section == customSectionIndex && indexPath.row == 1) {
        WDDSettingsViewController *vc = [[WDDSettingsViewController alloc] initWithAccount:self.account];
        [self.navigationController pushViewController:vc animated:YES];
    } else {
        %orig;
    }
}
%end
