//
//  PriterPoPViewController.m
//  Priter
//
//  Created by peter on 15/12/22.
//  Copyright © 2015年 peter. All rights reserved.
//

#import "PriterPoPViewController.h"
#import "PriterUtils.h"
#import "PriterUserDefaults.h"
#import <QuartzCore/QuartzCore.h>
NSString * const PriterTempForbidden = @"tempForbidden";
NSString * const PriterTempForbiddenFromDock = @"tempForbiddenFromDock";
NSString * const PriterSelectSound = @"selectSound";
NSString * const PriterHideAppIcon = @"hideAppIcon";
NSString * const PriterAutoLunch = @"autoLunch";
@interface References : NSObject
@property (nonatomic) LSSharedFileListItemRef existingReference;
@property (nonatomic) LSSharedFileListItemRef lastReference;
@end

@implementation References
@synthesize existingReference,lastReference;

@end


@interface PriterPoPViewController ()

@end

@implementation PriterPoPViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(darkModeChanged) name:@"AppleInterfaceThemeChangedNotification" object:nil];
    if ([PriterUserDefaults getShowInDock]) {
        [_showInDockButton setState:NSOnState];
    }else
    {
        [_showInDockButton setState:NSOffState];
    }
    
    if ([self applicationIsInStartUpItems]) {
        [_autonLunchButton setState:NSOnState];
        [PriterUserDefaults setAutoLunch:YES];
    }
    else
    {
        [_autonLunchButton setState:NSOffState];
        [PriterUserDefaults setAutoLunch:NO];
    }
    
    [_volumeSlider setStringValue:[PriterUserDefaults getSoundVolum]];
    [self darkModeChanged];
//    _appIconView.logoImage = [NSImage imageNamed:@"app_icon"];
    [self startLogoViewAnimation];
    [self setItemState:[PriterUserDefaults getSoundType]];
    // Do view setup here.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(soundTypeChangeFromDock:) name:PriterSelectSound object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tempForbiddenFromDock:) name:PriterTempForbiddenFromDock object:nil];
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(autoLunchFromDock) name:PriterAutoLunch object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setAppIconShow) name:PriterHideAppIcon object:nil];
   
}


-(void) viewDidAppear
{
    [super viewDidAppear];
    
}

- (IBAction)quit:(id)sender {
    [[NSApplication sharedApplication] terminate:self];
}

- (IBAction)setDockIcon:(NSButton *)sender {
    
    switch (sender.state) {
        case NSOnState:
            [PriterUtils toggleDockIcon:true];
            [PriterUserDefaults setShowInDock:YES];
            break;
        case NSOffState:
            [PriterUtils toggleDockIcon:false];
            [PriterUserDefaults setShowInDock:NO];
            break;
        default:
            break;
    }
    
}

-(void) setAppIconShow
{
    if ([PriterUserDefaults getShowInDock]) {
        _showInDockButton.state = 1;
    }else
    {
        _showInDockButton.state = 0;
    }
}

- (IBAction)setLaunch:(id)sender {
    [self toggleLaunchAtStartup];
}

- (IBAction)tempForbidden:(id)sender {
    NSButton *button = (NSButton *) sender;
    [[NSNotificationCenter defaultCenter] postNotificationName:PriterTempForbidden object:nil userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithInteger: [button state]] forKey:PriterTempForbidden]];
}

-(void) tempForbiddenFromDock:(NSNotification *) notification
{
    NSInteger state = ((NSString *) [notification.userInfo objectForKey:@"temp_forbidden"]).integerValue;
    _tempForbiddenButton.state = state;
    
}
- (IBAction)adjustTheVolum:(NSSlider *)sender {
    [PriterUserDefaults setSoundVolum:sender.stringValue];
//    [[NSNotificationCenter defaultCenter] postNotificationName:PriterTempForbidden
//                                                        object:nil];
}

-(BOOL) applicationIsInStartUpItems
{
    return ([self itemReferencesInLoginItems].existingReference != nil);
}


-(References *) itemReferencesInLoginItems
{
    NSURL *appUrl = [NSURL fileURLWithPath:[NSBundle mainBundle].bundlePath];
    if (appUrl) {
        References *reference = [References new];
        LSSharedFileListRef loginItemsRef = LSSharedFileListCreate(nil, kLSSharedFileListSessionLoginItems , nil);
        if (loginItemsRef!=nil) {
            NSArray* loginItems = (__bridge NSArray *)(LSSharedFileListCopySnapshot(loginItemsRef, nil));
            LSSharedFileListItemRef  lastItemRef = (__bridge LSSharedFileListItemRef) loginItems.lastObject;
            
            for (int i= 0 ; i<loginItems.count; i++) {
                LSSharedFileListItemRef currentItemRef = (__bridge LSSharedFileListItemRef) loginItems[i];
                CFURLRef resUrl = LSSharedFileListItemCopyResolvedURL(currentItemRef, 0, nil);
                if (resUrl) {
                    NSURL *urlRef = (__bridge NSURL *)resUrl;
                    if ([urlRef isEqual:appUrl]) {
                        reference.existingReference = currentItemRef;
                        reference.lastReference = lastItemRef;
                        return reference;
                    }
                }else
                {
                    
                }
            }
            
            reference.existingReference = nil;
            reference.lastReference = lastItemRef;
            return reference;
        }
        
    }
    
    return nil;
    
}


