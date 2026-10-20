//
//  WDDSettingsViewController.m
//  wddtwitter
//

#import "WDDSettingsViewController.h"
#import "WDDUIComponents.h"
#import "TWHeaders.h"
#import "BHDimPalette.h"
#import "WDDManager.h"

@interface WDDSettingsViewController () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray<NSArray<NSDictionary *> *> *settings;
@property (nonatomic, strong) NSArray<NSString *> *sectionTitles;
@property (nonatomic, strong) NSArray<NSDictionary *> *authors;
@end

@implementation WDDSettingsViewController

- (instancetype)initWithAccount:(TFNTwitterAccount *)account {
    if ((self = [super init])) {
        self.account = account;
        self.settings = @[
            @[
                @{ @"key": @"hide_author_name", @"title": @"隐藏作者名字", @"subtitle": @"在推文中隐藏作者显示的姓名", @"icon": @"person.text.rectangle", @"default": @NO, @"type": @"toggle" },
                @{ @"key": @"hide_avatar", @"title": @"隐藏头像", @"subtitle": @"在推文中隐藏作者的头像（加宽内容）", @"icon": @"person.crop.circle.badge.xmark", @"default": @NO, @"type": @"toggle" },
                @{ @"key": @"hide_blue_verified", @"title": @"隐藏认证标识", @"subtitle": @"隐藏账号的蓝V、金V、灰V 认证图标", @"icon": @"checkmark.seal", @"default": @NO, @"type": @"toggle" },
                @{ @"key": @"wdd_hide_account_labels", @"title": @"隐藏账号标签", @"subtitle": @"隐藏“戏仿/自动化/游戏/类别”等账号标签", @"icon": @"tag", @"default": @NO, @"type": @"toggle" },
                @{ @"key": @"wdd_hide_disclosure_labels", @"title": @"隐藏推文底部标签", @"subtitle": @"隐藏推文底部的“付费合作/推广/AI生成”等标签", @"icon": @"text.badge.xmark", @"default": @NO, @"type": @"toggle" },
                @{ @"key": @"wdd_hide_timeline_view_count", @"title": @"隐藏浏览量数值", @"subtitle": @"隐藏时间线及推文详情内的浏览量（流量数值）", @"icon": @"chart.bar.xaxis", @"default": @NO, @"type": @"toggle" },
                @{ @"key": @"wdd_hide_translation_notice", @"title": @"屏蔽翻译提示", @"subtitle": @"隐藏推文底部的翻译来源和显示原文提示（含Grok）", @"icon": @"character.bubble", @"default": @NO, @"type": @"toggle" },
                @{ @"key": @"wdd_hide_probable_spam", @"title": @"屏蔽“可能的垃圾信息”", @"subtitle": @"隐藏会话中“显示可能的垃圾信息”提示行", @"icon": @"exclamationmark.bubble", @"default": @NO, @"type": @"toggle" },
                @{ @"key": @"wdd_hide_reply_to_indicator", @"title": @"屏蔽回复指示", @"subtitle": @"隐藏回复推文中的‘回复 @用户名’提示", @"icon": @"arrowshape.turn.up.left", @"default": @NO, @"type": @"toggle" },
                @{ @"key": @"wdd_hide_grok_buttons", @"title": @"隐藏Grok相关按钮", @"subtitle": @"隐藏贴文回复中Grok底部的编辑图片、下载Grok等按钮", @"icon": @"sparkles", @"default": @NO, @"type": @"toggle" },
                @{ @"key": @"wdd_disable_long_press_menu", @"title": @"禁用长按菜单", @"subtitle": @"禁止在时间线长按推文时弹出菜单或预览", @"icon": @"hand.tap", @"default": @NO, @"type": @"toggle" },
                @{ @"key": @"wdd_hide_source_attribution", @"title": @"隐藏来源标签", @"subtitle": @"隐藏推文正文下方的“来自 域名”来源行", @"icon": @"globe", @"default": @NO, @"type": @"toggle" }
            ],
            @[
                @{ @"key": @"wdd_enable_single_image_sizing", @"title": @"固定单图大小", @"subtitle": @"固定首页单张图片为 16:9 比例并居中裁剪", @"icon": @"arrow.up.left.and.arrow.down.right", @"default": @NO, @"type": @"toggle" },
                @{ @"key": @"wdd_hide_timeline_images", @"title": @"屏蔽首页图片和视频", @"subtitle": @"仅在首页时间线屏蔽图片和视频，进入详情页可查看", @"icon": @"photo.on.rectangle", @"default": @NO, @"type": @"toggle" },
                @{ @"key": @"wdd_hide_all_media", @"title": @"屏蔽全部图片和视频", @"subtitle": @"在首页、推文详情及回复中全部屏蔽图片和视频", @"icon": @"eye.slash", @"default": @NO, @"type": @"toggle" }
            ],
            @[
                @{ @"key": @"enable_reply_filter", @"title": @"回复关键词屏蔽", @"subtitle": @"开启后将根据关键词隐藏回复推文", @"icon": @"magnifyingglass", @"default": @NO, @"type": @"toggle" },
                @{ @"key": @"reply_keywords", @"title": @"设置屏蔽关键词", @"subtitle": @"点击设置（多个关键词请用中or英文逗号分隔）", @"icon": @"keyboard", @"type": @"button" },
                @{ @"key": @"enable_emoji_filter", @"title": @"屏蔽纯表情回复", @"subtitle": @"屏蔽无中文且无英文数字的回复，或超3个emoji且无中文的回复", @"icon": @"face.smiling", @"default": @NO, @"type": @"toggle" },
                @{ @"key": @"enable_regex_filter", @"title": @"回复正则屏蔽", @"subtitle": @"开启后将根据自定义正则表达式屏蔽回复", @"icon": @"curlybraces", @"default": @NO, @"type": @"toggle" },
                @{ @"key": @"reply_regexes", @"title": @"设置屏蔽正则表达式", @"subtitle": @"点击设置自定义正则（多条规则请换行分隔）", @"icon": @"chevron.left.forwardslash.chevron.right", @"type": @"button" }
            ]
        ];

        self.sectionTitles = @[@"界面", @"媒体", @"回复过滤", @"作者"];
        
        self.authors = @[
            @{ @"type": @"twitter", @"title": @"王导导", @"username": @"goodwdd", @"avatarURL": @"https://unavatar.io/x/goodwdd" },
            @{ @"type": @"wechat", @"title": @"关注公众号", @"subtitle": @"王导导 (点击复制并跳转微信)" }
        ];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"WddTwitter";
    self.view.backgroundColor = [BHDimPalette currentBackgroundColor];

    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    self.tableView.backgroundColor = [BHDimPalette currentBackgroundColor];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableView];
    
    [self setupFooterLabel];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.settings.count + 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section < (NSInteger)self.settings.count) {
        return self.settings[section].count;
    }
    return self.authors.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section < (NSInteger)self.settings.count) {
        NSDictionary *setting = self.settings[indexPath.section][indexPath.row];
        NSString *type = setting[@"type"];
        NSString *iconName = setting[@"icon"];

        if ([type isEqualToString:@"toggle"]) {
            ModernSettingsToggleCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ToggleCell"];
            if (!cell) {
                cell = [[ModernSettingsToggleCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ToggleCell"];
            }

            [cell configureWithTitle:setting[@"title"] subtitle:setting[@"subtitle"] iconName:iconName];

            BOOL value = [WDDManager boolForKey:setting[@"key"]];
            [cell.toggleSwitch removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
            cell.toggleSwitch.on = value;
            cell.toggleSwitch.tag = indexPath.section * 100 + indexPath.row;
            [cell.toggleSwitch addTarget:self action:@selector(toggleChanged:) forControlEvents:UIControlEventValueChanged];
            return cell;
        } else {
            ModernSettingsCompactButtonCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ButtonCell"];
            if (!cell) {
                cell = [[ModernSettingsCompactButtonCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ButtonCell"];
            }

            NSString *currentValue = [WDDManager stringForKey:setting[@"key"]];
            [cell configureWithTitle:setting[@"title"]
                            subtitle:currentValue ?: setting[@"subtitle"]
                            iconName:iconName];
            return cell;
        }
    } else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AuthorCell"];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"AuthorCell"];
            [self setupDeveloperCell:cell];
        }
        NSDictionary *author = self.authors[indexPath.row];
        [self configureDeveloperCell:cell withDeveloper:author];
        return cell;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSString *title = nil;
    if (section < (NSInteger)self.sectionTitles.count) {
        title = self.sectionTitles[section];
    }
    return title.length > 0 ? [self headerViewWithTitle:title] : nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return UITableViewAutomaticDimension;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section < (NSInteger)self.settings.count) {
        NSDictionary *setting = self.settings[indexPath.section][indexPath.row];
        if ([setting[@"type"] isEqualToString:@"button"]) {
            if ([setting[@"key"] isEqualToString:@"reply_regexes"]) {
                [self showMultilineInput:setting];
            } else {
                [self showKeywordInput:setting];
            }
        }
    } else {
        NSDictionary *author = self.authors[indexPath.row];
        if ([author[@"type"] isEqualToString:@"wechat"]) {
            [self followWeChatOfficialAccount];
        } else {
            [self openTwitterProfileWithUser:author];
        }
    }
}

- (void)followWeChatOfficialAccount {
    [[UIPasteboard generalPasteboard] setString:@"王导导"];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"已复制公众号名称"
                                                                   message:@"公众号名称“王导导”已复制到剪切板，请在微信中搜索关注。"
                                                            preferredStyle:UIAlertControllerStyleAlert];
                                                            
    [alert addAction:[UIAlertAction actionWithTitle:@"打开微信" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSURL *wechatURL = [NSURL URLWithString:@"weixin://"];
        if ([[UIApplication sharedApplication] canOpenURL:wechatURL]) {
            [[UIApplication sharedApplication] openURL:wechatURL options:@{} completionHandler:nil];
        }
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"好" style:UIAlertActionStyleCancel handler:nil]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (UIView *)headerViewWithTitle:(NSString *)title {
    UIView *headerView = [[UIView alloc] init];
    headerView.backgroundColor = [BHDimPalette currentBackgroundColor];

    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    titleLabel.text = title.uppercaseString;
    titleLabel.font = [UIFont systemFontOfSize:13 weight:UIFontWeightSemibold];

    Class TAEColorSettingsCls = objc_getClass("TAEColorSettings");
    id settings = [TAEColorSettingsCls sharedSettings];
    id currentPalette = [settings currentColorPalette];
    id colorPalette = [currentPalette colorPalette];
    UIColor *titleColor = [colorPalette performSelector:@selector(tabBarItemColor)];
    titleLabel.textColor = titleColor ?: [UIColor secondaryLabelColor];

    [headerView addSubview:titleLabel];

    [NSLayoutConstraint activateConstraints:@[
        [titleLabel.leadingAnchor constraintEqualToAnchor:headerView.leadingAnchor constant:16],
        [titleLabel.trailingAnchor constraintEqualToAnchor:headerView.trailingAnchor constant:-16],
        [titleLabel.topAnchor constraintEqualToAnchor:headerView.topAnchor constant:18],
        [titleLabel.bottomAnchor constraintEqualToAnchor:headerView.bottomAnchor constant:-6]
    ]];

    return headerView;
}

- (void)setupDeveloperCell:(UITableViewCell *)cell {
    cell.textLabel.text = nil;
    cell.detailTextLabel.text = nil;
    cell.imageView.image = nil;

    UIImageView *avatarImageView = [[UIImageView alloc] init];
    avatarImageView.translatesAutoresizingMaskIntoConstraints = NO;
    avatarImageView.layer.cornerRadius = 20;
    avatarImageView.clipsToBounds = YES;
    avatarImageView.contentMode = UIViewContentModeScaleAspectFill;
    avatarImageView.tag = 100;
    [cell.contentView addSubview:avatarImageView];

    UILabel *nameLabel = [[UILabel alloc] init];
    nameLabel.translatesAutoresizingMaskIntoConstraints = NO;
    nameLabel.tag = 101;
    nameLabel.adjustsFontForContentSizeCategory = YES;
    [cell.contentView addSubview:nameLabel];

    UILabel *usernameLabel = [[UILabel alloc] init];
    usernameLabel.translatesAutoresizingMaskIntoConstraints = NO;
    usernameLabel.tag = 102;
    usernameLabel.adjustsFontForContentSizeCategory = YES;
    [cell.contentView addSubview:usernameLabel];

    UIImageView *devChevron = [[UIImageView alloc] init];
    devChevron.translatesAutoresizingMaskIntoConstraints = NO;
    devChevron.tag = 103;
    devChevron.contentMode = UIViewContentModeScaleAspectFit;
    [cell.contentView addSubview:devChevron];

    [NSLayoutConstraint activateConstraints:@[
        [avatarImageView.leadingAnchor constraintEqualToAnchor:cell.contentView.leadingAnchor constant:16],
        [avatarImageView.centerYAnchor constraintEqualToAnchor:cell.contentView.centerYAnchor],
        [avatarImageView.widthAnchor constraintEqualToConstant:40],
        [avatarImageView.heightAnchor constraintEqualToConstant:40],

        [nameLabel.leadingAnchor constraintEqualToAnchor:avatarImageView.trailingAnchor constant:12],
        [nameLabel.trailingAnchor constraintEqualToAnchor:devChevron.leadingAnchor constant:-12],
        [nameLabel.topAnchor constraintEqualToAnchor:cell.contentView.topAnchor constant:12],

        [usernameLabel.leadingAnchor constraintEqualToAnchor:nameLabel.leadingAnchor],
        [usernameLabel.trailingAnchor constraintEqualToAnchor:devChevron.leadingAnchor constant:-12],
        [usernameLabel.topAnchor constraintEqualToAnchor:nameLabel.bottomAnchor constant:2],
        [usernameLabel.bottomAnchor constraintEqualToAnchor:cell.contentView.bottomAnchor constant:-12],

        [devChevron.trailingAnchor constraintEqualToAnchor:cell.contentView.trailingAnchor constant:-16],
        [devChevron.centerYAnchor constraintEqualToAnchor:cell.contentView.centerYAnchor],
        [devChevron.widthAnchor constraintEqualToConstant:14],
        [devChevron.heightAnchor constraintEqualToConstant:14]
    ]];

    cell.backgroundColor = [BHDimPalette currentBackgroundColor];
    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
}

- (void)configureDeveloperCell:(UITableViewCell *)cell withDeveloper:(NSDictionary *)developer {
    UIImageView *avatarImageView = [cell.contentView viewWithTag:100];
    UILabel *nameLabel = [cell.contentView viewWithTag:101];
    UILabel *usernameLabel = [cell.contentView viewWithTag:102];
    UIImageView *devChevron = [cell.contentView viewWithTag:103];

    id fontGroup = [objc_getClass("TAEStandardFontGroup") sharedFontGroup];
    Class TAEColorSettingsCls = objc_getClass("TAEColorSettings");
    id settings = [TAEColorSettingsCls sharedSettings];
    id currentPalette = [settings currentColorPalette];
    id colorPalette = [currentPalette colorPalette];
    UIColor *textColor = [colorPalette performSelector:@selector(textColor)];
    UIColor *subtitleColor = [colorPalette performSelector:@selector(tabBarItemColor)];

    nameLabel.text = developer[@"title"];
    nameLabel.font = [fontGroup performSelector:@selector(bodyBoldFont)] ?: [UIFont systemFontOfSize:14 weight:UIFontWeightBold];
    nameLabel.textColor = textColor;

    usernameLabel.text = developer[@"subtitle"] ?: [NSString stringWithFormat:@"@%@", developer[@"username"]];
    usernameLabel.font = [fontGroup performSelector:@selector(subtext2Font)] ?: [UIFont systemFontOfSize:12 weight:UIFontWeightRegular];
    usernameLabel.textColor = subtitleColor;

    devChevron.image = [UIImage tfn_vectorImageNamed:@"chevron_right" fitsSize:CGSizeMake(14, 14) fillColor:subtitleColor];

    NSString *type = developer[@"type"];
    if ([type isEqualToString:@"wechat"]) {
        avatarImageView.image = [UIImage systemImageNamed:@"bubble.left.and.bubble.right.fill"] ?: [UIImage systemImageNamed:@"message.fill"];
        avatarImageView.tintColor = [UIColor systemGreenColor];
    } else {
        avatarImageView.tintColor = nil;
        NSString *avatarURL = developer[@"avatarURL"];
        objc_setAssociatedObject(avatarImageView, @selector(configureDeveloperCell:withDeveloper:), avatarURL, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        if (avatarURL.length > 0) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:avatarURL]];
                UIImage *img = [UIImage imageWithData:data];
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSString *currentURL = objc_getAssociatedObject(avatarImageView, @selector(configureDeveloperCell:withDeveloper:));
                    if ([currentURL isEqualToString:avatarURL]) {
                        avatarImageView.image = img ?: [UIImage systemImageNamed:@"person.circle.fill"];
                    }
                });
            });
        } else {
            avatarImageView.image = [UIImage systemImageNamed:@"person.circle.fill"];
        }
    }
}

