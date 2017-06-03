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
    [[[FlieralSDKEngine SDKEngine] GetPlacementWithHashID:@""] SetParentViewController:self];

    [[[FlieralSDKEngine SDKEngine] GetPlacementWithHashID:@""] SetPreLoadBlock:^(NSDictionary * _Nonnull details) {
        NSLog(@"Inside Placement #1 - Trigger Fired: Preload");
    }];
    
    [[[FlieralSDKEngine SDKEngine] GetPlacementWithHashID:@""] SetDidLoadBlock:^(NSDictionary * _Nonnull details) {
        NSLog(@"Inside Placement #1 - Trigger Fired: DidLoad");
    }];
    
    [[[FlieralSDKEngine SDKEngine] GetPlacementWithHashID:@""] SetFailedLoadBlock:^(NSDictionary * _Nonnull details) {
        NSLog(@"Inside Placement #1 - Trigger Fired: FailedLoad");
    }];
    
    [[[FlieralSDKEngine SDKEngine] GetPlacementWithHashID:@""] SetWillAppearBlock:^(NSDictionary * _Nonnull details) {
        NSLog(@"Inside Placement #1 - Trigger Fired: WillAppear");
    }];
    
    [[[FlieralSDKEngine SDKEngine] GetPlacementWithHashID:@""] SetDidAppearBlock:^(NSDictionary * _Nonnull details) {
        NSLog(@"Inside Placement #1 - Trigger Fired: DidAppear");
    }];
    
    [[[FlieralSDKEngine SDKEngine] GetPlacementWithHashID:@""] SetWillDisappearBlock:^(NSDictionary * _Nonnull details) {
        NSLog(@"Inside Placement #1 - Trigger Fired: WillDisappear");
    }];
    
    [[[FlieralSDKEngine SDKEngine] GetPlacementWithHashID:@""] SetDidDisappearBlock:^(NSDictionary * _Nonnull details) {
        NSLog(@"Inside Placement #1 - Trigger Fired: DidDisappear");
    }];
}

- (void)configuringSecondPlacement
{
    [[[FlieralSDKEngine SDKEngine] GetPlacementWithHashID:@""] SetParentViewController:self];
    
    [[[FlieralSDKEngine SDKEngine] GetPlacementWithHashID:@""] SetPreLoadBlock:^(NSDictionary * _Nonnull details) {
        NSLog(@"Inside Placement #2 - Trigger Fired: Preload");
    }];
    
    [[[FlieralSDKEngine SDKEngine] GetPlacementWithHashID:@""] SetDidLoadBlock:^(NSDictionary * _Nonnull details) {
        NSLog(@"Inside Placement #2 - Trigger Fired: DidLoad");
    }];
    
    [[[FlieralSDKEngine SDKEngine] GetPlacementWithHashID:@""] SetFailedLoadBlock:^(NSDictionary * _Nonnull details) {
        NSLog(@"Inside Placement #2 - Trigger Fired: FailedLoad");
    }];
    
    [[[FlieralSDKEngine SDKEngine] GetPlacementWithHashID:@""] SetWillAppearBlock:^(NSDictionary * _Nonnull details) {
        NSLog(@"Inside Placement #2 - Trigger Fired: WillAppear");
    }];
    
    [[[FlieralSDKEngine SDKEngine] GetPlacementWithHashID:@""] SetDidAppearBlock:^(NSDictionary * _Nonnull details) {
        NSLog(@"Inside Placement #2 - Trigger Fired: DidAppear");
    }];
    
    [[[FlieralSDKEngine SDKEngine] GetPlacementWithHashID:@""] SetWillDisappearBlock:^(NSDictionary * _Nonnull details) {
        NSLog(@"Inside Placement #2 - Trigger Fired: WillDisappear");
    }];
    
    [[[FlieralSDKEngine SDKEngine] GetPlacementWithHashID:@""] SetDidDisappearBlock:^(NSDictionary * _Nonnull details) {
        NSLog(@"Inside Placement #2 - Trigger Fired: DidDisappear");
    }];
}

- (void)configuringThirdPlacement
{
    [[[FlieralSDKEngine SDKEngine] GetPlacementWithHashID:@""] SetParentViewController:self];
    
    [[[FlieralSDKEngine SDKEngine] GetPlacementWithHashID:@""] SetPreLoadBlock:^(NSDictionary * _Nonnull details) {
        NSLog(@"Inside Placement #3 - Trigger Fired: Preload");
    }];
    
    [[[FlieralSDKEngine SDKEngine] GetPlacementWithHashID:@""] SetDidLoadBlock:^(NSDictionary * _Nonnull details) {
        NSLog(@"Inside Placement #3 - Trigger Fired: DidLoad");
    }];
    
    [[[FlieralSDKEngine SDKEngine] GetPlacementWithHashID:@""] SetFailedLoadBlock:^(NSDictionary * _Nonnull details) {
        NSLog(@"Inside Placement #3 - Trigger Fired: FailedLoad");
    }];
    
    [[[FlieralSDKEngine SDKEngine] GetPlacementWithHashID:@""] SetWillAppearBlock:^(NSDictionary * _Nonnull details) {
        NSLog(@"Inside Placement #3 - Trigger Fired: WillAppear");
    }];
    
    [[[FlieralSDKEngine SDKEngine] GetPlacementWithHashID:@""] SetDidAppearBlock:^(NSDictionary * _Nonnull details) {
        NSLog(@"Inside Placement #3 - Trigger Fired: DidAppear");
    }];
    
    [[[FlieralSDKEngine SDKEngine] GetPlacementWithHashID:@""] SetWillDisappearBlock:^(NSDictionary * _Nonnull details) {
        NSLog(@"Inside Placement #3 - Trigger Fired: WillDisappear");
    }];
    
    [[[FlieralSDKEngine SDKEngine] GetPlacementWithHashID:@""] SetDidDisappearBlock:^(NSDictionary * _Nonnull details) {
        NSLog(@"Inside Placement #3 - Trigger Fired: DidDisappear");
    }];
}

#pragma mark - Button Handlers

- (IBAction)firstButtonClicked:(id)sender
{
    [[[FlieralSDKEngine SDKEngine] GetPlacementWithHashID:@""] Show];
}

- (IBAction)secondButtonClicked:(id)sender
{
    [[[FlieralSDKEngine SDKEngine] GetPlacementWithHashID:@""] Show];
}

- (IBAction)thirdButtonClicked:(id)sender
{
    [[[FlieralSDKEngine SDKEngine] GetPlacementWithHashID:@""] Show];
}

@end