-(void) toggleLaunchAtStartup
{
    References * reference = [self itemReferencesInLoginItems];
    BOOL shouldBeToggled =([self itemReferencesInLoginItems].existingReference == nil);
    LSSharedFileListRef  loginItemsRef = LSSharedFileListCreate(nil,kLSSharedFileListSessionLoginItems,NULL);
    if (loginItemsRef) {
        if (shouldBeToggled) {
            CFURLRef appUrl = (__bridge CFURLRef) [NSURL fileURLWithPath:[NSBundle mainBundle].bundlePath];
            if (appUrl) {
                LSSharedFileListInsertItemURL(loginItemsRef,reference.lastReference,nil,nil,appUrl,nil,nil);
                NSLog(@"Application was added to login items");
                [PriterUserDefaults setAutoLunch:YES];
            }
        }else
        {
            LSSharedFileListItemRef itemRef = reference.existingReference;
            if (itemRef) {
                LSSharedFileListItemRemove(loginItemsRef,itemRef);
                NSLog(@"Application was removed from login items");
                 [PriterUserDefaults setAutoLunch:NO];

            }
        }
    }
}

-(void) autoLunchFromDock
{
     [self toggleLaunchAtStartup];
    if ([self applicationIsInStartUpItems]) {
        [_autonLunchButton setState:NSOnState];
        [PriterUserDefaults setAutoLunch:YES];
    }
    else
    {
        [_autonLunchButton setState:NSOffState];
        [PriterUserDefaults setAutoLunch:NO];
    }

}

-(void) darkModeChanged
{
    
    if ([PriterUtils isDarkMode]) {
        [_closeButton setImage: [NSImage imageNamed:@"shutdown_light"]];
    }
    else
    {
        [_closeButton setImage: [NSImage imageNamed:@"shutdown"]];
        
    }
}

-(void) startLogoViewAnimation
{
    [_appIconView setWantsLayer:YES];
    CGRect frame = _appIconView.frame;
    CALayer * layer = [CALayer layer];
    layer.bounds = frame;
    layer.cornerRadius = frame.size.width/2;
//    layer.masksToBounds = YES;
    layer.contents =  (id)[NSImage imageNamed:@"app_icon"];
//    layer.cornerRadius =
    layer.position = CGPointMake(self.appIconView.bounds.origin.x+self.appIconView.bounds.size.width/2, self.appIconView.bounds.origin.y+self.appIconView.bounds.size.width/2);
    

    
    CABasicAnimation * animation = [CABasicAnimation animation];
    animation.keyPath = @"transform.rotation.y";
    animation.fromValue = @0;
    animation.toValue=@(2*M_PI);
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    animation.removedOnCompletion = NO;
//    animation.repeatCount = MAXFLOAT;
    animation.duration = 3.f;
    animation.fillMode = kCAFillModeForwards;
    
    [layer addAnimation:animation forKey:nil];
    [_appIconView.layer addSublayer:layer];
    
}
- (IBAction)selectDefaultSound:(id)sender {
     [PriterUserDefaults setSoundType:1];
    [self setItemState:1];
}

- (IBAction)selectBubbleSound:(id)sender {
    [PriterUserDefaults setSoundType:2];
    [self setItemState:2];
}

- (IBAction)selectG803Sound:(id)sender {
    [PriterUserDefaults setSoundType:3];
    [self setItemState:3];
}

- (IBAction)selectG804Sound:(id)sender {
    [PriterUserDefaults setSoundType:4];
    [self setItemState:4];
}

- (IBAction)selectMechanicalSound:(id)sender {
    [PriterUserDefaults setSoundType:5];
    [self setItemState:5];
}

- (IBAction)selectSwordSound:(id)sender {
    [PriterUserDefaults setSoundType:6];
    [self setItemState:6];
}

- (IBAction)selectDrumbeatSound:(id)sender {
    [PriterUserDefaults setSoundType:7];
    [self setItemState:7];
}


-(void) setItemState:(NSInteger) type
{
    _defaultSound.state = 0;
    _bubbleSound.state = 0;
    _g80_3000Sound.state = 0;
    _g80_3494Sound.state =0;
    _mechanicalSound.state = 0;
    _swordSound.state = 0;
    _drumBeatSound.state = 0;
    switch (type) {
        case 1:
             _defaultSound.state = 1;
            [_soundSelectButton setTitle:_defaultSound.title];
            break;
        case 2:
            _bubbleSound.state = 1;
            [_soundSelectButton setTitle:_bubbleSound.title];
            break;
        case 3:
            _g80_3000Sound.state = 1;
             [_soundSelectButton setTitle:_g80_3000Sound.title];
            break;
        case 4:
            _g80_3494Sound.state = 1;
            [_soundSelectButton setTitle:_g80_3494Sound.title];
            
            break;
        case 5:
            _mechanicalSound.state = 1;
            [_soundSelectButton setTitle:_mechanicalSound.title];
            break;
        case 6:
            _swordSound.state = 1;
            [_soundSelectButton setTitle:_swordSound.title];
            break;
        case 7:
            _drumBeatSound.state = 1;
            [_soundSelectButton setTitle:_drumBeatSound.title];
            break;
        default:
            break;
    }
}

-(NSMenuItem *) getMenuItemByType:(NSInteger) type
{
    switch (type) {
        case 1:
            return _defaultSound;
            break;
        case 2:
            return _bubbleSound;
            break;
        case 3:
            return _g80_3000Sound;
            break;
        case 4:
            return _g80_3494Sound;
            break;
        case 5:
            return _mechanicalSound;
            break;
        case 6:
            return _swordSound;
            break;
        case 7:
            return _drumBeatSound;
            break;
        default:
            return nil;
            break;
    }
}

-(void) soundTypeChangeFromDock:(NSNotification *) notification
{
    NSDictionary *userInfo = [notification userInfo];
    NSInteger type = ((NSString *)[userInfo valueForKey:@"sound_type"]).integerValue;
    [self setItemState:type];
    
}

-(void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
