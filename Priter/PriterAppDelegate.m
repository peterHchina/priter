//
//  AppDelegate.m
//  Priter
//
//  Created by peter on 15/12/21.
//  Copyright © 2015年 peter. All rights reserved.
//

#import "PriterAppDelegate.h"
#import "PoPView/PriterRHStatusItemView.h"
#import <AVFoundation/AVFoundation.h>
#import "PoPView/PriterPopOverViewDelagate.h"
#import "Defaults/PriterUserDefaults.h"
#import "Utils/PriterUtils.h"
@interface PriterAppDelegate ()
{
    BOOL isAcquirePrivileges;
    AVAudioPlayer* avPlayer;
    NSImage *menuNormalImage;
    NSImage * menuDarkImage;
    PriterPopOverViewDelagate * popOverDelagate;
    BOOL isTempForbidden;
    NSMenu *mRightMenu;
    NSMenuItem*autoLunch;
    NSMenuItem *showInDock;
    NSMenuItem *tempForbidden;
}
@end

@implementation PriterAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    [PriterUserDefaults registerUserDefaults];
    isTempForbidden = NO;
    isAcquirePrivileges = [self acquirePrivileges];
    if (isAcquirePrivileges) {
        [NSEvent addGlobalMonitorForEventsMatchingMask:NSKeyDownMask handler:^(NSEvent* event){
            UInt16 key = event.keyCode;
            [self playSoundsByKey:key];
        }];
    } else {
        NSAlert * alert = [NSAlert new];
        alert.window.title = @"WriteTyper";
        alert.messageText = @"Help";
        alert.informativeText = @"For it to work: Accessibility for Priter must be enabled in Security & Privacy, System Preferences.\n\nMade by Urinx, based on original NoisyTyper";
        [alert runModal];
    }
    [self setUpPopView];
    [self setupNotifications];
    [PriterUtils toggleDockIcon:[PriterUserDefaults getShowInDock]];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (NSMenu *)applicationDockMenu:(NSApplication *)sender
{
    [self initRightClick];
    return mRightMenu;
}


-(BOOL) toggleDockIcon:(BOOL) showIcon
{
    BOOL result ;
    if (showIcon) {
        result = [NSApp setActivationPolicy:NSApplicationActivationPolicyRegular];
    }else
    {
        result = [NSApp setActivationPolicy:NSApplicationActivationPolicyAccessory];
    }
    return result;
}

-(BOOL) acquirePrivileges
{
    BOOL accessEnabled;
    NSDictionary *options = @{(__bridge id)kAXTrustedCheckOptionPrompt: @YES};
    accessEnabled = AXIsProcessTrustedWithOptions((__bridge CFDictionaryRef)options );
    if (!accessEnabled) {
        NSLog(@"%@",@"You need to enable the Priter in the System Prefrences");
    }
    return accessEnabled;
}


-(void) playSoundsByKey:(UInt16) key
{
    
    
    NSInteger type = [PriterUserDefaults getSoundType];
    
    switch (type) {
        case 1:
            [self keyWithSound1:key];
            break;
        case 2:
            [self keyWithSound2:key];
            break;
        case 3:
            [self keyWithSound3:key];
            break;
        case 4:
            [self keyWithSound4:key];
            break;
        case 5:
            [self keyWithSound5:key];
            break;
        case 6:
            [self keyWithSound6:key];
            break;
        case 7:
            [self keyWithSound7:key];
            break;
        default:
            break;
    }
   
}

-(CGFloat) ofRandom:(CGFloat) min : (CGFloat) max {
    return  (arc4random()) / 0xFFFFFFFF * (max - min) + min;
}

-(void) darkModeChanged
{
    
    if ([self isDarkMode]) {
        [_statusView setImage: menuNormalImage];
    }
    else
    {
        [_statusView setImage: menuDarkImage];
        
    }
}

-(BOOL) isDarkMode
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


-(void) setUpPopView
{
    _statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:24];
    [_statusItem setHighlightMode:YES];
    _statusView = [[PriterRHStatusItemView alloc] initWithStatusBarItem:_statusItem];
    _statusItem.view = _statusView;
    _statusView.target =self;
    _statusView.action = @selector(mouseClick:);
