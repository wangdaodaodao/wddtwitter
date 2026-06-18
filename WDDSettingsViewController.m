//
//  WDDSettingsViewController.m
//  wddtwitter
//

#import "WDDSettingsViewController.h"
#import "WDDUIComponents.h"
#import "TWHeaders.h"
#import "BHDimPalette.h"

@interface WDDSettingsViewController () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray<NSDictionary *> *settings;
@property (nonatomic, strong) NSArray<NSDictionary *> *authors;
@end

@implementation WDDSettingsViewController

- (instancetype)initWithAccount:(TFNTwitterAccount *)account {
    if ((self = [super init])) {
        self.account = account;
        self.settings = @[
            @{ @"key": @"hide_author_name", @"title": @"隐藏作者名字", @"subtitle": @"在推文中隐藏作者显示的姓名", @"default": @NO, @"type": @"toggle" },
            @{ @"key": @"hide_avatar", @"title": @"隐藏头像", @"subtitle": @"在推文中隐藏作者的头像（加宽内容）", @"default": @NO, @"type": @"toggle" },
            @{ @"key": @"hide_blue_verified", @"title": @"隐藏蓝V标识", @"subtitle": @"隐藏所有账号的蓝色认证标识", @"default": @NO, @"type": @"toggle" },
            @{ @"key": @"wdd_hide_translation_notice", @"title": @"屏蔽翻译提示", @"subtitle": @"隐藏推文底部的翻译来源和显示原文提示（含Grok）", @"default": @NO, @"type": @"toggle" },
            @{ @"key": @"wdd_hide_reply_to_indicator", @"title": @"屏蔽回复指示", @"subtitle": @"隐藏回复推文中的‘回复 @用户名’提示", @"default": @NO, @"type": @"toggle" },
            @{ @"key": @"wdd_enable_single_image_sizing", @"title": @"固定单图大小", @"subtitle": @"固定首页单张图片为 16:9 比例并居中裁剪", @"default": @NO, @"type": @"toggle" },
            @{ @"key": @"wdd_hide_account_labels", @"title": @"隐藏账号标签", @"subtitle": @"隐藏“戏仿/自动化/游戏/类别”等账号标签", @"default": @NO, @"type": @"toggle" },
            @{ @"key": @"wdd_hide_disclosure_labels", @"title": @"隐藏推文底部标签", @"subtitle": @"隐藏推文底部的“付费合作/推广/AI生成”等标签", @"default": @NO, @"type": @"toggle" },
            @{ @"key": @"wdd_hide_timeline_view_count", @"title": @"隐藏浏览量数值", @"subtitle": @"隐藏时间线及推文详情内的浏览量（流量数值）", @"default": @NO, @"type": @"toggle" },
            @{ @"key": @"wdd_disable_long_press_menu", @"title": @"禁用长按菜单", @"subtitle": @"禁止在时间线长按推文时弹出菜单或预览", @"default": @NO, @"type": @"toggle" },
            @{ @"key": @"enable_reply_filter", @"title": @"回复关键词屏蔽", @"subtitle": @"开启后将根据关键词隐藏回复推文", @"default": @NO, @"type": @"toggle" },
            @{ @"key": @"reply_keywords", @"title": @"设置屏蔽关键词", @"subtitle": @"点击设置（多个关键词请用中or英文逗号分隔）", @"type": @"button" },
            @{ @"key": @"enable_emoji_filter", @"title": @"屏蔽纯表情回复", @"subtitle": @"屏蔽无中文且无英文数字的回复，或超3个emoji且无中文的回复", @"default": @NO, @"type": @"toggle" },
            @{ @"key": @"enable_regex_filter", @"title": @"回复正则屏蔽", @"subtitle": @"开启后将根据自定义正则表达式屏蔽回复", @"default": @NO, @"type": @"toggle" },
            @{ @"key": @"reply_regexes", @"title": @"设置屏蔽正则表达式", @"subtitle": @"点击设置自定义正则（多条规则请换行分隔）", @"type": @"button" }
        ];
        
        self.authors = @[
            @{ @"title": @"王导导", @"username": @"goodwdd", @"avatarURL": @"https://unavatar.io/x/goodwdd" }
        ];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"王导导推特增强";
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
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return self.settings.count;
    } else if (section == 1) {
        return self.authors.count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        NSDictionary *setting = self.settings[indexPath.row];
        NSString *type = setting[@"type"];
        
        if ([type isEqualToString:@"toggle"]) {
            ModernSettingsToggleCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ToggleCell"];
            if (!cell) {
                cell = [[ModernSettingsToggleCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ToggleCell"];
            }

            NSString *title = setting[@"title"];
            NSString *subtitle = setting[@"subtitle"];
            [cell configureWithTitle:title subtitle:subtitle];

            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            BOOL value = [defaults boolForKey:setting[@"key"]];
            cell.toggleSwitch.on = value;
            cell.toggleSwitch.tag = indexPath.row;
            [cell addTarget:self action:@selector(toggleChanged:) forControlEvents:UIControlEventValueChanged];
            return cell;
        } else {
            ModernSettingsCompactButtonCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ButtonCell"];
            if (!cell) {
                cell = [[ModernSettingsCompactButtonCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ButtonCell"];
            }
            
            NSString *title = setting[@"title"];
            NSString *currentValue = [[NSUserDefaults standardUserDefaults] stringForKey:setting[@"key"]];
            cell.titleLabel.text = title;
            cell.subtitleLabel.text = currentValue ?: @"未设置";
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
    if (section == 1) {
        return [self headerViewWithTitle:@"作者"];
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 1) {
        return UITableViewAutomaticDimension;
    }
    return CGFLOAT_MIN;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        NSDictionary *setting = self.settings[indexPath.row];
        if ([setting[@"type"] isEqualToString:@"button"]) {
            if ([setting[@"key"] isEqualToString:@"reply_regexes"]) {
                [self showMultilineInput:setting];
            } else {
                [self showKeywordInput:setting];
            }
        }
    } else if (indexPath.section == 1) {
        NSDictionary *author = self.authors[indexPath.row];
        [self openTwitterProfileWithUser:author];
    }
}

- (UIView *)headerViewWithTitle:(NSString *)title {
    UIView *headerView = [[UIView alloc] init];
    headerView.backgroundColor = [BHDimPalette currentBackgroundColor];

    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    titleLabel.text = title;

    id fontGroup = [objc_getClass("TAEStandardFontGroup") sharedFontGroup];
    titleLabel.font = [fontGroup performSelector:@selector(headline2BoldFont)] ?: [UIFont systemFontOfSize:16 weight:UIFontWeightBold];

    Class TAEColorSettingsCls = objc_getClass("TAEColorSettings");
    id settings = [TAEColorSettingsCls sharedSettings];
    id currentPalette = [settings currentColorPalette];
    id colorPalette = [currentPalette colorPalette];
    UIColor *titleColor = [colorPalette performSelector:@selector(textColor)];
    titleLabel.textColor = titleColor;

    [headerView addSubview:titleLabel];

    [NSLayoutConstraint activateConstraints:@[
        [titleLabel.leadingAnchor constraintEqualToAnchor:headerView.leadingAnchor constant:20],
        [titleLabel.trailingAnchor constraintEqualToAnchor:headerView.trailingAnchor constant:-20],
        [titleLabel.topAnchor constraintEqualToAnchor:headerView.topAnchor constant:24],
        [titleLabel.bottomAnchor constraintEqualToAnchor:headerView.bottomAnchor constant:-8]
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
        [avatarImageView.leadingAnchor constraintEqualToAnchor:cell.contentView.leadingAnchor constant:20],
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

        [devChevron.trailingAnchor constraintEqualToAnchor:cell.contentView.trailingAnchor constant:-20],
        [devChevron.centerYAnchor constraintEqualToAnchor:cell.contentView.centerYAnchor],
        [devChevron.widthAnchor constraintEqualToConstant:18],
        [devChevron.heightAnchor constraintEqualToConstant:18]
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

    usernameLabel.text = [NSString stringWithFormat:@"@%@", developer[@"username"]];
    usernameLabel.font = [fontGroup performSelector:@selector(subtext2Font)] ?: [UIFont systemFontOfSize:12 weight:UIFontWeightRegular];
    usernameLabel.textColor = subtitleColor;

    devChevron.image = [UIImage tfn_vectorImageNamed:@"chevron_right" fitsSize:CGSizeMake(18, 18) fillColor:subtitleColor];

    NSString *avatarURL = developer[@"avatarURL"];
    if (avatarURL.length > 0) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:avatarURL]];
            UIImage *img = [UIImage imageWithData:data];
            dispatch_async(dispatch_get_main_queue(), ^{
                avatarImageView.image = img ?: [UIImage systemImageNamed:@"person.circle.fill"];
            });
        });
    } else {
        avatarImageView.image = [UIImage systemImageNamed:@"person.circle.fill"];
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
    NSString *currentValue = [[NSUserDefaults standardUserDefaults] stringForKey:key];
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
            [[NSUserDefaults standardUserDefaults] setObject:inputText forKey:key];
        } else {
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
        }
        [self.tableView reloadData];
    }]];

    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)showKeywordInput:(NSDictionary *)setting {
    NSString *key = setting[@"key"];
    NSString *currentValue = [[NSUserDefaults standardUserDefaults] stringForKey:key];
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
            [[NSUserDefaults standardUserDefaults] setObject:inputText forKey:key];
        } else {
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
        }
        [self.tableView reloadData];
    }]];

    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)toggleChanged:(UISwitch *)sender {
    NSDictionary *setting = self.settings[sender.tag];
    [[NSUserDefaults standardUserDefaults] setBool:sender.on forKey:setting[@"key"]];
}

