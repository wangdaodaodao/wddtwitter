#import "WDDSettingsViewController.h"
#import "TWHeaders.h"
#import <objc/runtime.h>
#import <stdarg.h>

// ==============================================================
// Settings Page Entry Injection
// ==============================================================
// 版本适配说明（基于 X 12.35）：
//
// 【12.35 起 · 现行】
//   设置根页 = XSettings.SettingsListViewController
//              ObjC 名 _TtC9XSettings26SettingsListViewController
//              位于 Frameworks/XAppLibraries.framework/XAppLibraries
//   它继承 TFNViewController，但**不使用 TFN 数据源**：
//       - 没有 sections / backingStore
//       - 行数据是纯 Swift 结构体 SettingsRowDefinition / SettingsSectionDefinition
//         （还有 SettingsRowID / SettingsRowKind / SettingsRowLink / SettingsRowActivation）
//       - 列表由自定义 ivar `list` 驱动，ObjC 侧无法构造 Swift 结构体
//   => setSections: 注入对它完全无效（这正是此前所有尝试失效的原因）。
//   因此改为 **UI 层注入**：在该 VC 的导航栏放一个入口按钮；
//   若导航栏不可用（无 nav / 被隐藏 / 两侧都被占），退化为右下角悬浮按钮。
//
// 【12.28 及更早 · 兼容分支】
//   T1GenericSettingsViewController（TFNItemsDataViewController 子类）走 setSections: 注入
//   T1SettingsViewController（更早版本）走 backingStore 注入
//   类不存在时 Logos 自动跳过，无副作用。
// ==============================================================

static NSString *const kWDDEntryTitle  = @"WddTwitter";
static NSString *const kWDDEntryDetail = @"自定义推特过滤与界面调整";

#pragma mark - 日志（排查用，写入 App 沙盒 Documents/wdd_entry.log）

static void WDDEntryLog(NSString *fmt, ...) {
    va_list args;
    va_start(args, fmt);
    NSString *msg = [[NSString alloc] initWithFormat:fmt arguments:args];
    va_end(args);

    NSLog(@"[WDD-ENTRY] %@", msg);

    static NSString *path = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/wdd_entry.log"];
    });
    FILE *fp = fopen(path.UTF8String, "a");
    if (fp) {
        fputs([[msg stringByAppendingString:@"\n"] UTF8String], fp);
        fclose(fp);
    }
}

#pragma mark - 入口按钮的 target

@interface WDDEntryTarget : NSObject
@property (nonatomic, weak) UIViewController *host;
@property (nonatomic, weak) UIViewController *presented;
@end

@implementation WDDEntryTarget

- (void)openSettings:(id)sender {
    UIViewController *host = self.host;
    if (!host) {
        WDDEntryLog(@"openSettings: host 已释放，放弃");
        return;
    }

    // account 仅用于透传（WDDSettingsViewController 内部设置项为硬编码，不依赖 account）
    TFNTwitterAccount *account = nil;
    @try { account = [host valueForKey:@"account"]; } @catch (__unused NSException *e) {}

    WDDSettingsViewController *vc = [[WDDSettingsViewController alloc] initWithAccount:account];

    UINavigationController *nav = host.navigationController;
    if (nav && !nav.isNavigationBarHidden) {
        WDDEntryLog(@"openSettings: push 到现有导航栈");
        [nav pushViewController:vc animated:YES];
        return;
    }

    WDDEntryLog(@"openSettings: present 模态导航控制器");
    UINavigationController *wrap = [[UINavigationController alloc] initWithRootViewController:vc];
    wrap.modalPresentationStyle = UIModalPresentationFullScreen;
    vc.navigationItem.leftBarButtonItem =
        [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                      target:self
                                                      action:@selector(closeModal:)];
    self.presented = wrap;
    [host presentViewController:wrap animated:YES completion:nil];
}

