//
//  BHDimPalette.m
//  wddtwitter
//

#import "BHDimPalette.h"
#import <objc/runtime.h>

@interface TAETwitterColorPaletteSettingInfo : NSObject
@property(readonly, nonatomic) BOOL isDark;
@property(readonly, copy, nonatomic) NSString *name;
@end

@interface TAEColorSettings : NSObject
+ (instancetype)sharedSettings;
- (id)currentColorPalette;
@end

@implementation BHDimPalette

+ (BOOL)isDimMode {
    TAETwitterColorPaletteSettingInfo *paletteInfo = (TAETwitterColorPaletteSettingInfo *)[[objc_getClass("TAEColorSettings") sharedSettings] currentColorPalette];
    
    if ([paletteInfo respondsToSelector:@selector(isDark)] && [paletteInfo isDark]) {
        NSString *name = [paletteInfo valueForKey:@"_name"];
        return [name isEqualToString:@"dark"];
    }
    return NO;
}

+ (UIColor *)currentBackgroundColor {
    if ([self isDimMode]) {
        return [self dimModeColor];
    } else {
        return [UIColor systemBackgroundColor];
    }
}

+ (UIColor *)dimModeColor {
    return [UIColor colorWithRed:0.082 green:0.125 blue:0.169 alpha:1.0];
}

@end