- (void)openTwitterProfileWithUser:(NSDictionary *)user {
    NSString *username = user[@"username"];
    if (username.length > 0) {
        NSString *urlPath = [NSString stringWithFormat:@"twitter://user?screen_name=%@", username];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlPath]
                                           options:@{}
                                 completionHandler:nil];
    }
}

- (void)showMultilineInput:(NSDictionary *)setting {
    NSString *key = setting[@"key"];
    NSString *currentValue = [WDDManager stringForKey:key];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:setting[@"title"]
                                                                   message:@"\n\n\n\n\n\n\n"
                                                            preferredStyle:UIAlertControllerStyleAlert];

    UIViewController *contentViewController = [[UIViewController alloc] init];
    contentViewController.preferredContentSize = CGSizeMake(270, 140);

    UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(10, 0, 250, 140)];
    textView.font = [UIFont systemFontOfSize:14.0];
    textView.layer.borderColor = [UIColor grayColor].CGColor;
    textView.layer.borderWidth = 0.5;
    textView.layer.cornerRadius = 5.0;
    textView.text = currentValue;

    [contentViewController.view addSubview:textView];
    [alert setValue:contentViewController forKey:@"contentViewController"];

    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSString *inputText = textView.text;
        if (inputText.length > 0) {
            [WDDManager setString:inputText forKey:key];
        } else {
            [WDDManager removeObjectForKey:key];
        }
        [self.tableView reloadData];
    }]];

    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)showKeywordInput:(NSDictionary *)setting {
    NSString *key = setting[@"key"];
    NSString *currentValue = [WDDManager stringForKey:key];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:setting[@"title"]
                                                                   message:setting[@"subtitle"]
                                                            preferredStyle:UIAlertControllerStyleAlert];

    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"关键词1,关键词2";
        textField.text = currentValue;
    }];

    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSString *inputText = alert.textFields.firstObject.text;
        if (inputText.length > 0) {
            [WDDManager setString:inputText forKey:key];
        } else {
            [WDDManager removeObjectForKey:key];
        }
        [self.tableView reloadData];
    }]];

    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (NSString *)pairedKeyForKey:(NSString *)key {
    if ([key isEqualToString:@"wdd_hide_all_media"]) return @"wdd_hide_timeline_images";
    if ([key isEqualToString:@"wdd_hide_timeline_images"]) return @"wdd_hide_all_media";
    return nil;
}

