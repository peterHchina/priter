//
//  PusicPopOverViewDelagate.m
//  Pusic
//
//  Created by peter on 15/4/22.
//  Copyright (c) 2015年 peter. All rights reserved.
//

#import "PriterPopOverViewDelagate.h"
#import "PriterPoPViewController.h"
@implementation PriterPopOverViewDelagate
@synthesize popOver;
-(id) init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}
-(void) showPopover:(id)sender
{
    if(!viewController){
        viewController = [[PriterPoPViewController alloc] init];
    }
        if (popOver ==nil) {
        popOver = [NSPopover new];
        popOver.delegate =self;
//        popOver.appearance = [NSAppearance appearanceNamed:NSAppearanceNameVibrantLight];
        popOver.contentViewController = viewController;
        popOver.behavior = NSPopoverBehaviorTransient;
    }
    
    [popOver showRelativeToRect:[sender bounds] ofView:sender preferredEdge:NSMaxYEdge];
}

- (void)popoverDidClose:(NSNotification *)notification {
    popOver = nil;
}


- (BOOL)popoverShouldDetach:(NSPopover *)popover {
    return YES;
}
@end
