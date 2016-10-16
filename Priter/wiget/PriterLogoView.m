//
//  PriterLogoView.m
//  Priter
//
//  Created by peter on 15/12/26.
//  Copyright © 2015年 peter. All rights reserved.
//

#import "PriterLogoView.h"

@implementation PriterLogoView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    CGFloat x = dirtyRect.origin.x;
    CGFloat y = dirtyRect.origin.y;
    CGFloat width = dirtyRect.size.width;
    CGFloat height = dirtyRect.size.height;
    
    // Drawing code here.
    [self setWantsLayer:YES];
    
    CGContextRef ctx=  [[NSGraphicsContext currentContext] graphicsPort];
    CGContextAddEllipseInRect(ctx, CGRectMake(x, y, width, height));
    
     //指定上下文中可以显示内容的范围就是圆的范围
      CGContextClip(ctx);
    if (!_logoImage) {
        _logoImage = [NSImage imageNamed:@"app_icon"];
    }
    [_logoImage drawInRect:dirtyRect];
    
    
}

@end