//    _statusView.rightAction = @selector(menuClick:);
    popOverDelagate =[[PriterPopOverViewDelagate alloc] init];
    [self setStatusImageAndToolTip];

}

-(void) mouseClick:(id) sender
{
    
    [popOverDelagate showPopover:sender];

    [NSApp activateIgnoringOtherApps:YES];
}


- (void)setStatusImageAndToolTip
{
    
    menuNormalImage = [NSImage imageNamed:@"priter_light_icon"];
    menuDarkImage = [NSImage imageNamed:@"priter_dark_icon"];
    [[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(darkModeChanged) name:@"AppleInterfaceThemeChangedNotification" object:nil];
    if ([self isDarkMode]) {
        [_statusView setImage: menuNormalImage];
        [_statusView setAlternateImage:menuNormalImage];
    }
    else
    {
        [_statusView setImage: menuDarkImage ];
        [_statusView setAlternateImage:menuNormalImage];
        
    }
    
    
    
}

- (void)setupNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(audioPlayerVolume:)
                                                 name:PriterTempForbidden
                                               object:nil];
    

}

-(void) audioPlayerVolume:(NSNotification *) notification
{
    if (notification ) {
        NSDictionary * sendVale = [notification userInfo];
        if (((NSString *)[sendVale objectForKey:PriterTempForbidden]).integerValue==1) {
            isTempForbidden = YES;
        }else
        {
            isTempForbidden = NO;
        }
    }
}

-(void)initRightClick
{
    mRightMenu = [[NSMenu alloc] initWithTitle:@"DockMenu"];
    NSMenu * submenu = [[NSMenu alloc] init];
    [[mRightMenu addItemWithTitle:NSLocalizedString(@"key-board-choice", @"") action:nil  keyEquivalent:@""] setSubmenu:submenu];
    
    NSMenuItem *defaultSound =    [submenu addItemWithTitle:NSLocalizedString(@"defalut-sound", @"") action:@selector(defaultSoundAction) keyEquivalent:@""];
    
    NSMenuItem *bubbleSound =    [submenu addItemWithTitle:NSLocalizedString(@"bubble-sound", @"") action:@selector(bubbleSoundAction) keyEquivalent:@""];
    
    NSMenuItem *g80_3000Sound =    [submenu addItemWithTitle:NSLocalizedString(@"g80_3000-sound", @"") action:@selector(g80_3000SoundAction) keyEquivalent:@""];
    
    NSMenuItem *g80_3494Sound =    [submenu addItemWithTitle:NSLocalizedString(@"g80_3494-sound", @"")         action:@selector(g80_3494SoundAction) keyEquivalent:@""];
    
    NSMenuItem *mechanicalSound =    [submenu addItemWithTitle:NSLocalizedString(@"mechanical-sound", @"") action:@selector(mechanicalSoundAction) keyEquivalent:@""];
    
    NSMenuItem *swordSound =    [submenu addItemWithTitle:NSLocalizedString(@"sword-sound", @"") action:@selector(swordSoundAction) keyEquivalent:@""];
    
    NSMenuItem *drumBeatSound =    [submenu addItemWithTitle:NSLocalizedString(@"drum-sound", @"") action:@selector(drumBeatSoundAction) keyEquivalent:@""];
    
    NSInteger type = [PriterUserDefaults getSoundType ];
    
    switch (type) {
        case 1:
            defaultSound.state = 1;
            submenu.title = NSLocalizedString(@"defalut-sound", @"");
            break;
        case 2:
            bubbleSound.state = 1;
            submenu.title = NSLocalizedString(@"bubble-sound", @"");
            break;
        case 3:
            g80_3000Sound.state = 1;
            submenu.title = NSLocalizedString(@"g80_3000-sound", @"");
            break;
        case 4:
            g80_3494Sound.state = 1;
            submenu.title = NSLocalizedString(@"g80_3494-sound", @"");
            break;
        case 5:
            mechanicalSound.state = 1;
            submenu.title = NSLocalizedString(@"mechanical-sound", @"");
            break;
        case 6:
            swordSound.state = 1;
            submenu.title = NSLocalizedString(@"sword-sound", @"");
            break;
        case 7:
            drumBeatSound.state = 1;
            submenu.title = NSLocalizedString(@"drum-sound", @"");
            break;
        default:
            break;
    }
    
    
    [mRightMenu addItem:[NSMenuItem separatorItem]];
    autoLunch =    [mRightMenu addItemWithTitle:@"开机启动" action:@selector(autoLunchApp) keyEquivalent:@""];
        BOOL isCirculate = [PriterUserDefaults getAutoLunch ];
        if (isCirculate) {
            autoLunch.state = 1;
        }else
        {
            autoLunch.state = 0;
        }
        
        
    tempForbidden = [mRightMenu addItemWithTitle:@"临时禁用" action:@selector(tempForbiddenApp:) keyEquivalent:@""];
    
        if (isTempForbidden) {
            tempForbidden.state = 1;
        }
        else
        {
            tempForbidden.state = 0;
        }
    showInDock= [mRightMenu addItemWithTitle:@"在Dock显示图标" action:@selector(showAppInDock:) keyEquivalent:@""];
        BOOL isRepeat= [PriterUserDefaults getShowInDock];
        if (isRepeat) {
            showInDock.state = 1;
        }
        else
        {
            showInDock.state = 0;
        }
    
    

}

