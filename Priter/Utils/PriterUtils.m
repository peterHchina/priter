//
//  PritetUtils.m
//  Priter
//
//  Created by peter on 15/12/24.
//  Copyright © 2015年 peter. All rights reserved.
//

#import "PriterUtils.h"
#import <Cocoa/Cocoa.h>
@implementation PriterUtils
+(BOOL) toggleDockIcon:(BOOL) showIcon
{
    if (showIcon) {
        return [NSApp setActivationPolicy:NSApplicationActivationPolicyRegular];
    }
    else
    {
        return [NSApp setActivationPolicy:NSApplicationActivationPolicyAccessory];
    }
}

+(BOOL) isDarkMode
{
    NSDictionary *systemUserDefaults = [[NSUserDefaults standardUserDefaults] persistentDomainForName:@"NSGlobalDomain"];
    NSString *style = [systemUserDefaults objectForKey:@"AppleInterfaceStyle"];
    
    //    NSString *style1 = NSStringFromClass(style1);
    if ([style.lowercaseString isEqualToString:@"dark"]) {
        return YES;
    }
    else
    {
        return NO;
    }
}

@end
