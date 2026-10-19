#import "TWHeaders.h"
#import <objc/runtime.h>
#import <stdarg.h>

// ==============================================================
// 临时诊断模块（定位设置页入口不显示的原因）
//
// 三级信号：
//   1. 启动红色横幅        → dylib 已加载
//   2. 顶部黑色 HUD        → 实时显示设置相关 VC 的真实类名与 sections 数量
//   3. Documents/wdd_settings_debug.log → 完整日志
//
// 定位完成后整体删除本文件及 Makefile 中的引用
// ==============================================================

@interface T1SettingsContainerController : UIViewController
@end

@interface T1SettingsViewControllers : NSObject
@end

static NSString *WDDBGLogPath(void) {
    static NSString *path = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/wdd_settings_debug.log"];
    });
    return path;
}

static void WDDBGLog(NSString *fmt, ...) {
    va_list args;
    va_start(args, fmt);
    NSString *msg = [[NSString alloc] initWithFormat:fmt arguments:args];
    va_end(args);

    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    df.dateFormat = @"HH:mm:ss.SSS";
    NSString *line = [NSString stringWithFormat:@"[%@] %@\n", [df stringFromDate:[NSDate date]], msg];

    NSLog(@"[WDD-DBG] %@", msg);

    FILE *fp = fopen(WDDBGLogPath().UTF8String, "a");
    if (fp) {
        fputs(line.UTF8String, fp);
        fclose(fp);
    }
}

static NSString *WDDBGDescribeStack(UINavigationController *nav) {
    if (!nav) return @"<无nav>";
    NSMutableArray *names = [NSMutableArray array];
    for (UIViewController *v in nav.viewControllers) {
        [names addObject:NSStringFromClass([v class])];
    }
    return [names componentsJoinedByString:@" > "];
}

#pragma mark - 屏幕 HUD

static __weak UIWindow *_wddKeyWindow = nil;
static UILabel *_wddHUD = nil;
static NSMutableArray *_wddLines = nil;
static BOOL _wddBannerShown = NO;

static UIWindow *WDDBGCurrentWindow(void) {
    if (_wddKeyWindow) return _wddKeyWindow;
    NSArray *windows = [UIApplication sharedApplication].windows;
    for (UIWindow *w in windows) {
        if (w.isKeyWindow) return w;
    }
    return windows.firstObject;
}

static void WDDBGShowHUD(NSString *line) {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!_wddLines) _wddLines = [NSMutableArray array];
        [_wddLines insertObject:line atIndex:0];
        while (_wddLines.count > 5) [_wddLines removeLastObject];

        UIWindow *window = WDDBGCurrentWindow();
        if (!window) return;

        if (!_wddHUD) {
            CGFloat top = window.safeAreaInsets.top + 8;
            _wddHUD = [[UILabel alloc] initWithFrame:CGRectMake(8, top, window.bounds.size.width - 16, 90)];
            _wddHUD.numberOfLines = 0;
            _wddHUD.font = [UIFont monospacedSystemFontOfSize:10 weight:UIFontWeightMedium];
            _wddHUD.textColor = [UIColor whiteColor];
            _wddHUD.backgroundColor = [UIColor colorWithWhite:0 alpha:0.78];
            _wddHUD.layer.cornerRadius = 6;
            _wddHUD.clipsToBounds = YES;
            _wddHUD.userInteractionEnabled = NO;
            _wddHUD.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            [window addSubview:_wddHUD];
        }
        _wddHUD.text = [NSString stringWithFormat:@" WDD 设置页诊断\n%@", [_wddLines componentsJoinedByString:@"\n"]];
        [_wddHUD sizeToFit];
        CGRect f = _wddHUD.frame;
        f.origin.x = 8;
        f.origin.y = window.safeAreaInsets.top + 8;
        f.size.width = window.bounds.size.width - 16;
        _wddHUD.frame = f;
        _wddHUD.alpha = 1.0;
    });
}

#pragma mark - 窗口：横幅 + 抓 key window

%hook UIWindow