-(void) keyWithSound1:(UInt16) key
{
    CGFloat rate= 1.0;
    CGFloat pan = 0.0;
    CGFloat adjustvolume = [PriterUserDefaults getSoundVolum].integerValue/100.0;
    CGFloat volume = 0;
    NSString* sound = @"key-new-01";
    switch( key ){
        case 125: // scrollDown
            rate = [self ofRandom:0.85: 1.0];
            pan = -0.7;
            volume = 1.0;
            sound = @"scrollDown";
            break;
        case 126: // scrollUp
            rate = [self ofRandom:0.85 : 1.0];
            pan = -0.7;
            volume = 1.0;
            sound = @"scrollUp";
            break;
        case 51: // backspace
            rate = [self ofRandom:0.97: 1.03];
            volume = 1.0;
            pan = 0.75;
            sound = @"backspace";
            break;
        case 49: // space
            rate = [self ofRandom:0.95 : 1.05];
            volume = [self ofRandom:0.8: 1.1];
            sound = @"space-new";
            break;
        case 36: // return
            rate = [self ofRandom:0.99: 1.01];
            volume = [self ofRandom:0.7: 1.1];
            pan = 0.3;
            sound = @"return-new";
            break;
        default:
            rate = [self ofRandom:0.98: 1.02];
            volume = [self ofRandom:0.7: 1.1];
            sound =[ NSString stringWithFormat:@"key-new-0%d",(int)(random() % 5 + 1)];
            
            if( key == 12 || key == 13 || key == 0 || key == 1 || key == 6 || key == 7 ) {
                pan = -0.65;
            } else if( key == 35 || key == 37 || key == 43 || key == 31 || key == 40 || key == 46 ) {
                pan = 0.65;
            } else {
                pan = [self ofRandom:-0.3: 0.3];
            }
            break;
    }

    NSURL * soundUrl  = [NSURL fileURLWithPath:[[NSBundle mainBundle]pathForResource:(sound) ofType:@"mp3"]];
    NSError *error;
    avPlayer =  [[AVAudioPlayer alloc] initWithContentsOfURL:soundUrl error:&error];
    avPlayer.rate = rate;
    avPlayer.pan = pan;
    if (isTempForbidden) {
        avPlayer.volume = 0;
    }else
    {
        avPlayer.volume = volume*adjustvolume;
    }
    
    [avPlayer play];

}

