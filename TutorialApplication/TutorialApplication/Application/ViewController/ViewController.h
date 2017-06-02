//
//  ViewController.h
//  TutorialApplication
//
//  Created by Alireza Arabi on 9/16/16.
//  Copyright © 2016 Flieral Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextView *firstPlacementTextView;

@property (weak, nonatomic) IBOutlet UITextView *secondPlacementTextView;

- (IBAction)firstButtonClicked:(id)sender;

- (IBAction)secondButtonClicked:(id)sender;

@end