- (void)closeModal:(id)sender {
    UIViewController *vc = self.presented;
    if (vc) {
        [vc dismissViewControllerAnimated:YES completion:nil];
        return;
    }
    // 兜底：从 key window 往上找最顶层的 presented
    UIViewController *top = nil;
    for (UIWindow *w in [UIApplication sharedApplication].windows) {
        if (w.isKeyWindow) { top = w.rootViewController; break; }
    }
    while (top.presentedViewController) top = top.presentedViewController;
    [top dismissViewControllerAnimated:YES completion:nil];
}

@end

#pragma mark - UI 层注入

static const void *kWDDEntryInjectedKey = &kWDDEntryInjectedKey;
static const void *kWDDEntryTargetKey   = &kWDDEntryTargetKey;

// 注入结果只写日志，不在界面上弹任何提示条
static void WDDInstallFloatingButton(UIViewController *host, WDDEntryTarget *target) {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    btn.translatesAutoresizingMaskIntoConstraints = NO;
    btn.backgroundColor = [UIColor colorWithRed:0.11 green:0.63 blue:0.95 alpha:1.0];
    [btn setTitle:@"W" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont boldSystemFontOfSize:24];
    btn.layer.cornerRadius = 28;
    btn.layer.shadowColor = [UIColor blackColor].CGColor;
    btn.layer.shadowOpacity = 0.28;
    btn.layer.shadowRadius = 8;
    btn.layer.shadowOffset = CGSizeMake(0, 3);
    btn.accessibilityLabel = kWDDEntryTitle;
    [btn addTarget:target action:@selector(openSettings:) forControlEvents:UIControlEventTouchUpInside];

    [host.view addSubview:btn];
    [NSLayoutConstraint activateConstraints:@[
        [btn.trailingAnchor constraintEqualToAnchor:host.view.safeAreaLayoutGuide.trailingAnchor constant:-20],
        [btn.bottomAnchor   constraintEqualToAnchor:host.view.safeAreaLayoutGuide.bottomAnchor   constant:-24],
        [btn.widthAnchor    constraintEqualToConstant:56],
        [btn.heightAnchor   constraintEqualToConstant:56],
    ]];
}