-(void) keyWithSound2:(UInt16) key
{
    CGFloat rate= 1.0;
    CGFloat pan = 0.0;
    CGFloat adjustvolume = [PriterUserDefaults getSoundVolum].integerValue/100.0;
    CGFloat volume = 0;
    NSString* sound = @"bubble_1";
    switch( key ){
        case 125: // scrollDown
            rate = [self ofRandom:0.85: 1.0];
            pan = -0.7;
            volume = 1.0;
            sound = @"bubble_scroll_down";
            break;
        case 126: // scrollUp
            rate = [self ofRandom:0.85 : 1.0];
            pan = -0.7;
            volume = 1.0;
            sound = @"bubble_scroll_up";
            break;
        case 51: // backspace
            rate = [self ofRandom:0.97: 1.03];
            volume = 1.0;
            pan = 0.75;
            sound = @"bubble_backspace";
            break;
        case 49: // space
            rate = [self ofRandom:0.95 : 1.05];
            volume = [self ofRandom:0.8: 1.1];
            sound = @"bubble_space";
            break;
        case 36: // return
            rate = [self ofRandom:0.99: 1.01];
            volume = [self ofRandom:0.7: 1.1];
            pan = 0.3;
            sound = @"bubble_enter";
            break;
        default:
            rate = [self ofRandom:0.98: 1.02];
            volume = [self ofRandom:0.7: 1.1];
            int soundtype =(int)(random() % 5);
            if (soundtype==0) {
                soundtype++;
            }
            sound =[ NSString stringWithFormat:@"bubble_%d",soundtype];
            
            if( key == 12 || key == 13 || key == 0 || key == 1 || key == 6 || key == 7 ) {
                pan = -0.65;
            } else if( key == 35 || key == 37 || key == 43 || key == 31 || key == 40 || key == 46 ) {
                pan = 0.65;
            } else {
                pan = [self ofRandom:-0.3: 0.3];
            }
            break;
    }
    
    NSURL * soundUrl  = [NSURL fileURLWithPath:[[NSBundle mainBundle]pathForResource:(sound) ofType:@"wav"]];
    NSError *error;
    avPlayer =  [[AVAudioPlayer alloc] initWithContentsOfURL:soundUrl error:&error];
    avPlayer.rate = rate;
    avPlayer.pan = pan;
    if (isTempForbidden) {
        avPlayer.volume = 0;
    }else
    {
        avPlayer.volume = volume*adjustvolume;
    }
    
    [avPlayer play];
    

}


-(void) keyWithSound3:(UInt16) key
{
    CGFloat rate= 1.0;
    CGFloat pan = 0.0;
    CGFloat adjustvolume = [PriterUserDefaults getSoundVolum].integerValue/100.0;
    CGFloat volume = 0;
    NSString* sound = @"G80-3000_fast1";
    switch( key ){
        case 125: // scrollDown
            rate = [self ofRandom:0.85: 1.0];
            pan = -0.7;
            volume = 1.0;
            sound = @"G80-3000_slow2";
            break;
        case 126: // scrollUp
            rate = [self ofRandom:0.85 : 1.0];
            pan = -0.7;
            volume = 1.0;
            sound = @"G80-3000_slow1";
            break;
        case 51: // backspace
            rate = [self ofRandom:0.97: 1.03];
            volume = 1.0;
            pan = 0.75;
            sound = @"G80-3000_slow2";
            break;
        case 49: // space
            rate = [self ofRandom:0.95 : 1.05];
            volume = [self ofRandom:0.8: 1.1];
            sound = @"G80-3000_slow2";
            break;
        case 36: // return
            rate = [self ofRandom:0.99: 1.01];
            volume = [self ofRandom:0.7: 1.1];
            pan = 0.3;
            sound = @"G80-3000_slow1";
            break;
        default:
            rate = [self ofRandom:0.98: 1.02];
            volume = [self ofRandom:0.7: 1.1];
            int soundtype=(int)(random() % 2);
            if (soundtype==0) {
                soundtype++;
            }
            sound =[ NSString stringWithFormat:@"G80-3000_fast%d",soundtype];
            
            if( key == 12 || key == 13 || key == 0 || key == 1 || key == 6 || key == 7 ) {
                pan = -0.65;
            } else if( key == 35 || key == 37 || key == 43 || key == 31 || key == 40 || key == 46 ) {
                pan = 0.65;
            } else {
                pan = [self ofRandom:-0.3: 0.3];
            }
            break;
    }
    
    NSURL * soundUrl  = [NSURL fileURLWithPath:[[NSBundle mainBundle]pathForResource:(sound) ofType:@"wav"]];
    NSError *error;
    avPlayer =  [[AVAudioPlayer alloc] initWithContentsOfURL:soundUrl error:&error];
    avPlayer.rate = rate;
    avPlayer.pan = pan;
    if (isTempForbidden) {
        avPlayer.volume = 0;
    }else
    {
        avPlayer.volume = volume*adjustvolume;
    }
    
    [avPlayer play];
    

}


