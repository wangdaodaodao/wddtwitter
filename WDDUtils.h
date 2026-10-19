#import <UIKit/UIKit.h>

extern __weak UIViewController *WDDActiveViewController;
extern BOOL WDDActiveViewControllerIsDetail;

BOOL WDDIsViewModelReply(id viewModel);
BOOL WDDIsCurrentActiveContextDetail(void);
UIViewController *WDDViewControllerForView(UIView *view);
BOOL WDDIsFocalContext(UIView *view);

BOOL WDDIsMediaViewerContext(UIView *view);
BOOL WDDIsMediaViewerController(UIViewController *vc);

BOOL WDDShouldHideTimelineMedia(UIView *view);

BOOL WDDIsInFocalLayout(void);
