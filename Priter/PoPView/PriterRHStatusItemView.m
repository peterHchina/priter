//
//  PusicRHStatusItemView.m
//  Pusic
//
//  Created by peter on 15/4/23.
//  Copyright (c) 2015年 peter. All rights reserved.
//

#import "PriterRHStatusItemView.h"
#import <Cocoa/Cocoa.h>

static CGFloat RHStatusItemViewImageHPadding = 4.0f;
static CGFloat RHStatusItemViewImageVPadding = 3.0f;
@implementation PriterRHStatusItemView

#pragma mark - init
- (id)init {
    return [self initWithStatusBarItem:nil];
}

- (id)initWithFrame:(NSRect)frameRect {
    return [self initWithStatusBarItem:nil];
}

- (id)initWithStatusBarItem:(NSStatusItem*)statusItem {
    if (!statusItem) {
        [NSException raise:NSInvalidArgumentException format:@"-[%@ %@] statusItem should not be nil!", NSStringFromClass(self.class), NSStringFromSelector(_cmd)];
    }
    
    self = [super initWithFrame:NSZeroRect];
    if (self) {
        self.statusItem = statusItem;
    }
    
    return self;
}

#pragma mark - properties
- (void)setStatusItem:(NSStatusItem *)statusItem{
    if (!statusItem) {
        [NSException raise:NSInvalidArgumentException format:@"-[%@ %@] statusItem should not be nil!", NSStringFromClass(self.class), NSStringFromSelector(_cmd)];
    }
    _statusItem = statusItem;
}

- (void)setImage:(NSImage *)image{
    if (image != _image){
        _image = image;
    }
    
    [self setNeedsDisplay];
}

- (void)setAlternateImage:(NSImage *)alternateImage{
    if (alternateImage != _alternateImage){
        _alternateImage = alternateImage;
    }
    
    [self setNeedsDisplay];
}

#pragma mark - NSView
- (void)drawRect:(NSRect)rect {
    
    BOOL highlighted = _isMouseDown || _isMenuVisible;
    
    // Draw status bar background, highlighted if menu is showing
    [_statusItem drawStatusBarBackgroundInRect:[self bounds] withHighlight:highlighted];
    
    NSRect imageRect = NSInsetRect(self.bounds, RHStatusItemViewImageHPadding, RHStatusItemViewImageVPadding);
    ++imageRect.origin.y; //move it up one pix
    
    if (highlighted) {
        [self.alternateImage drawInRect:imageRect fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1];
    } else {
        [self.image drawInRect:imageRect fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1];
    }
}


#pragma mark - mouse tracking

// left
- (void)mouseDown:(NSEvent *)theEvent {
    _isMouseDown = YES;
    [self setNeedsDisplay];
}

- (void)mouseUp:(NSEvent *)event {
    // If showing a menu, the mouse down event dismisses the menu before we
    // see it, so this is a nice way not to re-show the menu on the subsequent
    // mouse up
    
    if (!_isMouseDown) return;
    
    if ([event modifierFlags] & NSControlKeyMask) {
        if (![NSApp sendAction:self.rightAction to:self.target from:self]) {
            [self popUpMenu];
        }
    } else {
        if (![NSApp sendAction:self.action to:self.target from:self]) {
            [self popUpMenu];
        }
    }
    
    _isMouseDown = NO;
    [self setNeedsDisplay];
}

// right
- (void)rightMouseDown:(NSEvent *)theEvent {
    _isMouseDown = YES;
    [self setNeedsDisplay];
}

- (void)rightMouseUp:(NSEvent *)event {
    // If showing a menu, the mouse down event dismisses the menu before we
    // see it, so this is a nice way not to re-show the menu on the subsequent
    // mouse up
    if (!_isMouseDown) return;
    
    if (![NSApp sendAction:self.rightAction to:self.target from:self]) {
        if (self.rightMenu) {
            [self popUpRightMenu];
        } else {
            [self popUpMenu];
        }
    }
    _isMouseDown = NO;
    [self setNeedsDisplay];
    
}


#pragma mark - Menu showing
- (void)popUpMenu {
    [self popUpMenu:self.menu];
}

- (void)popUpRightMenu {
    [self popUpMenu:self.rightMenu];
}

- (void)popUpMenu:(NSMenu*)menu {
    if (menu) {
        //register for menu did open and close notifications
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(menuWillOpen:) name:NSMenuDidBeginTrackingNotification object:menu];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(menuDidClose:) name:NSMenuDidEndTrackingNotification object:menu];
        
        [_statusItem popUpStatusItemMenu:menu];
    }
}


#pragma mark - NSMenuDidBeginTrackingNotification
- (void)menuWillOpen:(NSNotification *)notification {
    _isMenuVisible = YES;
    [self setNeedsDisplay];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSMenuDidBeginTrackingNotification object:notification.object];
}


#pragma mark - NSMenuDidEndTrackingNotification
- (void)menuDidClose:(NSNotification *)notification {
    _isMenuVisible = NO;
    [self setNeedsDisplay];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSMenuDidEndTrackingNotification object:notification.object];
}


@end
