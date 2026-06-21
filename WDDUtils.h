//
//  WDDUtils.h
//  wddtwitter
//

#import <UIKit/UIKit.h>

extern __weak UIViewController *WDDActiveViewController;
extern BOOL WDDActiveViewControllerIsDetail;


BOOL WDDIsViewModelReply(id viewModel);
BOOL WDDIsCurrentActiveContextDetail(void);
UIViewController *WDDViewControllerForView(UIView *view);
BOOL WDDIsFocalContext(UIView *view);
