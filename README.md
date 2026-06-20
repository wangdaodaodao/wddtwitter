# WddTwitter (王导导推特增强插件)

这是一个基于 iOS Theos 开发的 Twitter (X) 客户端界面增强与过滤功能微调插件（Tweak）。通过注入 App 运行期方法（Hooking），实现推文内容过滤、多余 UI 隐藏以及界面自适应美化。

详细功能介绍，界面预览，及更新说明：请参考官方文档：

[wangdaodao.me/wddtwitter/](https://wangdaodao.me/wddtwitter/)

---

## 功能特性

### 1. UI 界面净化与隐藏


### 2. 交互体验提升


### 3. 智能回复过滤机制

---

## 项目结构

```text
├── Makefile                   # Theos 项目构建配置文件（需在此处注册新源文件）
├── control                    # Debian 软件包控制信息
├── wddtwitter.plist           # 注入目标配置 (com.atebits.Tweetie2)
├── build.py                   # 自动化版本自增编译打包脚本
│
├── WDDTweak.x                 # 插件入口加载器（仅包含 %ctor 构造器，输出加载日志）
├── WDDUtils.h / .m            # 公用状态/环境上下文判断工具类（如 isFocalContext）
├── WDDManager.h / .m          # 偏好设置（用户开关配置）管理类
├── WDDSettingsViewController.h / .m  # 插件二级设置页面控制器（原生风格）
├── WDDUIComponents.h / .m     # 插件设置页定制的 Cell 元素组件
├── BHDimPalette.h / .m        # 主题调色板适配（支持 Twitter 纯黑及 Dim Mode 蓝灰色调）
│
├── WDDFilters.x               # [模块] 消息与回复过滤 Hooks（关键词、正则、表情）
├── WDDLayout.x                # [模块] UI界面定制 Hooks（头像、蓝V、标签隐藏、单图大小）
├── WDDGrok.x                  # [模块] Grok 功能屏蔽 Hooks（翻译、下载/编辑按钮遮罩、配置开关）
├── WDDViewCount.x             # [模块] 动态 Swizzling 浏览量隐藏 Hooks
├── WDDGestures.x              # [模块] 禁用长按菜单手势 Hooks
└── WDDSettings.x              # [模块] 原生设置入口注入 Hooks
```

---

## 如何新增功能 (开发指引)

若以后需要为插件新增定制功能或界面控制，请按照以下步骤进行：

### 第一步：在 `WDDManager` 中注册配置开关
1. 在 [WDDManager.h](file:///Users/wangdaodao/编程/tweak/wddtwitter/WDDManager.h) 中添加新功能的开关方法声明：
   ```objc
   + (BOOL)myNewFeatureEnabled;
   ```
2. 在 [WDDManager.m](file:///Users/wangdaodao/编程/tweak/wddtwitter/WDDManager.m) 中实现该方法，绑定本地 `NSUserDefaults` 存储键值：
   ```objc
   + (BOOL)myNewFeatureEnabled {
       return [[NSUserDefaults standardUserDefaults] boolForKey:@"wdd_my_new_feature"];
   }
   ```

### 第二步：在设置界面添加开关 UI
在 [WDDSettingsViewController.m](file:///Users/wangdaodao/编程/tweak/wddtwitter/WDDSettingsViewController.m) 的 `self.settings` 数组中，增加一行配置项字典：
```objc
@{ @"key": @"wdd_my_new_feature", @"title": @"新功能标题", @"subtitle": @"新功能描述说明文案", @"default": @NO, @"type": @"toggle" },
```
设置页会自动渲染该 Toggle 开关，并在用户点击时自动存取 `wdd_my_new_feature` 键值。

### 第三步：编写 Hook 逻辑
* **如果属于已有功能领域**：
  直接在对应的模块文件（如回复过滤改 `WDDFilters.x`，界面改 `WDDLayout.x`）中编写 `%hook` 钩子。在钩子内通过 `[WDDManager myNewFeatureEnabled]` 判断是否启用。
* **如果属于全新的功能品类**（例如想写一个“生物识别锁”功能）：
  1. 新建一个 `.x` 文件，例如 `WDDBiometrics.x`。
  2. 导入头文件并在文件顶部引入公用工具：
     ```objc
     #import "WDDManager.h"
     #import "WDDUtils.h"
     #import "TWHeaders.h"
     #import <UIKit/UIKit.h>
     ```
  3. 编写你的 `%hook` 类和方法逻辑。如果使用了特殊的 Logos `%group`（如需要延时启用），需在文件底部添加 `%ctor { %init; %init(MyGroup); }` 构造块；若是常规 Hook，无需写 `%ctor`，Logos 会自动生成默认加载器。
  4. **如果需要用到公用的状态判定（如是否在正文页）**，可直接调用 `WDDIsFocalContext(self)`，无需重复造轮子。若有新的公用函数，可在 `WDDUtils.h/.m` 中添加。

### 第四步：更新 Makefile (若新建了文件)
如果新建了 `.x` 或 `.m` 文件，必须在 [Makefile](file:///Users/wangdaodao/编程/tweak/wddtwitter/Makefile) 的 `wddtwitter_FILES` 变量末尾追加新文件名，例如：
```makefile
wddtwitter_FILES = ... WDDSettings.x WDDBiometrics.x
```

### 第五步：编译打包
在项目根目录下运行编译脚本，进行代码合法性检查：
```bash
python3 build.py
```

---

## 编译与打包

### 前提条件
1. 拥有装有 macOS 的设备，并安装好 [Theos](https://theos.dev/) 越狱开发工具链。
2. 确保环境变量 `$THEOS` 已正确配置指向你的 Theos 目录。
3. 本机有 `python3` 环境以运行辅助打包脚本。