- (void)setupFooterLabel {
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 120)];
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
    
    NSString *line1 = @"WDDTwitter v1.0.0 (Stable)\n";
    NSString *line2 = @"基于 X 版本 11.90\n";
    NSString *line4 = @"更新请参考：wangdaodao.me/2026/wddtwitter/";
    
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@%@%@", line1, line2, line4]];
    NSRange fullRange = NSMakeRange(0, attrStr.length);
    [attrStr addAttributes:@{NSFontAttributeName: font, NSForegroundColorAttributeName: subtitleColor} range:fullRange];
    
    // Add links
    [attrStr addAttribute:NSLinkAttributeName value:@"https://wangdaodao.me/2026/wddtwitter/" range:[attrStr.string rangeOfString:@"wangdaodao.me/2026/wddtwitter/"]];
    
    footerTextView.attributedText = attrStr;
    footerTextView.linkTextAttributes = @{NSForegroundColorAttributeName: subtitleColor, NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle)};
    
    [footerView addSubview:footerTextView];
    [NSLayoutConstraint activateConstraints:@[
        [footerTextView.leadingAnchor constraintEqualToAnchor:footerView.leadingAnchor constant:20],
        [footerTextView.trailingAnchor constraintEqualToAnchor:footerView.trailingAnchor constant:-20],
        [footerTextView.topAnchor constraintEqualToAnchor:footerView.topAnchor constant:15]
    ]];

    self.tableView.tableFooterView = footerView;
}

@end