-(void) keyWithSound4:(UInt16) key
{
    CGFloat rate= 1.0;
    CGFloat pan = 0.0;
    CGFloat adjustvolume = [PriterUserDefaults getSoundVolum].integerValue/100.0;
    CGFloat volume = 0;
    NSString* sound = @"G80-3494_fast1";
    switch( key ){
        case 125: // scrollDown
            rate = [self ofRandom:0.85: 1.0];
            pan = -0.7;
            volume = 1.0;
            sound = @"G80-3494_slow1";
            break;
        case 126: // scrollUp
            rate = [self ofRandom:0.85 : 1.0];
            pan = -0.7;
            volume = 1.0;
            sound = @"G80-3494_slow1";
            break;
        case 51: // backspace
            rate = [self ofRandom:0.97: 1.03];
            volume = 1.0;
            pan = 0.75;
            sound = @"G80-3494_backspace";
            break;
        case 49: // space
            rate = [self ofRandom:0.95 : 1.05];
            volume = [self ofRandom:0.8: 1.1];
            sound = @"G80-3494_space";
            break;
        case 36: // return
            rate = [self ofRandom:0.99: 1.01];
            volume = [self ofRandom:0.7: 1.1];
            pan = 0.3;
            sound = @"G80-3494_enter";
            break;
        default:
            rate = [self ofRandom:0.98: 1.02];
            volume = [self ofRandom:0.7: 1.1];
            sound =@"G80-3494_fast1";
            
            if( key == 12 || key == 13 || key == 0 || key == 1 || key == 6 || key == 7 ) {
                pan = -0.65;
            } else if( key == 35 || key == 37 || key == 43 || key == 31 || key == 40 || key == 46 ) {
                pan = 0.65;
            } else {
                pan = [self ofRandom:-0.3: 0.3];
            }
            break;
    }
    
    NSURL * soundUrl  = [NSURL fileURLWithPath:[[NSBundle mainBundle]pathForResource:(sound) ofType:@"wav"]];
    NSError *error;
    avPlayer =  [[AVAudioPlayer alloc] initWithContentsOfURL:soundUrl error:&error];
    avPlayer.rate = rate;
    avPlayer.pan = pan;
    if (isTempForbidden) {
        avPlayer.volume = 0;
    }else
    {
        avPlayer.volume = volume*adjustvolume;
    }
    
    [avPlayer play];
    

}


-(void) keyWithSound5:(UInt16) key
{
    CGFloat rate= 1.0;
    CGFloat pan = 0.0;
    CGFloat adjustvolume = [PriterUserDefaults getSoundVolum].integerValue/100.0;
    CGFloat volume = 0;
    NSString* sound = @"mechanical_1";
    switch( key ){
        case 125: // scrollDown
            rate = [self ofRandom:0.85: 1.0];
            pan = -0.7;
            volume = 1.0;
            sound = @"mechanical_2";
            break;
        case 126: // scrollUp
            rate = [self ofRandom:0.85 : 1.0];
            pan = -0.7;
            volume = 1.0;
            sound = @"mechanical_2";
            break;
        case 51: // backspace
            rate = [self ofRandom:0.97: 1.03];
            volume = 1.0;
            pan = 0.75;
            sound = @"mechanical_backspace";
            break;
        case 49: // space
            rate = [self ofRandom:0.95 : 1.05];
            volume = [self ofRandom:0.8: 1.1];
            sound = @"mechanical_space";
            break;
        case 36: // return
            rate = [self ofRandom:0.99: 1.01];
            volume = [self ofRandom:0.7: 1.1];
            pan = 0.3;
            sound = @"mechanical_enter";
            break;
        default:
            rate = [self ofRandom:0.98: 1.02];
            volume = [self ofRandom:0.7: 1.1];
            int soundtype=(int)(random() % 2);
            if (soundtype==0) {
                soundtype++;
            }
            
            sound =[ NSString stringWithFormat:@"mechanical_%d",soundtype];
            
            if( key == 12 || key == 13 || key == 0 || key == 1 || key == 6 || key == 7 ) {
                pan = -0.65;
            } else if( key == 35 || key == 37 || key == 43 || key == 31 || key == 40 || key == 46 ) {
                pan = 0.65;
            } else {
                pan = [self ofRandom:-0.3: 0.3];
            }
            break;
    }
    
    NSURL * soundUrl  = [NSURL fileURLWithPath:[[NSBundle mainBundle]pathForResource:(sound) ofType:@"wav"]];
    NSError *error;
    avPlayer =  [[AVAudioPlayer alloc] initWithContentsOfURL:soundUrl error:&error];
    avPlayer.rate = rate;
    avPlayer.pan = pan;
    if (isTempForbidden) {
        avPlayer.volume = 0;
    }else
    {
        avPlayer.volume = volume*adjustvolume;
    }
    
    [avPlayer play];
    

}