static void WDDInstallEntry(UIViewController *host) {
    if (!host) return;
    if (objc_getAssociatedObject(host, kWDDEntryInjectedKey)) return;

    WDDEntryTarget *target = [WDDEntryTarget new];
    target.host = host;

    UINavigationController *nav = host.navigationController;
    NSString *where = nil;

    if (nav && !nav.isNavigationBarHidden) {
        UIBarButtonItem *btn =
            [[UIBarButtonItem alloc] initWithTitle:kWDDEntryTitle
                                             style:UIBarButtonItemStylePlain
                                            target:target
                                            action:@selector(openSettings:)];
        if (host.navigationItem.rightBarButtonItem == nil) {
            host.navigationItem.rightBarButtonItem = btn;
            where = @"导航栏右上角";
        } else if (host.navigationItem.leftBarButtonItem == nil) {
            host.navigationItem.leftBarButtonItem = btn;
            where = @"导航栏左上角";
        }
    }

    if (!where) {
        WDDInstallFloatingButton(host, target);
        where = @"右下角悬浮按钮";
    }

    WDDEntryLog(@"入口已放入%@", where);

    // target 必须被持有：UIControl / UIBarButtonItem 都不强引用 target
    objc_setAssociatedObject(host, kWDDEntryTargetKey, target, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(host, kWDDEntryInjectedKey, @YES, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - 12.35+ Swift 设置页（手工安装 hook，带重试）

// 为什么不用 %hook：
//   Logos 生成的注册代码是 `MSHookMessageEx(objc_getClass("..."), ...)`，对类为 NULL 不做保护。
//   XSettings 类位于 XAppLibraries.framework，若该镜像在 tweak 初始化时尚未完成 ObjC 注册，
//   %hook 就会静默失效（不报错、不生效）。这里改为手工安装 + 失败重试，行为确定。

typedef void (*WDDVoidBOOLIMP)(id, SEL, BOOL);

static WDDVoidBOOLIMP _wddOrigViewWillAppear = NULL;
static WDDVoidBOOLIMP _wddOrigViewDidAppear  = NULL;
static BOOL _wddSwiftHookInstalled = NO;
static int  _wddSwiftHookRetries   = 0;

// 只替换「该类自己定义」的方法：若 viewWillAppear: 是从 UIViewController 继承来的，
// class_copyMethodList 里就找不到，直接跳过，绝不会误伤所有 VC。
static BOOL WDDHookOwnMethod(Class cls, SEL sel, IMP newImp, IMP *origImp) {
    unsigned int count = 0;
    Method *list = class_copyMethodList(cls, &count);
    BOOL ok = NO;
    for (unsigned int i = 0; i < count; i++) {
        if (method_getName(list[i]) == sel) {
            *origImp = method_getImplementation(list[i]);
            method_setImplementation(list[i], newImp);
            ok = YES;
            break;
        }
    }
    free(list);
    return ok;
}

static void WDDTryInstallSwiftHook(void);

static void wddSettingsList_viewWillAppear(id self, SEL _cmd, BOOL animated) {
    if (_wddOrigViewWillAppear) _wddOrigViewWillAppear(self, _cmd, animated);

    UIViewController *host = (UIViewController *)self;
    UINavigationController *nav = host.navigationController;

    WDDEntryLog(@"命中 SettingsListViewController | nav=%@ barHidden=%d right=%@ left=%@",
                nav ? NSStringFromClass([nav class]) : @"nil",
                (int)(nav ? nav.isNavigationBarHidden : 0),
                host.navigationItem.rightBarButtonItem,
                host.navigationItem.leftBarButtonItem);

    WDDInstallEntry(host);
}

static void wddSettingsList_viewDidAppear(id self, SEL _cmd, BOOL animated) {
    if (_wddOrigViewDidAppear) _wddOrigViewDidAppear(self, _cmd, animated);
    // 兜底：导航栏按钮有时在 viewWillAppear 之后才被重设
    WDDInstallEntry((UIViewController *)self);
}

static void WDDTryInstallSwiftHook(void) {
    if (_wddSwiftHookInstalled) return;

    Class cls = objc_getClass("_TtC9XSettings26SettingsListViewController");
    if (!cls) {
        if (++_wddSwiftHookRetries <= 120) {          // 0.5s × 120 ≈ 60s
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)),
                           dispatch_get_main_queue(), ^{ WDDTryInstallSwiftHook(); });
        } else {
            WDDEntryLog(@"放弃：60s 内未找到 SettingsListViewController");
        }
        return;
    }

    BOOL a = WDDHookOwnMethod(cls, @selector(viewWillAppear:),
                              (IMP)wddSettingsList_viewWillAppear, (IMP *)&_wddOrigViewWillAppear);
    BOOL b = WDDHookOwnMethod(cls, @selector(viewDidAppear:),
                              (IMP)wddSettingsList_viewDidAppear, (IMP *)&_wddOrigViewDidAppear);
    if (a || b) {
        _wddSwiftHookInstalled = YES;
        WDDEntryLog(@"Swift 设置页 hook 安装成功 (viewWillAppear=%d viewDidAppear=%d)", a, b);
    } else {
        _wddSwiftHookInstalled = YES;                 // 类存在但无自有方法，不再重试
        WDDEntryLog(@"警告：类已找到但未找到自有的 viewWillAppear:/viewDidAppear:");
    }
}

%ctor {
    WDDEntryLog(@"===== wddtwitter 设置入口模块加载 =====");
    WDDTryInstallSwiftHook();

    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidBecomeActiveNotification
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *note) {
        WDDTryInstallSwiftHook();
    }];
}

#pragma mark - 12.35 早期 / 12.28 通用设置页（TFN 数据源路径）

static BOOL WDDItemIsOurEntry(id item) {
    if (!item) return NO;
    if (![item respondsToSelector:NSSelectorFromString(@"title")]) return NO;
    id title = nil;
    @try { title = [item valueForKey:@"title"]; } @catch (__unused NSException *e) { return NO; }
    return [title isKindOfClass:[NSString class]] && [title isEqualToString:kWDDEntryTitle];
}

