//
//  WDDUIComponents.h
//  wddtwitter
//

#import <UIKit/UIKit.h>
#import "BHDimPalette.h"
#import "TWHeaders.h"
#import <objc/runtime.h>

@interface ModernSettingsTableViewCell : UITableViewCell
@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *subtitleLabel;
@property (nonatomic, strong) UIImageView *chevronImageView;
- (void)configureWithTitle:(NSString *)title subtitle:(NSString *)subtitle iconName:(NSString *)iconName;
@end

@interface ModernSettingsSimpleButtonCell : UITableViewCell
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIImageView *chevronImageView;
- (void)configureWithTitle:(NSString *)title;
@end

@interface ModernSettingsCompactButtonCell : UITableViewCell
@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *subtitleLabel;
@property (nonatomic, strong) UIImageView *chevronImageView;
- (void)configureWithTitle:(NSString *)title subtitle:(NSString *)subtitle;
- (void)configureWithTitle:(NSString *)title subtitle:(NSString *)subtitle iconName:(NSString *)iconName;
@end

@interface ModernSettingsToggleCell : UITableViewCell
@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *subtitleLabel;
@property (nonatomic, strong) UISwitch *toggleSwitch;
- (void)configureWithTitle:(NSString *)title subtitle:(NSString *)subtitle;
- (void)configureWithTitle:(NSString *)title subtitle:(NSString *)subtitle iconName:(NSString *)iconName;
- (void)addTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)events;
@end
