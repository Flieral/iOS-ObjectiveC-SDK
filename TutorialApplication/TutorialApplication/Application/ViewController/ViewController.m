//
//  ViewController.m
//  TutorialApplication
//
//  Created by Alireza Arabi on 9/16/16.
//  Copyright © 2016 Flieral Inc. All rights reserved.
//

#import "ViewController.h"
#import "FlieralSDKEngine.h"

#define FIRST_PLACEMENT         @"593a381a6f16aeabd64fcf86"
#define SECOND_PLACEMENT        @"593a388b6f16aeabd64fcf88"
#define THIRD_PLACEMENT         @"593a38f76f16aeabd64fcf8a"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
	[super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self configuringFirstPlacement];
    [self configuringSecondPlacement];
    [self configuringThirdPlacement];
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
}

#pragma mark - Settings

- (void)configuringFirstPlacement
{
    [[[FlieralSDKEngine SDKEngine] GetPlacementWithHashID:FIRST_PLACEMENT] SetParentViewController:self];

    [[[FlieralSDKEngine SDKEngine] GetPlacementWithHashID:FIRST_PLACEMENT] SetPreLoadBlock:^(NSMutableDictionary * _Nonnull details) {
        NSLog(@"Inside Placement #1 - Trigger Fired: Preload");
    }];
    
    [[[FlieralSDKEngine SDKEngine] GetPlacementWithHashID:FIRST_PLACEMENT] SetDidLoadBlock:^(NSMutableDictionary * _Nonnull details) {
        NSLog(@"Inside Placement #1 - Trigger Fired: DidLoad");
    }];
    
    [[[FlieralSDKEngine SDKEngine] GetPlacementWithHashID:FIRST_PLACEMENT] SetFailedLoadBlock:^(NSMutableDictionary * _Nonnull details) {
        NSLog(@"Inside Placement #1 - Trigger Fired: FailedLoad");
    }];
    
    [[[FlieralSDKEngine SDKEngine] GetPlacementWithHashID:FIRST_PLACEMENT] SetWillAppearBlock:^(NSMutableDictionary * _Nonnull details) {
        NSLog(@"Inside Placement #1 - Trigger Fired: WillAppear");
    }];
    
    [[[FlieralSDKEngine SDKEngine] GetPlacementWithHashID:FIRST_PLACEMENT] SetDidAppearBlock:^(NSMutableDictionary * _Nonnull details) {
        NSLog(@"Inside Placement #1 - Trigger Fired: DidAppear");
    }];
    
    [[[FlieralSDKEngine SDKEngine] GetPlacementWithHashID:FIRST_PLACEMENT] SetWillDisappearBlock:^(NSMutableDictionary * _Nonnull details) {
        NSLog(@"Inside Placement #1 - Trigger Fired: WillDisappear");
    }];
    
    [[[FlieralSDKEngine SDKEngine] GetPlacementWithHashID:FIRST_PLACEMENT] SetDidDisappearBlock:^(NSMutableDictionary * _Nonnull details) {
        NSLog(@"Inside Placement #1 - Trigger Fired: DidDisappear");
    }];
}

