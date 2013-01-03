//
//  FirstTopViewController.m
//  ECSlidingViewController
//
//  Created by Michael Enriquez on 1/23/12.
//  Copyright (c) 2012 EdgeCase. All rights reserved.
//

#import "FirstTopViewController.h"

@implementation FirstTopViewController

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  
  // shadowPath, shadowOffset, and rotation is handled by ECSlidingViewController.
  // You just need to set the opacity, radius, and color.
  self.view.layer.shadowOpacity = 0.75f;
  self.view.layer.shadowRadius = 10.0f;
  self.view.layer.shadowColor = [UIColor blackColor].CGColor;
  
  if (![self.slidingViewController.underTopViewController isKindOfClass:[NorthernViewController class]]) {
    self.slidingViewController.underTopViewController  = [self.storyboard instantiateViewControllerWithIdentifier:@"Northern"];
  }
  
  if (![self.slidingViewController.underBottomViewController isKindOfClass:[SouthernViewController class]]) {
    self.slidingViewController.underBottomViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"Southern"];
  }
  
  [self.view addGestureRecognizer:self.slidingViewController.panGesture];
}

- (IBAction)revealMenu:(id)sender
{
  [self.slidingViewController anchorTopViewTo:ECBottom];
}

- (IBAction)revealUnderRight:(id)sender
{
  [self.slidingViewController anchorTopViewTo:ECLeft];
}

@end