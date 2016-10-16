//
//  PusicUserDefaults.m
//  Pusic
//
//  Created by peter on 15/4/14.
//  Copyright (c) 2015年 peter. All rights reserved.
//

#import "PriterUserDefaults.h"
NSString *  const BNRIsShowInDock=@"BNRInDock";
NSString *  const BNRIsAutoLunch=@"BNRAutoLunch";
NSString *  const BNRSoundVolum= @"BNRSoundVolum";
NSString * const BNRSoundSelect = @"BNRSoundSelect";
@implementation PriterUserDefaults
+(void) registerUserDefaults
{
    NSMutableDictionary *defaultValues  = [NSMutableDictionary dictionary];
    [defaultValues setValue:[NSNumber numberWithBool:NO] forKey:BNRIsShowInDock];
    [defaultValues setValue:[NSNumber numberWithBool:YES] forKey:BNRIsAutoLunch];
    [defaultValues setValue:@"70" forKey:BNRSoundVolum];
    [defaultValues setValue:[NSNumber numberWithInteger:1] forKey:BNRSoundSelect];
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaultValues];
}

+( void) setShowInDock :(BOOL) showInDock
{
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:[NSNumber numberWithBool:showInDock] forKey:BNRIsShowInDock];
    
}

+(BOOL) getShowInDock
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults boolForKey:BNRIsShowInDock];
}

+( void) setAutoLunch :(BOOL) autoLunch
{
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:[NSNumber numberWithBool:autoLunch] forKey:BNRIsAutoLunch];
    
}

+(BOOL) getAutoLunch
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults boolForKey:BNRIsAutoLunch];
}

+( void) setSoundVolum:(NSString *)soundVolum
{
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:soundVolum forKey:BNRSoundVolum];
    
}

+(NSString *) getSoundVolum
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults stringForKey:BNRSoundVolum];
}

+( void) setSoundType :(NSInteger) soundType
{
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:[NSNumber numberWithInteger:soundType] forKey:BNRSoundSelect];
    
}

+(NSInteger) getSoundType
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults integerForKey:BNRSoundSelect];
}

@end
