//
//  PusicUserDefaults.h
//  Pusic
//
//  Created by peter on 15/4/14.
//  Copyright (c) 2015年 peter. All rights reserved.
//

#import <Foundation/Foundation.h>
extern NSString *  const BNRIsShowInDock;
extern NSString *  const BNRIsAutoLunch;
extern NSString *  const BNRSoundVolum;
extern NSString *  const BNRSoundSelect;
@interface PriterUserDefaults : NSObject
+(void) registerUserDefaults;
+( void) setShowInDock :(BOOL) showInDock;
+(BOOL) getShowInDock;
+( void) setAutoLunch :(BOOL) autoLunch;
+(BOOL) getAutoLunch;
+( void) setSoundVolum:(NSString *)soundVolum;
+(NSString *) getSoundVolum;
+( void) setSoundType :(NSInteger) soundType;
+(NSInteger) getSoundType;
@end
