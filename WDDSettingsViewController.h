//
//  WDDSettingsViewController.h
//  wddtwitter
//

#import <UIKit/UIKit.h>

@class TFNTwitterAccount;

@interface WDDSettingsViewController : UIViewController
@property (nonatomic, strong) TFNTwitterAccount *account;
- (instancetype)initWithAccount:(TFNTwitterAccount *)account;
@end
