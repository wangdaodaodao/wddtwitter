#import <UIKit/UIKit.h>

extern __weak UIViewController *WDDActiveViewController;
extern BOOL WDDActiveViewControllerIsDetail;

extern _Thread_local BOOL g_wddThreadFocalLayout;
extern _Thread_local BOOL g_wddThreadCollapseUnifiedCard;

BOOL WDDIsViewModelReply(id viewModel);
BOOL WDDIsCurrentActiveContextDetail(void);
UIViewController *WDDViewControllerForView(UIView *view);
BOOL WDDIsFocalContext(UIView *view);

BOOL WDDIsMediaViewerContext(UIView *view);
BOOL WDDIsMediaViewerController(UIViewController *vc);

BOOL WDDIsFocalStatusView(UIView *view);

BOOL WDDShouldHideTimelineMedia(UIView *view);

BOOL WDDIsInFocalLayout(void);

BOOL WDDShouldHideTranslation(void);

BOOL WDDShouldHideProbableSpam(void);