- (NSIndexPath *)indexPathForSettingKey:(NSString *)key {
    for (NSInteger section = 0; section < (NSInteger)self.settings.count; section++) {
        NSArray<NSDictionary *> *rows = self.settings[section];
        for (NSInteger row = 0; row < (NSInteger)rows.count; row++) {
            if ([rows[row][@"key"] isEqualToString:key]) {
                return [NSIndexPath indexPathForRow:row inSection:section];
            }
        }
    }
    return nil;
}

- (void)toggleChanged:(UISwitch *)sender {
    NSInteger section = sender.tag / 100;
    NSInteger row = sender.tag % 100;
    if (section >= (NSInteger)self.settings.count || row >= (NSInteger)self.settings[section].count) {
        return;
    }

    NSString *key = self.settings[section][row][@"key"];
    NSString *otherKey = [self pairedKeyForKey:key];
    BOOL otherWasOn = otherKey ? [WDDManager boolForKey:otherKey] : NO;

    [WDDManager setBool:sender.on forKey:key];

    if (!sender.on || !otherKey || !otherWasOn) return;

    NSIndexPath *otherPath = [self indexPathForSettingKey:otherKey];
    if (!otherPath) return;
    UITableViewCell *otherCell = [self.tableView cellForRowAtIndexPath:otherPath];
    if ([otherCell isKindOfClass:[ModernSettingsToggleCell class]]) {
        [((ModernSettingsToggleCell *)otherCell).toggleSwitch setOn:NO animated:YES];
    }
}

