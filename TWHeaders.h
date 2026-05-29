//
//  TWHeaders.h
//  wddtwitter
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <objc/runtime.h>

@interface TFNTwitterAccount : NSObject
@property (nonatomic, strong) NSString *displayFullName;
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *displayUsername;
@property (nonatomic, strong) NSString *fullName;
@end

@interface TFNTableView : UITableView
@end

@interface TFNDataViewController : UIViewController
@property(readonly, nonatomic) TFNTableView *tableView;
@end

@interface TFNItemsDataViewController : TFNDataViewController
@property(copy, nonatomic) NSArray *sections;
- (id)itemAtIndexPath:(id)arg1;
@end

@interface TFNItemsDataViewControllerBackingStore : NSObject
- (void)insertSection:(id)section atIndex:(NSUInteger)index;
- (void)insertItem:(id)item atIndexPath:(NSIndexPath *)indexPath;
- (void)_tfn_insertSection:(id)section atIndex:(NSUInteger)index;
- (void)_tfn_insertItem:(id)item atIndexPath:(NSIndexPath *)indexPath;
@end

@interface T1GenericSettingsViewController : UIViewController
@property (nonatomic, strong) TFNItemsDataViewControllerBackingStore *backingStore;
@property (nonatomic, strong) NSArray *sections;
@property (nonatomic, strong) TFNTwitterAccount *account;
@end

@interface T1SettingsViewController : UIViewController
@property (nonatomic, strong) TFNItemsDataViewControllerBackingStore *backingStore;
@property (nonatomic, strong) NSArray *sections;
@property (nonatomic, strong) TFNTwitterAccount *account;
@end

@interface TFNSettingsNavigationItem : NSObject
- (instancetype)initWithTitle:(NSString *)arg1 detail:(NSString *)arg2 iconName:(NSString *)arg3 controllerFactory:(UIViewController* (^)(void))arg4;
- (instancetype)initWithTitle:(NSString *)arg1 detail:(NSString *)arg2 systemIconName:(NSString *)arg3 controllerFactory:(UIViewController* (^)(void))arg4;
- (instancetype)initWithTitle:(NSString *)arg1 detail:(NSString *)arg2 controllerFactory:(UIViewController* (^)(void))arg4;
@end

@interface TAEStandardFontGroup : NSObject
+ (instancetype)sharedFontGroup;
- (UIFont *)bodyBoldFont;
- (UIFont *)subtext2Font;
- (UIFont *)headline2BoldFont;
@end

@interface UIImage (TwitterVectors)
+ (UIImage *)tfn_vectorImageNamed:(NSString *)name
                         fitsSize:(CGSize)size
                        fillColor:(UIColor *)fillColor;
@end

@interface T1StatusView : UIView
- (id)itemAtIndexPath:(id)arg2;
@end

@interface T1StandardStatusView : UIView
@end

@interface TFNTextCell : UITableViewCell
@end

@interface UIView (TwitterViewModels)
- (id)viewModel;
@end

@interface TAETwitterColorPaletteSettingInfo : NSObject
@property (readonly, nonatomic) id colorPalette;
@property (readonly, nonatomic) BOOL isDark;
@end

@interface TAEColorSettings : NSObject
+ (instancetype)sharedSettings;
- (id)currentColorPalette;
- (id)colorPalette;
- (id)tabBarItemColor;
- (id)textColor;
@end