static BOOL WDDSectionsContainOurEntry(NSArray *sections) {
    for (id section in sections) {
        if ([section isKindOfClass:[NSArray class]]) {
            for (id item in (NSArray *)section) {
                if (WDDItemIsOurEntry(item)) return YES;
            }
        } else if (WDDItemIsOurEntry(section)) {
            return YES;
        }
    }
    return NO;
}

// 只在「设置栈中的第一个设置页」注入，避免每个子页都出现入口。
static BOOL WDDIsRootSettingsVC(UIViewController *vc) {
    UINavigationController *nav = vc.navigationController;
    if (!nav) return YES;                       // 被单独 present 时也允许注入
    Class settingsCls = objc_getClass("T1GenericSettingsViewController");
    for (UIViewController *v in nav.viewControllers) {
        if (v == vc) return YES;
        if (!settingsCls || ![v isKindOfClass:settingsCls]) return NO;
    }
    return NO;
}

// 把入口拼进 sections，返回新数组；已在则返回 nil
static NSArray *WDDArrayByInsertingEntry(UIViewController *vc, NSArray *sections) {
    if (![sections isKindOfClass:[NSArray class]]) return nil;
    if (WDDSectionsContainOurEntry(sections)) return nil;

    Class itemCls = objc_getClass("TFNSettingsNavigationItem");
    if (!itemCls) return nil;

    id account = nil;
    @try { account = [vc valueForKey:@"account"]; } @catch (__unused NSException *e) {}

    TFNSettingsNavigationItem *item =
        [[itemCls alloc] initWithTitle:kWDDEntryTitle
                                detail:kWDDEntryDetail
                              iconName:nil
                     controllerFactory:^UIViewController *{
            return [[WDDSettingsViewController alloc] initWithAccount:account];
        }];
    if (!item) return nil;

    @try {
        UIImage *icon = [UIImage systemImageNamed:@"gearshape.fill"];
        if (icon) [item setValue:icon forKey:@"icon"];
    } @catch (__unused NSException *e) {}

    NSMutableArray *newSections = [sections mutableCopy] ?: [NSMutableArray array];
    [newSections insertObject:@[ item ] atIndex:0];
    return newSections;
}

static void WDDInjectSettingsEntry(UIViewController *vc) {
    if (!WDDIsRootSettingsVC(vc)) return;

    NSArray *sections = nil;
    @try { sections = [vc valueForKey:@"sections"]; } @catch (__unused NSException *e) { return; }
    if (![sections isKindOfClass:[NSArray class]]) return;   // 数据尚未构建

    NSArray *newSections = WDDArrayByInsertingEntry(vc, sections);
    if (!newSections) return;                                // 已注入或无法构造

    [vc setValue:newSections forKey:@"sections"];            // 等价于 setSections:
}

%hook T1GenericSettingsViewController

- (void)viewWillAppear:(BOOL)animated {
    %orig;
    WDDInjectSettingsEntry(self);
}

- (void)viewDidAppear:(BOOL)animated {
    %orig;

    static const void *kWDDRetryKey = &kWDDRetryKey;
    if (objc_getAssociatedObject(self, kWDDRetryKey)) return;

    NSArray *sections = nil;
    @try { sections = [self valueForKey:@"sections"]; } @catch (__unused NSException *e) {}
    if ([sections isKindOfClass:[NSArray class]] && WDDSectionsContainOurEntry(sections)) return;

    objc_setAssociatedObject(self, kWDDRetryKey, @YES, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    WDDInjectSettingsEntry(self);
}

- (void)setSections:(NSArray *)sections {
    if (sections.count > 0 && WDDIsRootSettingsVC(self)) {
        NSArray *injected = WDDArrayByInsertingEntry(self, sections);
        if (injected) {
            %orig(injected);
            return;
        }
    }
    %orig;
}

%end
