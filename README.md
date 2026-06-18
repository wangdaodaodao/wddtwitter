# WddTwitter (王导导推特增强插件)

这是一个基于 iOS Theos 开发的 Twitter (X) 客户端界面增强与过滤功能微调插件（Tweak）。通过注入 App 运行期方法（Hooking），实现推文内容过滤、多余 UI 隐藏以及界面自适应美化。

详细功能介绍及更新说明请参考官方文档：[wangdaodao.me/wddtwitter/](https://wangdaodao.me/wddtwitter/)

---

## 功能特性

### 1. UI 界面净化与隐藏


### 2. 交互体验提升


### 3. 智能回复过滤机制

---

## 项目结构

```text
├── Makefile                   # Theos 项目构建配置文件
├── control                    # Debian 软件包控制信息
├── wddtwitter.plist           # 注入目标配置 (com.atebits.Tweetie2)
├── build.py                   # 自动化版本自增编译打包脚本
│
├── WDDTweak.x                 # 核心 Logos Hook 钩子逻辑实现
├── WDDManager.h / .m          # 偏好设置数据存取及管理类
├── WDDSettingsViewController.h / .m  # 插件二级设置页面控制器（原生风格）
├── WDDUIComponents.h / .m     # 插件设置页定制的 Cell 元素组件
└── BHDimPalette.h / .m        # 主题调色板适配（支持 Twitter 暗黑及 Dim Mode 蓝灰色调）
```

---

## 编译与打包

### 前提条件
1. 拥有装有 macOS 的设备，并安装好 [Theos](https://theos.dev/) 越狱开发工具链。
2. 确保环境变量 `$THEOS` 已正确配置指向你的 Theos 目录。
3. 本机有 `python3` 环境以运行辅助打包脚本。

