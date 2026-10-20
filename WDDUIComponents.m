//
//  WDDUIComponents.m
//  wddtwitter
//

#import "WDDUIComponents.h"

static UIColor *WDDCurrentAccentColor(void) {    Class TAEColorSettingsCls = objc_getClass("TAEColorSettings");
    if (!TAEColorSettingsCls) {
        return [UIColor systemBlueColor];
    }
    
    id settings = [TAEColorSettingsCls performSelector:@selector(sharedSettings)];
    id current = [settings performSelector:@selector(currentColorPalette)];
    id palette = [current performSelector:@selector(colorPalette)];
    NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
    
    if ([defs objectForKey:@"T1ColorSettingsPrimaryColorOptionKey"]) {
        NSInteger opt = [defs integerForKey:@"T1ColorSettingsPrimaryColorOptionKey"];
        // In Twitter, primaryColorForOption: is on the TAEThemeColorPalette class.
        // We can safely call it via performSelector:withObject:
        SEL selector = NSSelectorFromString(@"primaryColorForOption:");
        if ([palette respondsToSelector:selector]) {
            // Using signature to invoke safely since it returns an object and takes NSInteger
            NSMethodSignature *sig = [palette methodSignatureForSelector:selector];
            NSInvocation *inv = [NSInvocation invocationWithMethodSignature:sig];
            [inv setTarget:palette];
            [inv setSelector:selector];
            [inv setArgument:&opt atIndex:2];
            [inv invoke];
            __unsafe_unretained UIColor *color = nil;
            [inv getReturnValue:&color];
            if (color) {
                return color;
            }
        }
    }
    return [UIColor systemBlueColor];
}

static UIColor *WDDThemeSecondaryColor(void) {
    Class TAEColorSettingsCls = objc_getClass("TAEColorSettings");
    if (!TAEColorSettingsCls) {
        return [UIColor secondaryLabelColor];
    }
    id settings = [TAEColorSettingsCls performSelector:@selector(sharedSettings)];
    id current = [settings performSelector:@selector(currentColorPalette)];
    id palette = [current performSelector:@selector(colorPalette)];
    UIColor *color = [palette performSelector:@selector(tabBarItemColor)];
    return color ?: [UIColor secondaryLabelColor];
}

static UIImage *WDDIconImage(NSString *iconName, CGFloat pointSize) {
    if (iconName.length == 0) return nil;
    UIImageSymbolConfiguration *cfg = [UIImageSymbolConfiguration configurationWithPointSize:pointSize
                                                                                     weight:UIImageSymbolWeightRegular];
    UIImage *image = [UIImage systemImageNamed:iconName withConfiguration:cfg];
    return [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
}

static const CGFloat WDDIconSize = 24.0;
static const CGFloat WDDCellLeading = 16.0;
static const CGFloat WDDIconTextGap = 10.0;
static const CGFloat WDDCellTrailing = 16.0;

static UIFont *WDDTitleFont(void) {
    UIFont *base = [UIFont systemFontOfSize:17 weight:UIFontWeightRegular];
    return [[UIFontMetrics metricsForTextStyle:UIFontTextStyleBody] scaledFontForFont:base];
}

static UIFont *WDDSubtitleFont(void) {
    UIFont *base = [UIFont systemFontOfSize:14 weight:UIFontWeightRegular];
    return [[UIFontMetrics metricsForTextStyle:UIFontTextStyleSubheadline] scaledFontForFont:base];
}

@implementation ModernSettingsTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupViews];
        [self setupConstraints];
    }
    return self;
}

- (void)setupViews {
    self.iconImageView = [[UIImageView alloc] init];
    self.iconImageView.translatesAutoresizingMaskIntoConstraints = NO;
    self.iconImageView.contentMode = UIViewContentModeScaleAspectFit;
    self.iconImageView.tintColor = [UIColor secondaryLabelColor];
    [self.contentView addSubview:self.iconImageView];

    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.titleLabel.font = WDDTitleFont();
    self.titleLabel.textColor = [UIColor labelColor];
    [self.contentView addSubview:self.titleLabel];

    self.subtitleLabel = [[UILabel alloc] init];
    self.subtitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.subtitleLabel.font = WDDSubtitleFont();
    [self updateSubtitleColor];
    self.subtitleLabel.numberOfLines = 0;
    [self.contentView addSubview:self.subtitleLabel];

    self.chevronImageView = [[UIImageView alloc] init];
    self.chevronImageView.translatesAutoresizingMaskIntoConstraints = NO;
    self.chevronImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.contentView addSubview:self.chevronImageView];

    self.backgroundColor = [BHDimPalette currentBackgroundColor];
    self.selectionStyle = UITableViewCellSelectionStyleDefault;
}

