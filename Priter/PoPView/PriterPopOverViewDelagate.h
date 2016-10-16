//
//  PusicPopOverViewDelagate.h
//  Pusic
//
//  Created by peter on 15/4/22.
//  Copyright (c) 2015年 peter. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#import "PriterPoPViewController.h"
@interface PriterPopOverViewDelagate : NSObject <NSPopoverDelegate>
{
    
    NSViewController *viewController;
    
}

@property  NSPopover *popOver;
@property NSInteger viewThmeNum;
- (void)showPopover:(id)sender ;
@end
