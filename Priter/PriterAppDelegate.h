//
//  AppDelegate.h
//  Priter
//
//  Created by peter on 15/12/21.
//  Copyright © 2015年 peter. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class PriterRHStatusItemView;
@interface PriterAppDelegate : NSObject <NSApplicationDelegate>

@property PriterRHStatusItemView *statusView;
@property NSStatusItem *statusItem;

@end