- (void)setupConstraints {
    [NSLayoutConstraint activateConstraints:@[
        [self.iconImageView.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:WDDCellLeading],
        [self.iconImageView.centerYAnchor constraintEqualToAnchor:self.contentView.centerYAnchor],
        [self.iconImageView.widthAnchor constraintEqualToConstant:WDDIconSize],
        [self.iconImageView.heightAnchor constraintEqualToConstant:WDDIconSize],

        [self.titleLabel.leadingAnchor constraintEqualToAnchor:self.iconImageView.trailingAnchor constant:WDDIconTextGap],
        [self.titleLabel.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:14],
        [self.titleLabel.trailingAnchor constraintEqualToAnchor:self.chevronImageView.leadingAnchor constant:-12],

        [self.subtitleLabel.leadingAnchor constraintEqualToAnchor:self.titleLabel.leadingAnchor],
        [self.subtitleLabel.topAnchor constraintEqualToAnchor:self.titleLabel.bottomAnchor constant:3],
        [self.subtitleLabel.trailingAnchor constraintEqualToAnchor:self.titleLabel.trailingAnchor],
        [self.subtitleLabel.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor constant:-14],

        [self.chevronImageView.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-WDDCellTrailing],
        [self.chevronImageView.centerYAnchor constraintEqualToAnchor:self.contentView.centerYAnchor],
        [self.chevronImageView.widthAnchor constraintEqualToConstant:14],
        [self.chevronImageView.heightAnchor constraintEqualToConstant:14]
    ]];
}

- (void)configureWithTitle:(NSString *)title subtitle:(NSString *)subtitle iconName:(NSString *)iconName {
    self.titleLabel.text = title;
    self.subtitleLabel.text = subtitle;
    objc_setAssociatedObject(self, @selector(iconName), iconName, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self updateIconColors];
}

- (void)updateIconColors {
    NSString *iconName = objc_getAssociatedObject(self, @selector(iconName));
    UIColor *secondary = WDDThemeSecondaryColor();
    self.iconImageView.tintColor = secondary;
    if (iconName.length > 0) {
        UIImage *image = WDDIconImage(iconName, 18);
        if (!image) {
            image = [UIImage tfn_vectorImageNamed:iconName fitsSize:CGSizeMake(WDDIconSize, WDDIconSize) fillColor:secondary];
        }
        self.iconImageView.image = image;
    }
    self.chevronImageView.image = [UIImage tfn_vectorImageNamed:@"chevron_right" fitsSize:CGSizeMake(14, 14) fillColor:secondary];
}

- (void)updateSubtitleColor {
    Class TAEColorSettingsCls = objc_getClass("TAEColorSettings");
    id settings = [TAEColorSettingsCls sharedSettings];
    id currentPalette = [settings currentColorPalette];
    id colorPalette = [currentPalette colorPalette];
    UIColor *subtitleColor = [colorPalette performSelector:@selector(tabBarItemColor)];
    self.subtitleLabel.textColor = subtitleColor;
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];
    self.backgroundColor = [BHDimPalette currentBackgroundColor];
    [self updateIconColors];
    [self updateSubtitleColor];
    if (previousTraitCollection.preferredContentSizeCategory != self.traitCollection.preferredContentSizeCategory) {
        self.titleLabel.font = WDDTitleFont();
        self.subtitleLabel.font = WDDSubtitleFont();
    }
}

@end

@implementation ModernSettingsSimpleButtonCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupViews];
        [self setupConstraints];
    }
    return self;
}

- (void)setupViews {
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.titleLabel.font = WDDTitleFont();
    self.titleLabel.textColor = [UIColor labelColor];
    [self.contentView addSubview:self.titleLabel];

    self.chevronImageView = [[UIImageView alloc] init];
    self.chevronImageView.translatesAutoresizingMaskIntoConstraints = NO;
    self.chevronImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.contentView addSubview:self.chevronImageView];

    self.backgroundColor = [BHDimPalette currentBackgroundColor];
    self.selectionStyle = UITableViewCellSelectionStyleDefault;
    [self updateChevronColor];
}

- (void)setupConstraints {
    [NSLayoutConstraint activateConstraints:@[
        [self.titleLabel.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:20],
        [self.titleLabel.centerYAnchor constraintEqualToAnchor:self.contentView.centerYAnchor],
        [self.titleLabel.trailingAnchor constraintEqualToAnchor:self.chevronImageView.leadingAnchor constant:-16],
        [self.titleLabel.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:16],
        [self.titleLabel.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor constant:-16],

        [self.chevronImageView.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-20],
        [self.chevronImageView.centerYAnchor constraintEqualToAnchor:self.contentView.centerYAnchor],
        [self.chevronImageView.widthAnchor constraintEqualToConstant:18],
        [self.chevronImageView.heightAnchor constraintEqualToConstant:18]
    ]];
}

