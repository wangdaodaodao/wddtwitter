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

// 精确版「当前是否在焦点推文布局中」：
// 只认 T1ConversationFocalStatusViewLayoutStateGenerator 在生成期间打的线程标记，
// 不看当前是哪个 ViewController。WDDIsFocalContext 会把整个「推文详情/会话页」
// 都算成焦点上下文，导致时间线里那些回复单元格的图片功能全部失效。
BOOL WDDIsInFocalLayout(void);