- (void)setupFooterLabel {
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 180)];
    footerView.backgroundColor = [BHDimPalette currentBackgroundColor];

    UITextView *footerTextView = [[UITextView alloc] init];
    footerTextView.translatesAutoresizingMaskIntoConstraints = NO;
    footerTextView.editable = NO;
    footerTextView.scrollEnabled = NO;
    footerTextView.backgroundColor = [UIColor clearColor];
    footerTextView.textContainerInset = UIEdgeInsetsZero;
    footerTextView.textContainer.lineFragmentPadding = 0;
    footerTextView.dataDetectorTypes = UIDataDetectorTypeLink;
    
    UIFont *font = [UIFont fontWithName:@"ChirpUIVF_wght1900000_opszE0000" size:12] ?:
                   [UIFont systemFontOfSize:12 weight:UIFontWeightRegular];
    
    Class TAEColorSettingsCls = objc_getClass("TAEColorSettings");
    id settings = [TAEColorSettingsCls sharedSettings];
    id currentPalette = [settings currentColorPalette];
    id colorPalette = [currentPalette colorPalette];
    UIColor *subtitleColor = [colorPalette performSelector:@selector(tabBarItemColor)];
    
    NSString *line1 = @"WddTwitter v1.2.10\n";
    NSString *line2 = @"基于 X 版本 12.35\n";
    NSString *line4 = @"更多信息：wangdaodao.me";
    
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@%@%@", line1, line2, line4]];
    NSRange fullRange = NSMakeRange(0, attrStr.length);
    [attrStr addAttributes:@{NSFontAttributeName: font, NSForegroundColorAttributeName: subtitleColor} range:fullRange];
    
    // Add left-aligned paragraph style and line spacing
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment = NSTextAlignmentLeft;
    paragraphStyle.lineSpacing = 4.0;
    [attrStr addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:fullRange];
    
    // Add links
    [attrStr addAttribute:NSLinkAttributeName value:@"https://wangdaodao.me/ios-jailbreak" range:[attrStr.string rangeOfString:@"wangdaodao.me/2026/ios-jailbreak/"]];
    
    footerTextView.attributedText = attrStr;
    footerTextView.linkTextAttributes = @{NSForegroundColorAttributeName: subtitleColor, NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle)};
    
    [footerView addSubview:footerTextView];
    [NSLayoutConstraint activateConstraints:@[
        [footerTextView.leadingAnchor constraintEqualToAnchor:footerView.leadingAnchor constant:20],
        [footerTextView.trailingAnchor constraintEqualToAnchor:footerView.trailingAnchor constant:-20],
        [footerTextView.topAnchor constraintEqualToAnchor:footerView.topAnchor constant:15],
        [footerTextView.bottomAnchor constraintLessThanOrEqualToAnchor:footerView.bottomAnchor constant:-110]
    ]];

    self.tableView.tableFooterView = footerView;
}

@end