- (void)configureWithTitle:(NSString *)title {
    self.titleLabel.text = title;
}

- (void)updateChevronColor {
    Class TAEColorSettingsCls = objc_getClass("TAEColorSettings");
    id settings = [TAEColorSettingsCls sharedSettings];
    id currentPalette = [settings currentColorPalette];
    id colorPalette = [currentPalette colorPalette];
    UIColor *chevronColor = [colorPalette performSelector:@selector(tabBarItemColor)];
    self.chevronImageView.image = [UIImage tfn_vectorImageNamed:@"chevron_right" fitsSize:CGSizeMake(18, 18) fillColor:chevronColor];
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];
    self.backgroundColor = [BHDimPalette currentBackgroundColor];
    [self updateChevronColor];
    if (previousTraitCollection.preferredContentSizeCategory != self.traitCollection.preferredContentSizeCategory) {
        self.titleLabel.font = WDDTitleFont();
    }
}

@end

@implementation ModernSettingsCompactButtonCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupViews];
        [self setupConstraints];
    }
    return self;
}

- (void)setupViews {
    self.iconImageView = [[UIImageView alloc] init];
    self.iconImageView.translatesAutoresizingMaskIntoConstraints = NO;
    self.iconImageView.contentMode = UIViewContentModeScaleAspectFit;
    self.iconImageView.tintColor = WDDThemeSecondaryColor();
    [self.contentView addSubview:self.iconImageView];

    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.titleLabel.font = WDDTitleFont();
    self.titleLabel.textColor = [UIColor labelColor];
    [self.contentView addSubview:self.titleLabel];

    self.subtitleLabel = [[UILabel alloc] init];
    self.subtitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.subtitleLabel.font = WDDSubtitleFont();
    self.subtitleLabel.textAlignment = NSTextAlignmentRight;
    [self updateSubtitleColor];
    [self.contentView addSubview:self.subtitleLabel];

    self.chevronImageView = [[UIImageView alloc] init];
    self.chevronImageView.translatesAutoresizingMaskIntoConstraints = NO;
    self.chevronImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.contentView addSubview:self.chevronImageView];

    self.backgroundColor = [BHDimPalette currentBackgroundColor];
    self.selectionStyle = UITableViewCellSelectionStyleDefault;
    [self updateChevronColor];
}

