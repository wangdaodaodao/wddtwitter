//
//  WDDUtils.h
//  wddtwitter
//

#import <UIKit/UIKit.h>

BOOL WDDIsViewModelReply(id viewModel);
BOOL WDDIsCurrentActiveContextDetail(void);
UIViewController *WDDViewControllerForView(UIView *view);
BOOL WDDIsFocalContext(UIView *view);
