//
//  PusicRHStatusItemView.h
//  Pusic
//
//  Created by peter on 15/4/23.
//  Copyright (c) 2015年 peter. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface PriterRHStatusItemView : NSControl
{
    
    NSStatusItem *_statusItem;
    
    NSImage *_image;
    NSImage *_alternateImage;
    
    SEL _rightAction;
    
    NSMenu *_menu;
    NSMenu *_rightMenu;
    
    BOOL _isMouseDown;
    BOOL _isMenuVisible;
}
@property (nonatomic) NSStatusItem *statusItem; //should never be nil

@property (nonatomic, retain) NSImage *image;
@property (nonatomic, retain) NSImage *alternateImage;

//	NSControl provides these for us
//	@property (weak) id target;
//	If no action specified, we will try and pop up menu if set.
//	@property SEL action;

// If no rightAction specified, we will try and pop up, in order rightMenu, menu.
@property SEL rightAction;

@property (nonatomic, retain) NSMenu *menu;
@property (nonatomic, retain) NSMenu *rightMenu;

// Designated initializer
- (id)initWithStatusBarItem:(NSStatusItem*)statusItem;

- (void)popUpMenu;				// Pops up the currently stored menu
- (void)popUpRightMenu;			// If right menu is set, pops up right menu
- (void)popUpMenu:(NSMenu*)menu;	// Pops up the passed menu
@end