- (void)setupConstraints {
    [NSLayoutConstraint activateConstraints:@[
        [self.iconImageView.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:WDDCellLeading],
        [self.iconImageView.centerYAnchor constraintEqualToAnchor:self.contentView.centerYAnchor],
        [self.iconImageView.widthAnchor constraintEqualToConstant:WDDIconSize],
        [self.iconImageView.heightAnchor constraintEqualToConstant:WDDIconSize],

        [self.titleLabel.leadingAnchor constraintEqualToAnchor:self.iconImageView.trailingAnchor constant:WDDIconTextGap],
        [self.titleLabel.centerYAnchor constraintEqualToAnchor:self.contentView.centerYAnchor],
        [self.titleLabel.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:14],
        [self.titleLabel.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor constant:-14],

        [self.subtitleLabel.leadingAnchor constraintGreaterThanOrEqualToAnchor:self.titleLabel.trailingAnchor constant:12],
        [self.subtitleLabel.trailingAnchor constraintEqualToAnchor:self.chevronImageView.leadingAnchor constant:-8],
        [self.subtitleLabel.centerYAnchor constraintEqualToAnchor:self.contentView.centerYAnchor],

        [self.chevronImageView.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-WDDCellTrailing],
        [self.chevronImageView.centerYAnchor constraintEqualToAnchor:self.contentView.centerYAnchor],
        [self.chevronImageView.widthAnchor constraintEqualToConstant:14],
        [self.chevronImageView.heightAnchor constraintEqualToConstant:14]
    ]];
    [self.titleLabel setContentHuggingPriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
    [self.subtitleLabel setContentHuggingPriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
    [self.subtitleLabel setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
}

- (void)configureWithTitle:(NSString *)title subtitle:(NSString *)subtitle {
    [self configureWithTitle:title subtitle:subtitle iconName:nil];
}

- (void)configureWithTitle:(NSString *)title subtitle:(NSString *)subtitle iconName:(NSString *)iconName {
    self.titleLabel.text = title;
    self.subtitleLabel.text = subtitle;
    self.iconImageView.tintColor = WDDThemeSecondaryColor();
    self.iconImageView.image = WDDIconImage(iconName, 18);
}

- (void)updateChevronColor {
    Class TAEColorSettingsCls = objc_getClass("TAEColorSettings");
    id settings = [TAEColorSettingsCls sharedSettings];
    id currentPalette = [settings currentColorPalette];
    id colorPalette = [currentPalette colorPalette];
    UIColor *chevronColor = [colorPalette performSelector:@selector(tabBarItemColor)];
    self.chevronImageView.image = [UIImage tfn_vectorImageNamed:@"chevron_right" fitsSize:CGSizeMake(18, 18) fillColor:chevronColor];
}

- (void)updateSubtitleColor {
    Class TAEColorSettingsCls = objc_getClass("TAEColorSettings");
    id settings = [TAEColorSettingsCls sharedSettings];
    id currentPalette = [settings currentColorPalette];
    id colorPalette = [currentPalette colorPalette];
    UIColor *subtitleColor = [colorPalette performSelector:@selector(tabBarItemColor)];
    self.subtitleLabel.textColor = subtitleColor;
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];
    self.backgroundColor = [BHDimPalette currentBackgroundColor];
    [self updateChevronColor];
    [self updateSubtitleColor];
    if (previousTraitCollection.preferredContentSizeCategory != self.traitCollection.preferredContentSizeCategory) {
        self.titleLabel.font = WDDTitleFont();
        self.subtitleLabel.font = WDDSubtitleFont();
    }
}

@end

@implementation ModernSettingsToggleCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [BHDimPalette currentBackgroundColor];

        self.iconImageView = [UIImageView new];
        self.iconImageView.translatesAutoresizingMaskIntoConstraints = NO;
        self.iconImageView.contentMode = UIViewContentModeScaleAspectFit;
        self.iconImageView.tintColor = WDDThemeSecondaryColor();
        [self.contentView addSubview:self.iconImageView];

        self.titleLabel = [UILabel new];
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:self.titleLabel];
        self.subtitleLabel = [UILabel new];
        self.subtitleLabel.numberOfLines = 0;
        self.subtitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:self.subtitleLabel];
        self.toggleSwitch = [UISwitch new];
        self.toggleSwitch.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:self.toggleSwitch];
        [self applyTheme];
        [NSLayoutConstraint activateConstraints:@[
            [self.toggleSwitch.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-WDDCellTrailing],
            [self.toggleSwitch.centerYAnchor constraintEqualToAnchor:self.titleLabel.centerYAnchor],

            [self.iconImageView.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:WDDCellLeading],
            [self.iconImageView.centerYAnchor constraintEqualToAnchor:self.titleLabel.centerYAnchor],
            [self.iconImageView.widthAnchor constraintEqualToConstant:WDDIconSize],
            [self.iconImageView.heightAnchor constraintEqualToConstant:WDDIconSize],

            [self.titleLabel.leadingAnchor constraintEqualToAnchor:self.iconImageView.trailingAnchor constant:WDDIconTextGap],
            [self.titleLabel.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:14],
            [self.titleLabel.trailingAnchor constraintEqualToAnchor:self.toggleSwitch.leadingAnchor constant:-12],

            [self.subtitleLabel.leadingAnchor constraintEqualToAnchor:self.titleLabel.leadingAnchor],
            [self.subtitleLabel.trailingAnchor constraintEqualToAnchor:self.titleLabel.trailingAnchor],
            [self.subtitleLabel.topAnchor constraintEqualToAnchor:self.titleLabel.bottomAnchor constant:3],
            [self.subtitleLabel.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor constant:-14]
        ]];
    }
    return self;
}

- (void)configureWithTitle:(NSString *)title subtitle:(NSString *)subtitle {
    [self configureWithTitle:title subtitle:subtitle iconName:nil];
}

- (void)configureWithTitle:(NSString *)title subtitle:(NSString *)subtitle iconName:(NSString *)iconName {
    self.titleLabel.text = title;
    self.subtitleLabel.text = subtitle;
    self.iconImageView.tintColor = WDDThemeSecondaryColor();
    self.iconImageView.image = WDDIconImage(iconName, 18);
}

- (void)addTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)events {
    [self.toggleSwitch addTarget:target action:action forControlEvents:events];
}

- (void)applyTheme {
    self.titleLabel.font = WDDTitleFont();
    self.subtitleLabel.font = WDDSubtitleFont();
    Class TAEColorSettingsCls = objc_getClass("TAEColorSettings");
    id settings = [TAEColorSettingsCls sharedSettings];
    id colorPalette = [[settings currentColorPalette] colorPalette];
    self.titleLabel.textColor = [colorPalette performSelector:@selector(textColor)];
    self.subtitleLabel.textColor = [colorPalette performSelector:@selector(tabBarItemColor)];
    self.iconImageView.tintColor = WDDThemeSecondaryColor();
    self.toggleSwitch.onTintColor = WDDCurrentAccentColor();
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];
    [self applyTheme];
}

@end