-(void) keyWithSound6:(UInt16) key
{
    CGFloat rate= 1.0;
    CGFloat pan = 0.0;
    CGFloat adjustvolume = [PriterUserDefaults getSoundVolum].integerValue/100.0;
    CGFloat volume = 0;
    NSString* sound = @"sword_1";
    switch( key ){
        case 125: // scrollDown
            rate = [self ofRandom:0.85: 1.0];
            pan = -0.7;
            volume = 1.0;
            sound = @"sword_4";
            break;
        case 126: // scrollUp
            rate = [self ofRandom:0.85 : 1.0];
            pan = -0.7;
            volume = 1.0;
            sound = @"sword_6";
            break;
        case 51: // backspace
            rate = [self ofRandom:0.97: 1.03];
            volume = 1.0;
            pan = 0.75;
            sound = @"sword_back";
            break;
        case 49: // space
            rate = [self ofRandom:0.95 : 1.05];
            volume = [self ofRandom:0.8: 1.1];
            sound = @"sword_space";
            break;
        case 36: // return
            rate = [self ofRandom:0.99: 1.01];
            volume = [self ofRandom:0.7: 1.1];
            pan = 0.3;
            sound = @"sword_enter";
            break;
        default:
            rate = [self ofRandom:0.98: 1.02];
            volume = [self ofRandom:0.7: 1.1];
            int soundtype=(int)(random() % 7);;
            if (soundtype==0) {
                soundtype++;
            }
            sound =[ NSString stringWithFormat:@"sword_%d",soundtype];
            
            if( key == 12 || key == 13 || key == 0 || key == 1 || key == 6 || key == 7 ) {
                pan = -0.65;
            } else if( key == 35 || key == 37 || key == 43 || key == 31 || key == 40 || key == 46 ) {
                pan = 0.65;
            } else {
                pan = [self ofRandom:-0.3: 0.3];
            }
            break;
    }
    
    NSURL * soundUrl  = [NSURL fileURLWithPath:[[NSBundle mainBundle]pathForResource:(sound) ofType:@"wav"]];
    NSError *error;
    avPlayer =  [[AVAudioPlayer alloc] initWithContentsOfURL:soundUrl error:&error];
    avPlayer.rate = rate;
    avPlayer.pan = pan;
    if (isTempForbidden) {
        avPlayer.volume = 0;
    }else
    {
        avPlayer.volume = volume*adjustvolume;
    }
    
    [avPlayer play];
    

}



-(void) keyWithSound7:(UInt16) key
{
    CGFloat rate= 1.0;
    CGFloat pan = 0.0;
    CGFloat adjustvolume = [PriterUserDefaults getSoundVolum].integerValue/100.0;
    CGFloat volume = 0;
    NSString* sound = @"drum-01";
    switch( key ){
        case 125: // scrollDown
            rate = [self ofRandom:0.85: 1.0];
            pan = -0.7;
            volume = 1.0;
            sound = @"drum-03";
            break;
        case 126: // scrollUp
            rate = [self ofRandom:0.85 : 1.0];
            pan = -0.7;
            volume = 1.0;
            sound = @"drum-04";
            break;
        case 51: // backspace
            rate = [self ofRandom:0.97: 1.03];
            volume = 1.0;
            pan = 0.75;
            sound = @"drum-backspace";
            break;
        case 49: // space
            rate = [self ofRandom:0.95 : 1.05];
            volume = [self ofRandom:0.8: 1.1];
            sound = @"drum-space";
            break;
        case 36: // return
            rate = [self ofRandom:0.99: 1.01];
            volume = [self ofRandom:0.7: 1.1];
            pan = 0.3;
            sound = @"drum-enter";
            break;
        default:
            rate = [self ofRandom:0.98: 1.02];
            volume = [self ofRandom:0.7: 1.1];
            sound =[ NSString stringWithFormat:@"drum-0%d",(int)(random() % 4 + 1)];
            
            if( key == 12 || key == 13 || key == 0 || key == 1 || key == 6 || key == 7 ) {
                pan = -0.65;
            } else if( key == 35 || key == 37 || key == 43 || key == 31 || key == 40 || key == 46 ) {
                pan = 0.65;
            } else {
                pan = [self ofRandom:-0.3: 0.3];
            }
            break;
    }
    
    NSURL * soundUrl  = [NSURL fileURLWithPath:[[NSBundle mainBundle]pathForResource:(sound) ofType:@"wav"]];
    NSError *error;
    avPlayer =  [[AVAudioPlayer alloc] initWithContentsOfURL:soundUrl error:&error];
    avPlayer.rate = rate;
    avPlayer.pan = pan;
    if (isTempForbidden) {
        avPlayer.volume = 0;
    }else
    {
        avPlayer.volume = volume*adjustvolume;
    }
    
    [avPlayer play];
    
}