- (void)makeKeyAndVisible {
    %orig;

    _wddKeyWindow = self;

    if (_wddBannerShown) return;
    _wddBannerShown = YES;

    dispatch_async(dispatch_get_main_queue(), ^{
        UILabel *banner = [[UILabel alloc] initWithFrame:CGRectZero];
        banner.text = @"✅ wddtwitter 已加载（诊断版）";
        banner.textAlignment = NSTextAlignmentCenter;
        banner.backgroundColor = [UIColor colorWithRed:0.85 green:0.12 blue:0.12 alpha:1.0];
        banner.textColor = [UIColor whiteColor];
        banner.font = [UIFont boldSystemFontOfSize:15];
        banner.numberOfLines = 2;
        banner.layer.cornerRadius = 10;
        banner.clipsToBounds = YES;
        banner.userInteractionEnabled = NO;

        UIWindow *keyWindow = self;
        CGSize size = keyWindow.bounds.size;
        banner.frame = CGRectMake(20, size.height - 140, size.width - 40, 52);
        banner.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        [keyWindow addSubview:banner];

        WDDBGLog(@"红色横幅已显示，dylib 确认在内存中");

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(15.0 * NSEC_PER_SEC)),
                       dispatch_get_main_queue(), ^{
            [banner removeFromSuperview];
        });
    });
}

%end

#pragma mark - 设置页（新版候选）

%hook T1GenericSettingsViewController

- (void)viewWillAppear:(BOOL)animated {
    %orig;

    NSArray *secs = nil;
    @try { secs = [self valueForKey:@"sections"]; } @catch (__unused NSException *e) {}

    WDDBGLog(@"【命中】T1GenericSettingsViewController viewWillAppear: class=%@ sections=%lu",
             NSStringFromClass([self class]), (unsigned long)[secs count]);
    WDDBGLog(@"      导航栈: %@", WDDBGDescribeStack(self.navigationController));

    WDDBGShowHUD([NSString stringWithFormat:@"GSVC sec=%lu", (unsigned long)[secs count]]);

    if ([secs isKindOfClass:[NSArray class]] && secs.count > 0) {
        id first = secs.firstObject;
        NSString *itemDesc = NSStringFromClass([first class]);
        if ([first isKindOfClass:[NSArray class]]) {
            NSMutableArray *items = [NSMutableArray array];
            for (id it in (NSArray *)first) [items addObject:NSStringFromClass([it class])];
            itemDesc = [NSString stringWithFormat:@"[%@]", [items componentsJoinedByString:@","]];
        }
        WDDBGShowHUD([NSString stringWithFormat:@"  sec[0]=%@", itemDesc]);
    }
}

%end

#pragma mark - 数据源：观察 sections 何时被写入

%hook TFNItemsDataViewController

- (void)setSections:(NSArray *)sections {
    NSString *cls = NSStringFromClass([self class]);
    if ([cls rangeOfString:@"Setting"].location != NSNotFound) {
        WDDBGLog(@"[setSections] %@ -> %lu 段", cls, (unsigned long)sections.count);
        WDDBGShowHUD([NSString stringWithFormat:@"%@ setSections=%lu", cls, (unsigned long)sections.count]);
    }
    %orig;
}

%end

#pragma mark - 设置容器与工厂

%hook T1SettingsContainerController

- (void)viewWillAppear:(BOOL)animated {
    %orig;
    id controllers = nil;
    @try { controllers = [self valueForKey:@"settingsControllers"]; } @catch (__unused NSException *e) {}
    WDDBGLog(@"【容器】T1SettingsContainerController settingsControllers=%@", controllers);
    WDDBGShowHUD([NSString stringWithFormat:@"Container children=%lu",
                  (unsigned long)[[self childViewControllers] count]]);
}

%end

%hook T1SettingsViewControllers

+ (UIViewController *)rootViewControllerForAccount:(id)account {
    UIViewController *vc = %orig;
    WDDBGLog(@"【工厂】rootViewControllerForAccount -> %@", NSStringFromClass([vc class]));
    WDDBGShowHUD([NSString stringWithFormat:@"Factory -> %@", NSStringFromClass([vc class])]);
    return vc;
}

%end

#pragma mark - 兜底：抓所有设置相关 VC

%hook UIViewController

- (void)viewWillAppear:(BOOL)animated {
    %orig;

    static NSUInteger counter = 0;
    if (counter > 300) return;
    counter++;

    NSString *cls = NSStringFromClass([self class]);
    if ([cls rangeOfString:@"Setting"].location != NSNotFound) {
        WDDBGLog(@"[VC] %@", cls);
        WDDBGShowHUD([NSString stringWithFormat:@"VC: %@", cls]);
    }
}

%end

#pragma mark - 加载确认

%ctor {
    WDDBGLog(@"===== wddtwitter dylib 已加载 (Tweak 生效) =====");
    WDDBGLog(@"沙盒路径: %@", NSHomeDirectory());
    WDDBGLog(@"Bundle: %@", [[NSBundle mainBundle] bundleIdentifier]);
}
