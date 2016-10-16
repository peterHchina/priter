//
//  PriterPoPViewController.h
//  Priter
//
//  Created by peter on 15/12/22.
//  Copyright © 2015年 peter. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PriterLogoView.h"
FOUNDATION_EXPORT NSString * const PriterTempForbidden;
FOUNDATION_EXPORT NSString * const PriterAdjustVolume;
FOUNDATION_EXPORT NSString * const PriterSelectSound;
FOUNDATION_EXPORT NSString * const PriterHideAppIcon ;
FOUNDATION_EXPORT NSString * const PriterAutoLunch ;
FOUNDATION_EXPORT NSString * const PriterTempForbiddenFromDock;
@interface PriterPoPViewController : NSViewController
- (IBAction)quit:(id)sender;
- (IBAction)setDockIcon:(NSButton *)sender;
- (IBAction)setLaunch:(id)sender;
- (IBAction)tempForbidden:(id)sender;
- (IBAction)adjustTheVolum:(NSSlider *)sender;
@property (strong) IBOutlet PriterLogoView *appIconView;
@property (strong) IBOutlet NSButton *showInDockButton;
@property (strong) IBOutlet NSButton *autonLunchButton;
@property (strong) IBOutlet NSButton *tempForbiddenButton;
@property (strong) IBOutlet NSSlider *volumeSlider;
@property (strong) IBOutlet NSButton *closeButton;
@property (strong) IBOutlet NSPopUpButton *soundSelectButton;
- (IBAction)selectDefaultSound:(id)sender;
- (IBAction)selectBubbleSound:(id)sender;
- (IBAction)selectG803Sound:(id)sender;
- (IBAction)selectG804Sound:(id)sender;

- (IBAction)selectMechanicalSound:(id)sender;

- (IBAction)selectSwordSound:(id)sender;

- (IBAction)selectDrumbeatSound:(id)sender;


@property (strong) IBOutlet NSMenuItem *defaultSound;
@property (strong) IBOutlet NSMenuItem *bubbleSound;
@property (strong) IBOutlet NSMenuItem *g80_3000Sound;
@property (strong) IBOutlet NSMenuItem *g80_3494Sound;
@property (strong) IBOutlet NSMenuItem *mechanicalSound;
@property (strong) IBOutlet NSMenuItem *swordSound;
@property (strong) IBOutlet NSMenuItem *drumBeatSound;

@end