-(void) autoLunchApp
{
    [[NSNotificationCenter defaultCenter] postNotificationName:PriterAutoLunch object:nil];
    if (autoLunch.state == 0) {
        autoLunch.state = 1;
    }else
    {
        autoLunch.state = 0;
    }
}


-(void) tempForbiddenApp:(NSMenuItem*) item
{
    if (isTempForbidden) {
         [[NSNotificationCenter defaultCenter] postNotificationName:PriterTempForbiddenFromDock object:nil userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithInteger: 0]forKey:@"temp_forbidden"]];
        tempForbidden.state = 0;
       
    }else
    {
         [[NSNotificationCenter defaultCenter] postNotificationName:PriterTempForbiddenFromDock object:nil userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithInteger: 1]forKey:@"temp_forbidden"]];
        tempForbidden.state = 1;
    }
    isTempForbidden = !isTempForbidden;

}

-(void) showAppInDock:(NSMenuItem *) item
{
    BOOL iscan = [PriterUserDefaults getShowInDock];
    [PriterUserDefaults setShowInDock:!iscan];
    [PriterUtils toggleDockIcon:!iscan];
    [[NSNotificationCenter defaultCenter] postNotificationName:PriterHideAppIcon object:nil];
    if (!iscan) {
        showInDock.state = 1;
    }else
    {
        showInDock.state = 0;
    }

  
}

-(void) defaultSoundAction
{
    [PriterUserDefaults setSoundType:1];
    [[NSNotificationCenter defaultCenter] postNotificationName:PriterSelectSound object:nil userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithInteger: 1 ]forKey:@"sound_type"]];

}

-(void) bubbleSoundAction
{
    [PriterUserDefaults setSoundType:2];
    [[NSNotificationCenter defaultCenter] postNotificationName:PriterSelectSound object:nil userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithInteger: 2 ]forKey:@"sound_type"]];
}

-(void) g80_3000SoundAction
{
    [PriterUserDefaults setSoundType:3];
    [[NSNotificationCenter defaultCenter] postNotificationName:PriterSelectSound object:nil userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithInteger: 3 ]forKey:@"sound_type"]];
}

-(void) g80_3494SoundAction
{
    [PriterUserDefaults setSoundType:4];
    [[NSNotificationCenter defaultCenter] postNotificationName:PriterSelectSound object:nil userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithInteger: 4 ]forKey:@"sound_type"]];
}

-(void) mechanicalSoundAction
{
    [PriterUserDefaults setSoundType:5];
    [[NSNotificationCenter defaultCenter] postNotificationName:PriterSelectSound object:nil userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithInteger: 5 ]forKey:@"sound_type"]];
}

-(void) swordSoundAction
{
    [PriterUserDefaults setSoundType:6];
    [[NSNotificationCenter defaultCenter] postNotificationName:PriterSelectSound object:nil userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithInteger: 6 ]forKey:@"sound_type"]];
    
}

-(void) drumBeatSoundAction
{
    [PriterUserDefaults setSoundType:7];
    [[NSNotificationCenter defaultCenter] postNotificationName:PriterSelectSound object:nil userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithInteger: 7 ]forKey:@"sound_type"]];
    
}

-(void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
