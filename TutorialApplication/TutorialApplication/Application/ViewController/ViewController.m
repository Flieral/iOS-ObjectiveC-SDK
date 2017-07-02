//
//  ViewController.m
//  TutorialApplication
//
//  Created by Alireza Arabi on 9/16/16.
//  Copyright © 2016 Flieral Inc. All rights reserved.
//

#import "ViewController.h"
#import "FlieralSDKEngine.h"

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
    [[[FlieralSDKEngine SDKEngine] GetPlacementFromIndex:0] SetParentViewController:self];

    [[[FlieralSDKEngine SDKEngine] GetPlacementFromIndex:0] SetPreLoadBlock:^(NSMutableDictionary * _Nonnull details) {
        NSLog(@"Inside Placement #1 - Trigger Fired: Preload");
    }];
    
    [[[FlieralSDKEngine SDKEngine] GetPlacementFromIndex:0] SetDidLoadBlock:^(NSMutableDictionary * _Nonnull details) {
        NSLog(@"Inside Placement #1 - Trigger Fired: DidLoad");
    }];
    
    [[[FlieralSDKEngine SDKEngine] GetPlacementFromIndex:0] SetFailedLoadBlock:^(NSMutableDictionary * _Nonnull details) {
        NSLog(@"Inside Placement #1 - Trigger Fired: FailedLoad");
    }];
    
    [[[FlieralSDKEngine SDKEngine] GetPlacementFromIndex:0] SetWillAppearBlock:^(NSMutableDictionary * _Nonnull details) {
        NSLog(@"Inside Placement #1 - Trigger Fired: WillAppear");
    }];
    
    [[[FlieralSDKEngine SDKEngine] GetPlacementFromIndex:0] SetDidAppearBlock:^(NSMutableDictionary * _Nonnull details) {
        NSLog(@"Inside Placement #1 - Trigger Fired: DidAppear");
    }];
    
    [[[FlieralSDKEngine SDKEngine] GetPlacementFromIndex:0] SetWillDisappearBlock:^(NSMutableDictionary * _Nonnull details) {
        NSLog(@"Inside Placement #1 - Trigger Fired: WillDisappear");
    }];
    
    [[[FlieralSDKEngine SDKEngine] GetPlacementFromIndex:0] SetDidDisappearBlock:^(NSMutableDictionary * _Nonnull details) {
        NSLog(@"Inside Placement #1 - Trigger Fired: DidDisappear");
    }];
}

- (void)configuringSecondPlacement
{
    [[[FlieralSDKEngine SDKEngine] GetPlacementFromIndex:1] SetParentViewController:self];
    
    [[[FlieralSDKEngine SDKEngine] GetPlacementFromIndex:1] SetPreLoadBlock:^(NSMutableDictionary * _Nonnull details) {
        NSLog(@"Inside Placement #2 - Trigger Fired: Preload");
    }];
    
    [[[FlieralSDKEngine SDKEngine] GetPlacementFromIndex:1] SetDidLoadBlock:^(NSMutableDictionary * _Nonnull details) {
        NSLog(@"Inside Placement #2 - Trigger Fired: DidLoad");
    }];
    
    [[[FlieralSDKEngine SDKEngine] GetPlacementFromIndex:1] SetFailedLoadBlock:^(NSMutableDictionary * _Nonnull details) {
        NSLog(@"Inside Placement #2 - Trigger Fired: FailedLoad");
    }];
    
    [[[FlieralSDKEngine SDKEngine] GetPlacementFromIndex:1] SetWillAppearBlock:^(NSMutableDictionary * _Nonnull details) {
        NSLog(@"Inside Placement #2 - Trigger Fired: WillAppear");
    }];
    
    [[[FlieralSDKEngine SDKEngine] GetPlacementFromIndex:1] SetDidAppearBlock:^(NSMutableDictionary * _Nonnull details) {
        NSLog(@"Inside Placement #2 - Trigger Fired: DidAppear");
    }];
    
    [[[FlieralSDKEngine SDKEngine] GetPlacementFromIndex:1] SetWillDisappearBlock:^(NSMutableDictionary * _Nonnull details) {
        NSLog(@"Inside Placement #2 - Trigger Fired: WillDisappear");
    }];
    
    [[[FlieralSDKEngine SDKEngine] GetPlacementFromIndex:1] SetDidDisappearBlock:^(NSMutableDictionary * _Nonnull details) {
        NSLog(@"Inside Placement #2 - Trigger Fired: DidDisappear");
    }];
}

- (void)configuringThirdPlacement
{
    [[[FlieralSDKEngine SDKEngine] GetPlacementFromIndex:2] SetParentViewController:self];
    
    [[[FlieralSDKEngine SDKEngine] GetPlacementFromIndex:2] SetPreLoadBlock:^(NSMutableDictionary * _Nonnull details) {
        NSLog(@"Inside Placement #3 - Trigger Fired: Preload");
    }];
    
    [[[FlieralSDKEngine SDKEngine] GetPlacementFromIndex:2] SetDidLoadBlock:^(NSMutableDictionary * _Nonnull details) {
        NSLog(@"Inside Placement #3 - Trigger Fired: DidLoad");
    }];
    
    [[[FlieralSDKEngine SDKEngine] GetPlacementFromIndex:2] SetFailedLoadBlock:^(NSMutableDictionary * _Nonnull details) {
        NSLog(@"Inside Placement #3 - Trigger Fired: FailedLoad");
    }];
    
    [[[FlieralSDKEngine SDKEngine] GetPlacementFromIndex:2] SetWillAppearBlock:^(NSMutableDictionary * _Nonnull details) {
        NSLog(@"Inside Placement #3 - Trigger Fired: WillAppear");
    }];
    
    [[[FlieralSDKEngine SDKEngine] GetPlacementFromIndex:2] SetDidAppearBlock:^(NSMutableDictionary * _Nonnull details) {
        NSLog(@"Inside Placement #3 - Trigger Fired: DidAppear");
    }];
    
    [[[FlieralSDKEngine SDKEngine] GetPlacementFromIndex:2] SetWillDisappearBlock:^(NSMutableDictionary * _Nonnull details) {
        NSLog(@"Inside Placement #3 - Trigger Fired: WillDisappear");
    }];
    
    [[[FlieralSDKEngine SDKEngine] GetPlacementFromIndex:2] SetDidDisappearBlock:^(NSMutableDictionary * _Nonnull details) {
        NSLog(@"Inside Placement #3 - Trigger Fired: DidDisappear");
    }];
}

#pragma mark - Button Handlers

- (IBAction)firstButtonClicked:(id)sender
{
    [[[FlieralSDKEngine SDKEngine] GetPlacementFromIndex:0] Show];
}

- (IBAction)secondButtonClicked:(id)sender
{
    [[[FlieralSDKEngine SDKEngine] GetPlacementFromIndex:1] Show];
}

- (IBAction)thirdButtonClicked:(id)sender
{
    [[[FlieralSDKEngine SDKEngine] GetPlacementFromIndex:2] Show];
}

@end