- (void)configuringSecondPlacement
{
    [[[FlieralSDKEngine SDKEngine] GetPlacementWithHashID:SECOND_PLACEMENT] SetParentViewController:self];
    
    [[[FlieralSDKEngine SDKEngine] GetPlacementWithHashID:SECOND_PLACEMENT] SetPreLoadBlock:^(NSMutableDictionary * _Nonnull details) {
        NSLog(@"Inside Placement #2 - Trigger Fired: Preload");
    }];
    
    [[[FlieralSDKEngine SDKEngine] GetPlacementWithHashID:SECOND_PLACEMENT] SetDidLoadBlock:^(NSMutableDictionary * _Nonnull details) {
        NSLog(@"Inside Placement #2 - Trigger Fired: DidLoad");
    }];
    
    [[[FlieralSDKEngine SDKEngine] GetPlacementWithHashID:SECOND_PLACEMENT] SetFailedLoadBlock:^(NSMutableDictionary * _Nonnull details) {
        NSLog(@"Inside Placement #2 - Trigger Fired: FailedLoad");
    }];
    
    [[[FlieralSDKEngine SDKEngine] GetPlacementWithHashID:SECOND_PLACEMENT] SetWillAppearBlock:^(NSMutableDictionary * _Nonnull details) {
        NSLog(@"Inside Placement #2 - Trigger Fired: WillAppear");
    }];
    
    [[[FlieralSDKEngine SDKEngine] GetPlacementWithHashID:SECOND_PLACEMENT] SetDidAppearBlock:^(NSMutableDictionary * _Nonnull details) {
        NSLog(@"Inside Placement #2 - Trigger Fired: DidAppear");
    }];
    
    [[[FlieralSDKEngine SDKEngine] GetPlacementWithHashID:SECOND_PLACEMENT] SetWillDisappearBlock:^(NSMutableDictionary * _Nonnull details) {
        NSLog(@"Inside Placement #2 - Trigger Fired: WillDisappear");
    }];
    
    [[[FlieralSDKEngine SDKEngine] GetPlacementWithHashID:SECOND_PLACEMENT] SetDidDisappearBlock:^(NSMutableDictionary * _Nonnull details) {
        NSLog(@"Inside Placement #2 - Trigger Fired: DidDisappear");
    }];
}

- (void)configuringThirdPlacement
{
    [[[FlieralSDKEngine SDKEngine] GetPlacementWithHashID:THIRD_PLACEMENT] SetParentViewController:self];
    
    [[[FlieralSDKEngine SDKEngine] GetPlacementWithHashID:THIRD_PLACEMENT] SetPreLoadBlock:^(NSMutableDictionary * _Nonnull details) {
        NSLog(@"Inside Placement #3 - Trigger Fired: Preload");
    }];
    
    [[[FlieralSDKEngine SDKEngine] GetPlacementWithHashID:THIRD_PLACEMENT] SetDidLoadBlock:^(NSMutableDictionary * _Nonnull details) {
        NSLog(@"Inside Placement #3 - Trigger Fired: DidLoad");
    }];
    
    [[[FlieralSDKEngine SDKEngine] GetPlacementWithHashID:THIRD_PLACEMENT] SetFailedLoadBlock:^(NSMutableDictionary * _Nonnull details) {
        NSLog(@"Inside Placement #3 - Trigger Fired: FailedLoad");
    }];
    
    [[[FlieralSDKEngine SDKEngine] GetPlacementWithHashID:THIRD_PLACEMENT] SetWillAppearBlock:^(NSMutableDictionary * _Nonnull details) {
        NSLog(@"Inside Placement #3 - Trigger Fired: WillAppear");
    }];
    
    [[[FlieralSDKEngine SDKEngine] GetPlacementWithHashID:THIRD_PLACEMENT] SetDidAppearBlock:^(NSMutableDictionary * _Nonnull details) {
        NSLog(@"Inside Placement #3 - Trigger Fired: DidAppear");
    }];
    
    [[[FlieralSDKEngine SDKEngine] GetPlacementWithHashID:THIRD_PLACEMENT] SetWillDisappearBlock:^(NSMutableDictionary * _Nonnull details) {
        NSLog(@"Inside Placement #3 - Trigger Fired: WillDisappear");
    }];
    
    [[[FlieralSDKEngine SDKEngine] GetPlacementWithHashID:THIRD_PLACEMENT] SetDidDisappearBlock:^(NSMutableDictionary * _Nonnull details) {
        NSLog(@"Inside Placement #3 - Trigger Fired: DidDisappear");
    }];
}

#pragma mark - Button Handlers

- (IBAction)firstButtonClicked:(id)sender
{
    [[[FlieralSDKEngine SDKEngine] GetPlacementWithHashID:FIRST_PLACEMENT] Show];
}

- (IBAction)secondButtonClicked:(id)sender
{
    [[[FlieralSDKEngine SDKEngine] GetPlacementWithHashID:SECOND_PLACEMENT] Show];
}

- (IBAction)thirdButtonClicked:(id)sender
{
    [[[FlieralSDKEngine SDKEngine] GetPlacementWithHashID:THIRD_PLACEMENT] Show];
}

@end
