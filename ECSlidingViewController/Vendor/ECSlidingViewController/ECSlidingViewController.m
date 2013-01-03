//
//  ECSlidingViewController.m
//  ECSlidingViewController
//
//  Created by Michael Enriquez on 1/23/12.
//  Copyright (c) 2012 EdgeCase. All rights reserved.
//

#import "ECSlidingViewController.h"

NSString *const ECSlidingViewUnderRightWillAppear    = @"ECSlidingViewUnderRightWillAppear";
NSString *const ECSlidingViewUnderLeftWillAppear     = @"ECSlidingViewUnderLeftWillAppear";
NSString *const ECSlidingViewUnderTopWillAppear     = @"ECSlidingViewUnderTopWillAppear";
NSString *const ECSlidingViewUnderBottomWillAppear     = @"ECSlidingViewUnderBottomWillAppear";
NSString *const ECSlidingViewUnderLeftWillDisappear  = @"ECSlidingViewUnderLeftWillDisappear";
NSString *const ECSlidingViewUnderRightWillDisappear = @"ECSlidingViewUnderRightWillDisappear";
NSString *const ECSlidingViewUnderTopWillDisappear = @"ECSlidingViewUnderTopWillDisappear";
NSString *const ECSlidingViewUnderBottomWillDisappear = @"ECSlidingViewUnderBottomWillDisappear";
NSString *const ECSlidingViewTopDidAnchorLeft        = @"ECSlidingViewTopDidAnchorLeft";
NSString *const ECSlidingViewTopDidAnchorRight       = @"ECSlidingViewTopDidAnchorRight";
NSString *const ECSlidingViewTopDidAnchorTop       = @"ECSlidingViewTopDidAnchorTop";
NSString *const ECSlidingViewTopDidAnchorBottom       = @"ECSlidingViewTopDidAnchorBottom";
NSString *const ECSlidingViewTopWillReset            = @"ECSlidingViewTopWillReset";
NSString *const ECSlidingViewTopDidReset             = @"ECSlidingViewTopDidReset";

@interface ECSlidingViewController()

@property (nonatomic, strong) UIView *topViewSnapshot;
@property (nonatomic, unsafe_unretained) CGFloat initialTouchPositionX;
@property (nonatomic, unsafe_unretained) CGFloat initialTouchPositionY;
@property (nonatomic, unsafe_unretained) CGFloat initialHoizontalCenter;
@property (nonatomic, unsafe_unretained) CGFloat initialVerticalCenter;
@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;
@property (nonatomic, strong) UITapGestureRecognizer *resetTapGesture;
@property (nonatomic, strong) UIPanGestureRecognizer *topViewSnapshotPanGesture;
@property (nonatomic, unsafe_unretained) BOOL underLeftShowing;
@property (nonatomic, unsafe_unretained) BOOL underRightShowing;
@property (nonatomic, unsafe_unretained) BOOL underTopShowing;
@property (nonatomic, unsafe_unretained) BOOL underBottomShowing;
@property (nonatomic, unsafe_unretained) BOOL topViewIsOffScreen;

- (NSUInteger)autoResizeToFillScreen;
- (UIView *)topView;
- (UIView *)underLeftView;
- (UIView *)underRightView;
- (UIView *)underTopView;
- (UIView *)underBottomView;
- (void)adjustLayout;       //todo: make horizontal
- (void)adjustLayoutVertical;
- (void)updateTopViewHorizontalCenterWithRecognizer:(UIPanGestureRecognizer *)recognizer;
- (void)updateTopViewVerticalCenterWithRecognizer:(UIPanGestureRecognizer *)recognizer;
- (void)updateTopViewHorizontalCenter:(CGFloat)newHorizontalCenter;
- (void)updateTopViewVerticalCenter:(CGFloat)newHorizontalCenter;
- (void)topViewHorizontalCenterWillChange:(CGFloat)newHorizontalCenter;
- (void)topViewVerticalCenterWillChange:(CGFloat)newHorizontalCenter;
- (void)topViewHorizontalCenterDidChange:(CGFloat)newHorizontalCenter;
- (void)topViewVerticalCenterDidChange:(CGFloat)newHorizontalCenter;
- (void)addTopViewSnapshot; //todo: change this to addTopViewHorizontalSnapshot
- (void)addTopViewVerticalSnapshot;
- (void)removeTopViewSnapshot;
- (CGFloat)anchorRightTopViewCenter;
- (CGFloat)anchorLeftTopViewCenter;
- (CGFloat)anchorTopTopViewCenter;
- (CGFloat)anchorBottomTopViewCenter;
- (CGFloat)resettedCenter;
- (CGFloat)resettedCenterVertical;
- (CGFloat)screenWidth;
- (CGFloat)screenHeight;
- (CGFloat)screenWidthForOrientation:(UIInterfaceOrientation)orientation;
- (CGFloat)screenHeightForOrientation:(UIInterfaceOrientation)orientation;
- (void)underLeftWillAppear;
- (void)underRightWillAppear;
- (void)underTopWillAppear;
- (void)underBottomWillAppear;
- (void)topDidReset;    //todo: change this to topDidResetHorizontal
- (void)topDidResetVertical;
- (BOOL)topViewHasFocus;
- (void)updateUnderLeftLayout;
- (void)updateUnderRightLayout;
- (void)updateUnderTopLayout;
- (void)updateUnderBottomLayout;

@end

@implementation UIViewController(SlidingViewExtension)

- (ECSlidingViewController *)slidingViewController
{
  UIViewController *viewController = self.parentViewController;
  while (!(viewController == nil || [viewController isKindOfClass:[ECSlidingViewController class]])) {
    viewController = viewController.parentViewController;
  }
  
  return (ECSlidingViewController *)viewController;
}

@end

@implementation ECSlidingViewController

// public properties
@synthesize underLeftViewController  = _underLeftViewController;
@synthesize underRightViewController = _underRightViewController;
@synthesize underTopViewController = _underTopViewController;
@synthesize underBottomViewController = _underBottomViewController;
@synthesize topViewController        = _topViewController;
@synthesize anchorLeftPeekAmount;
@synthesize anchorRightPeekAmount;
@synthesize anchorTopPeekAmount;
@synthesize anchorBottomPeekAmount;
@synthesize anchorLeftRevealAmount;
@synthesize anchorRightRevealAmount;
@synthesize anchorTopRevealAmount;
@synthesize anchorBottomRevealAmount;
@synthesize underRightWidthLayout = _underRightWidthLayout;
@synthesize underLeftWidthLayout  = _underLeftWidthLayout;
@synthesize underTopHeightLayout  = _underTopHeightLayout;
@synthesize underBottomHeightLayout  = _underBottomHeightLayout;
@synthesize shouldAllowUserInteractionsWhenAnchored;
@synthesize shouldAddPanGestureRecognizerToTopViewSnapshot;
@synthesize resetStrategy = _resetStrategy;

// category properties
@synthesize topViewSnapshot;
@synthesize initialTouchPositionX;
@synthesize initialTouchPositionY;
@synthesize initialHoizontalCenter;
@synthesize initialVerticalCenter;
@synthesize panGesture = _panGesture;
@synthesize resetTapGesture;
@synthesize underLeftShowing   = _underLeftShowing;
@synthesize underRightShowing  = _underRightShowing;
@synthesize underTopShowing = _underTopShowing;
@synthesize underBottomShowing = _underBottomShowing;
@synthesize topViewIsOffScreen = _topViewIsOffScreen;
@synthesize topViewSnapshotPanGesture = _topViewSnapshotPanGesture;


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark
#pragma mark View Controller Setters 



- (void)setTopViewController:(UIViewController *)theTopViewController
{
  CGRect topViewFrame = _topViewController ? _topViewController.view.frame : self.view.bounds;
  
  [self removeTopViewSnapshot];
  [_topViewController.view removeFromSuperview];
  [_topViewController willMoveToParentViewController:nil];
  [_topViewController removeFromParentViewController];
  
  _topViewController = theTopViewController;
  
  [self addChildViewController:self.topViewController];
  [self.topViewController didMoveToParentViewController:self];
  
  [_topViewController.view setAutoresizingMask:self.autoResizeToFillScreen];
  [_topViewController.view setFrame:topViewFrame];
  _topViewController.view.layer.shadowOffset = CGSizeZero;
  _topViewController.view.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.view.layer.bounds].CGPath;
  
  [self.view addSubview:_topViewController.view];
}

- (void)setUnderLeftViewController:(UIViewController *)theUnderLeftViewController
{
  [_underLeftViewController.view removeFromSuperview];
  [_underLeftViewController willMoveToParentViewController:nil];
  [_underLeftViewController removeFromParentViewController];
  
  _underLeftViewController = theUnderLeftViewController;
  
  if (_underLeftViewController) {
    [self addChildViewController:self.underLeftViewController];
    [self.underLeftViewController didMoveToParentViewController:self];
    
    [self updateUnderLeftLayout];
    
    [self.view insertSubview:_underLeftViewController.view atIndex:0];
  }
}

- (void)setUnderRightViewController:(UIViewController *)theUnderRightViewController
{
  [_underRightViewController.view removeFromSuperview];
  [_underRightViewController willMoveToParentViewController:nil];
  [_underRightViewController removeFromParentViewController];
  
  _underRightViewController = theUnderRightViewController;
  
  if (_underRightViewController) {
    [self addChildViewController:self.underRightViewController];
    [self.underRightViewController didMoveToParentViewController:self];
    
    [self updateUnderRightLayout];
    
    [self.view insertSubview:_underRightViewController.view atIndex:0];
  }
}

- (void)setUnderTopViewController:(UIViewController *)theUnderTopViewController
{
    [_underTopViewController.view removeFromSuperview];
    [_underTopViewController willMoveToParentViewController:nil];
    [_underTopViewController removeFromParentViewController];
    
    _underTopViewController = theUnderTopViewController;
    
    if (_underTopViewController) {
        [self addChildViewController:self.underTopViewController];
        [self.underTopViewController didMoveToParentViewController:self];
        
        [self updateUnderTopLayout];
        
        [self.view insertSubview:_underTopViewController.view atIndex:0];
    }
}

- (void)setUnderBottomViewController:(UIViewController *)theUnderBottomViewController
{
    [_underBottomViewController.view removeFromSuperview];
    [_underBottomViewController willMoveToParentViewController:nil];
    [_underBottomViewController removeFromParentViewController];
    
    _underBottomViewController = theUnderBottomViewController;
    
    if (_underBottomViewController) {
        [self addChildViewController:self.underBottomViewController];
        [self.underBottomViewController didMoveToParentViewController:self];
        
        [self updateUnderBottomLayout];
        
        [self.view insertSubview:_underBottomViewController.view atIndex:0];
    }
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark
#pragma mark Layout Setters


- (void)setUnderLeftWidthLayout:(ECViewWidthLayout)underLeftWidthLayout
{
  if (underLeftWidthLayout == ECVariableRevealWidth && self.anchorRightPeekAmount <= 0) {
    [NSException raise:@"Invalid Width Layout" format:@"anchorRightPeekAmount must be set"];
  } else if (underLeftWidthLayout == ECFixedRevealWidth && self.anchorRightRevealAmount <= 0) {
    [NSException raise:@"Invalid Width Layout" format:@"anchorRightRevealAmount must be set"];
  }
  
  _underLeftWidthLayout = underLeftWidthLayout;
}

- (void)setUnderRightWidthLayout:(ECViewWidthLayout)underRightWidthLayout
{
  if (underRightWidthLayout == ECVariableRevealWidth && self.anchorLeftPeekAmount <= 0) {
    [NSException raise:@"Invalid Width Layout" format:@"anchorLeftPeekAmount must be set"];
  } else if (underRightWidthLayout == ECFixedRevealWidth && self.anchorLeftRevealAmount <= 0) {
    [NSException raise:@"Invalid Width Layout" format:@"anchorLeftRevealAmount must be set"];
  }
  
  _underRightWidthLayout = underRightWidthLayout;
}

- (void)setUnderTopHeightLayout:(ECViewHeightLayout)underTopHeightLayout
{
    if (underTopHeightLayout == ECVariableRevealHeight && self.anchorLeftPeekAmount <= 0) {
        [NSException raise:@"Invalid Height Layout" format:@"anchorLeftPeekAmount must be set"];
    } else if (underTopHeightLayout == ECFixedRevealHeight && self.anchorLeftRevealAmount <= 0) {
        [NSException raise:@"Invalid Height Layout" format:@"anchorLeftRevealAmount must be set"];
    }
    
    _underTopHeightLayout = underTopHeightLayout;
}

- (void)setUnderBottomHeightLayout:(ECViewHeightLayout)underBottomHeightLayout
{
    if (underBottomHeightLayout == ECVariableRevealHeight && self.anchorLeftPeekAmount <= 0) {
        [NSException raise:@"Invalid Height Layout" format:@"anchorLeftPeekAmount must be set"];
    } else if (underBottomHeightLayout == ECFixedRevealHeight && self.anchorLeftRevealAmount <= 0) {
        [NSException raise:@"Invalid Height Layout" format:@"anchorLeftRevealAmount must be set"];
    }
    
    _underBottomHeightLayout = underBottomHeightLayout;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark
#pragma mark View Controller Methods

- (void)viewDidLoad
{
  [super viewDidLoad];
  self.shouldAllowUserInteractionsWhenAnchored = NO;
  self.shouldAddPanGestureRecognizerToTopViewSnapshot = NO;
  self.resetTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resetTopViewVertical)];
  _panGesture          = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(updateTopViewVerticalCenterWithRecognizer:)];
  self.resetTapGesture.enabled = NO;
  self.resetStrategy = ECTapping | ECPanning;
  
  self.topViewSnapshot = [[UIView alloc] initWithFrame:self.topView.bounds];
  [self.topViewSnapshot setAutoresizingMask:self.autoResizeToFillScreen];
  [self.topViewSnapshot addGestureRecognizer:self.resetTapGesture];
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  self.topView.layer.shadowOffset = CGSizeZero;
  self.topView.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.view.layer.bounds].CGPath;
  [self adjustLayout];
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark
#pragma mark Rotation Methods

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
  self.topView.layer.shadowPath = nil;
  self.topView.layer.shouldRasterize = YES;
  
  if(![self topViewHasFocus]){
    [self removeTopViewSnapshot];
  }
  
  [self adjustLayout];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
  self.topView.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.view.layer.bounds].CGPath;
  self.topView.layer.shouldRasterize = NO;
  
  if(![self topViewHasFocus]){
    [self addTopViewSnapshot];
  }
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark
#pragma mark Custom Methods

- (void)setResetStrategy:(ECResetStrategy)theResetStrategy
{
  _resetStrategy = theResetStrategy;
  if (_resetStrategy & ECTapping) {
    self.resetTapGesture.enabled = YES;
  } else {
    self.resetTapGesture.enabled = NO;
  }
}

- (void)adjustLayout
{
  self.topViewSnapshot.frame = self.topView.bounds;
  
  if ([self underRightShowing] && ![self topViewIsOffScreen]) {
    [self updateUnderRightLayout];
    [self updateTopViewHorizontalCenter:self.anchorLeftTopViewCenter];
  } else if ([self underRightShowing] && [self topViewIsOffScreen]) {
    [self updateUnderRightLayout];
    [self updateTopViewHorizontalCenter:-self.resettedCenter];
  } else if ([self underLeftShowing] && ![self topViewIsOffScreen]) {
    [self updateUnderLeftLayout];
    [self updateTopViewHorizontalCenter:self.anchorRightTopViewCenter];
  } else if ([self underLeftShowing] && [self topViewIsOffScreen]) {
    [self updateUnderLeftLayout];
    [self updateTopViewHorizontalCenter:self.screenWidth + self.resettedCenter];
  }
}

- (void)adjustLayoutVertical
{
    self.topViewSnapshot.frame = self.topView.bounds;
    
    if ([self underBottomShowing] && ![self topViewIsOffScreen]) {
        [self updateUnderBottomLayout];
        [self updateTopViewVerticalCenter:self.anchorTopTopViewCenter];
    } else if ([self underBottomShowing] && [self topViewIsOffScreen]) {
        [self updateUnderBottomLayout];
        [self updateTopViewVerticalCenter:-self.resettedCenter];
    } else if ([self underTopShowing] && ![self topViewIsOffScreen]) {
        [self updateUnderTopLayout];
        [self updateTopViewVerticalCenter:self.anchorBottomTopViewCenter];
    } else if ([self underTopShowing] && [self topViewIsOffScreen]) {
        [self updateUnderTopLayout];
        [self updateTopViewVerticalCenter:self.screenWidth + self.resettedCenter];
    }
}

- (void)updateTopViewHorizontalCenterWithRecognizer:(UIPanGestureRecognizer *)recognizer
{
  CGPoint currentTouchPoint     = [recognizer locationInView:self.view];
  CGFloat currentTouchPositionX = currentTouchPoint.x;
  
  if (recognizer.state == UIGestureRecognizerStateBegan) {
    self.initialTouchPositionX = currentTouchPositionX;
    self.initialHoizontalCenter = self.topView.center.x;
  } else if (recognizer.state == UIGestureRecognizerStateChanged) {
    
    CGPoint translation = [recognizer translationInView:self.view];
    
    if(fabs(translation.x) > fabs(translation.y))
    {
      CGFloat panAmount = self.initialTouchPositionX - currentTouchPositionX;
      CGFloat newCenterPosition = self.initialHoizontalCenter - panAmount;
      
      if ((newCenterPosition < self.resettedCenter && self.anchorLeftTopViewCenter == NSNotFound) || (newCenterPosition > self.resettedCenter && self.anchorRightTopViewCenter == NSNotFound)) {
        newCenterPosition = self.resettedCenter;
      }
      
      [self topViewHorizontalCenterWillChange:newCenterPosition];
      [self updateTopViewHorizontalCenter:newCenterPosition];
      [self topViewHorizontalCenterDidChange:newCenterPosition];
    }
  } else if (recognizer.state == UIGestureRecognizerStateEnded || recognizer.state == UIGestureRecognizerStateCancelled) {
    CGPoint currentVelocityPoint = [recognizer velocityInView:self.view];
    CGFloat currentVelocityX     = currentVelocityPoint.x;
    
    if ([self underLeftShowing] && currentVelocityX > 100) {
      [self anchorTopViewTo:ECRight];
    } else if ([self underRightShowing] && currentVelocityX < 100) {
      [self anchorTopViewTo:ECLeft];
    } else {
      [self resetTopView];
    }
  }
}

- (void)updateTopViewVerticalCenterWithRecognizer:(UIPanGestureRecognizer *)recognizer
{
    CGPoint currentTouchPoint     = [recognizer locationInView:self.view];
    CGFloat currentTouchPositionY = currentTouchPoint.y;
    
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        self.initialTouchPositionY = currentTouchPositionY;
        self.initialVerticalCenter = self.topView.center.y;
    } else if (recognizer.state == UIGestureRecognizerStateChanged) {
        
        CGPoint translation = [recognizer translationInView:self.view];
        
        if(fabs(translation.y) > fabs(translation.x))
        {
            CGFloat panAmount = self.initialTouchPositionY - currentTouchPositionY;
            CGFloat newCenterPosition = self.initialVerticalCenter - panAmount;
            
                    NSLog(@"newCenterPosition : %f, self.resettedCenterVertical: %f, ",newCenterPosition,self.resettedCenterVertical);
            
            if ((newCenterPosition < self.resettedCenterVertical && self.anchorTopTopViewCenter == NSNotFound) || (newCenterPosition > self.resettedCenterVertical && self.anchorBottomTopViewCenter == NSNotFound)) {
                newCenterPosition = self.resettedCenterVertical;
            }
              NSLog(@"\n\nupdateTopViewVerticalCenterWithRecognizer calling topViewVerticalCenterWillChange with %f",newCenterPosition);
            [self topViewVerticalCenterWillChange:newCenterPosition];
            [self updateTopViewVerticalCenter:newCenterPosition];
            [self topViewVerticalCenterDidChange:newCenterPosition];
        }
    } else if (recognizer.state == UIGestureRecognizerStateEnded || recognizer.state == UIGestureRecognizerStateCancelled) {
        CGPoint currentVelocityPoint = [recognizer velocityInView:self.view];
        CGFloat currentVelocityY    = currentVelocityPoint.y;
        
              NSLog(@"underTopShowing %d,underBottomShowing %d  currentVelocityY %f",[self underTopShowing], [self underBottomShowing], currentVelocityY);
        
        if ([self underTopShowing] && currentVelocityY > 100) {
            [self anchorTopViewTo:ECBottom];
        } else if ([self underBottomShowing] && currentVelocityY < 100) {
            [self anchorTopViewTo:ECTop];
        } else {
            [self resetTopViewVertical];
        }
    }
}

- (UIPanGestureRecognizer *)panGesture
{
  return _panGesture;
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark
#pragma mark Anchor Methods

- (void)anchorTopViewTo:(ECSide)side
{
  [self anchorTopViewTo:side animations:nil onComplete:nil];
}

- (void)anchorTopViewTo:(ECSide)side animations:(void (^)())animations onComplete:(void (^)())complete
{
  CGFloat newCenter = self.topView.center.y;
  
  if (side == ECLeft) {
    newCenter = self.anchorLeftTopViewCenter;
  } else if (side == ECRight) {
    newCenter = self.anchorRightTopViewCenter;
  } else if (side == ECTop) {
    newCenter = self.anchorTopTopViewCenter;
  } else if (side == ECBottom) {
    newCenter = self.anchorBottomTopViewCenter;
  }
  
  if (side == ECLeft || side == ECRight)    //todo: abstract this part
      [self topViewHorizontalCenterWillChange:newCenter];
  else if (side == ECTop || side == ECBottom) {
    NSLog(@"\n\nanchorTopViewTo calling topViewVerticalCenterWillChange with %f",newCenter);   
      [self topViewVerticalCenterWillChange:newCenter];
  }
  
  [UIView animateWithDuration:0.25f animations:^{
    if (animations) {
      animations();
    }
  if (side == ECLeft || side == ECRight)
    [self updateTopViewHorizontalCenter:newCenter];
  else if (side == ECTop || side == ECBottom)
    [self updateTopViewVerticalCenter:newCenter];
  
  } completion:^(BOOL finished){
    if (_resetStrategy & ECPanning) {
      self.panGesture.enabled = YES;
    } else {
      self.panGesture.enabled = NO;
    }
    if (complete) {
      complete();
    }
    _topViewIsOffScreen = NO;
      
  if (side == ECLeft || side == ECRight)      
    [self addTopViewSnapshot];
  else if (side == ECTop || side == ECBottom)
    [self addTopViewVerticalSnapshot];
      
    dispatch_async(dispatch_get_main_queue(), ^{
      NSString *key = (side == ECTop) ? ECSlidingViewTopDidAnchorTop : ECSlidingViewTopDidAnchorBottom;
      [[NSNotificationCenter defaultCenter] postNotificationName:key object:self userInfo:nil];
    });
  }];
}

- (void)anchorTopViewOffScreenTo:(ECSide)side
{
  [self anchorTopViewOffScreenTo:side animations:nil onComplete:nil];
}

- (void)anchorTopViewOffScreenTo:(ECSide)side animations:(void(^)())animations onComplete:(void(^)())complete
{
  CGFloat newCenter = self.topView.center.x;
  
  if (side == ECLeft) {
    newCenter = -self.resettedCenter;
  } else if (side == ECRight) {
    newCenter = self.screenWidth + self.resettedCenter;
  } else if (side == ECBottom) {
    newCenter = -self.resettedCenter;
  } else if (side == ECTop) {
    newCenter = self.screenHeight + self.resettedCenter;
  }
  
  if (side == ECLeft || side == ECRight)   
      [self topViewHorizontalCenterWillChange:newCenter];
  else if (side == ECTop || side == ECBottom) {
        NSLog(@"\n\anchorTopViewOffScreenTo calling topViewVerticalCenterWillChange with %f",newCenter);
       [self topViewVerticalCenterWillChange:newCenter];
  }
      
  
  [UIView animateWithDuration:0.25f animations:^{
    if (animations) {
      animations();
    }
    [self updateTopViewHorizontalCenter:newCenter];
  } completion:^(BOOL finished){
    if (complete) {
      complete();
    }
    _topViewIsOffScreen = YES;
    [self addTopViewSnapshot];
    dispatch_async(dispatch_get_main_queue(), ^{
      NSString *key = (side == ECLeft) ? ECSlidingViewTopDidAnchorLeft : ECSlidingViewTopDidAnchorRight;
      [[NSNotificationCenter defaultCenter] postNotificationName:key object:self userInfo:nil];
    });
  }];
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark
#pragma mark Reset Methods

- (void)resetTopView
{
  dispatch_async(dispatch_get_main_queue(), ^{
    [[NSNotificationCenter defaultCenter] postNotificationName:ECSlidingViewTopWillReset object:self userInfo:nil];
  });
  [self resetTopViewWithAnimations:nil onComplete:nil];
}

- (void)resetTopViewVertical
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:ECSlidingViewTopWillReset object:self userInfo:nil];
    });
    [self resetTopViewWithAnimationsVertical:nil onComplete:nil];
}

- (void)resetTopViewWithAnimations:(void(^)())animations onComplete:(void(^)())complete
{
  [self topViewHorizontalCenterWillChange:self.resettedCenter];
  
  [UIView animateWithDuration:0.25f animations:^{
    if (animations) {
      animations();
    }
    [self updateTopViewHorizontalCenter:self.resettedCenter];
  } completion:^(BOOL finished) {
    if (complete) {
      complete();
    }
    [self topViewHorizontalCenterDidChange:self.resettedCenter];
  }];
}

- (void)resetTopViewWithAnimationsVertical:(void(^)())animations onComplete:(void(^)())complete
{
        NSLog(@"\n\nresetTopViewWithAnimationsVertical calling topViewVerticalCenterWillChange with %f",self.resettedCenterVertical);   
    [self topViewVerticalCenterWillChange:self.resettedCenterVertical];
    
    [UIView animateWithDuration:0.25f animations:^{
        if (animations) {
            animations();
        }
        [self updateTopViewVerticalCenter:self.resettedCenterVertical];
    } completion:^(BOOL finished) {
        if (complete) {
            complete();
        }
        [self topViewVerticalCenterDidChange:self.resettedCenterVertical];
    }];
}

- (NSUInteger)autoResizeToFillScreen
{
  return (UIViewAutoresizingFlexibleWidth |
          UIViewAutoresizingFlexibleHeight |
          UIViewAutoresizingFlexibleTopMargin |
          UIViewAutoresizingFlexibleBottomMargin |
          UIViewAutoresizingFlexibleLeftMargin |
          UIViewAutoresizingFlexibleRightMargin);
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark
#pragma mark View Accessors

- (UIView *)topView
{
  return self.topViewController.view;
}

- (UIView *)underLeftView
{
  return self.underLeftViewController.view;
}

- (UIView *)underRightView
{
  return self.underRightViewController.view;
}

- (UIView *)underTopView
{
    return self.underTopViewController.view;
}

- (UIView *)underBottomView
{
    return self.underBottomViewController.view;
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark
#pragma mark View Controller Methods

- (void)updateTopViewHorizontalCenter:(CGFloat)newHorizontalCenter
{
  CGPoint center = self.topView.center;
  center.x = newHorizontalCenter;
  self.topView.layer.position = center;
}

- (void)updateTopViewVerticalCenter:(CGFloat)newVerticalCenter
{
    CGPoint center = self.topView.center;
    center.y = newVerticalCenter;
    self.topView.layer.position = center;
}

- (void)topViewHorizontalCenterWillChange:(CGFloat)newHorizontalCenter
{
	

  CGPoint center = self.topView.center;
  
	if (center.x >= self.resettedCenter && newHorizontalCenter == self.resettedCenter) {
		dispatch_async(dispatch_get_main_queue(), ^{
			[[NSNotificationCenter defaultCenter] postNotificationName:ECSlidingViewUnderLeftWillDisappear object:self userInfo:nil];
		});
	}
	
	if (center.x <= self.resettedCenter && newHorizontalCenter == self.resettedCenter) {
		dispatch_async(dispatch_get_main_queue(), ^{
			[[NSNotificationCenter defaultCenter] postNotificationName:ECSlidingViewUnderRightWillDisappear object:self userInfo:nil];
		});
	}
	
  if (center.x <= self.resettedCenter && newHorizontalCenter > self.resettedCenter) {
      NSLog(@"center.x %f self.resettedcenter %f newHorizontalcenter %f",center.x,self.resettedCenter, newHorizontalCenter);
    [self underLeftWillAppear];
  } else if (center.x >= self.resettedCenter && newHorizontalCenter < self.resettedCenter) {
    [self underRightWillAppear];
  }  
}

- (void)topViewVerticalCenterWillChange:(CGFloat)newVerticalCenter
{	    
    CGPoint center = self.topView.center;
    
	if (center.y >= self.resettedCenter && newVerticalCenter == self.resettedCenter) {
		dispatch_async(dispatch_get_main_queue(), ^{
			[[NSNotificationCenter defaultCenter] postNotificationName:ECSlidingViewUnderTopWillDisappear object:self userInfo:nil];
		});
	}
	
	if (center.y <= self.resettedCenter && newVerticalCenter == self.resettedCenter) {
		dispatch_async(dispatch_get_main_queue(), ^{
			[[NSNotificationCenter defaultCenter] postNotificationName:ECSlidingViewUnderBottomWillDisappear object:self userInfo:nil];
		});
	}
	NSLog(@"\n\n\n\n====topViewVerticalCenterWillChange:: center.y %f, self.resettedCenterVertical %f, newVerticalCenter %f",center.y,  self.resettedCenterVertical, newVerticalCenter);
    if (center.y <= self.resettedCenterVertical && newVerticalCenter > self.resettedCenterVertical) {    // moving in bottom direction   
        NSLog(@"---------->underTopWillAppear");
        [self underTopWillAppear];
    } else if (center.y >= self.resettedCenterVertical && newVerticalCenter < self.resettedCenterVertical) {    // moving in upper direction
        [self underBottomWillAppear];
                NSLog(@"---------->underBottomWillAppear");
    }  else {
                NSLog(@"---------->NONE WILL APPEAR");
    }
}

- (void)topViewHorizontalCenterDidChange:(CGFloat)newHorizontalCenter
{
  if (newHorizontalCenter == self.resettedCenter) {
    [self topDidReset]; //todo: change this to call topDidResetHorizontal
  }
}

- (void)topViewVerticalCenterDidChange:(CGFloat)newVerticalCenter
{
    if (newVerticalCenter == self.resettedCenter) {
        [self topDidResetVertical];
    }
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark
#pragma mark Snapshot Methods

- (void)addTopViewSnapshot
{
    if (!self.topViewSnapshot.superview && !self.shouldAllowUserInteractionsWhenAnchored) {
        topViewSnapshot.layer.contents = (id)[UIImage imageWithUIView:self.topView].CGImage;
        
        if (self.shouldAddPanGestureRecognizerToTopViewSnapshot && (_resetStrategy & ECPanning)) {
            if (!_topViewSnapshotPanGesture) {
                _topViewSnapshotPanGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(updateTopViewHorizontalCenterWithRecognizer:)];
            }
            [topViewSnapshot addGestureRecognizer:_topViewSnapshotPanGesture];
        }
        [self.topView addSubview:self.topViewSnapshot];
    }
}

- (void)addTopViewVerticalSnapshot
{
    if (!self.topViewSnapshot.superview && !self.shouldAllowUserInteractionsWhenAnchored) {
        topViewSnapshot.layer.contents = (id)[UIImage imageWithUIView:self.topView].CGImage;
        
        if (self.shouldAddPanGestureRecognizerToTopViewSnapshot && (_resetStrategy & ECPanning)) {
            if (!_topViewSnapshotPanGesture) {
                _topViewSnapshotPanGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(updateTopViewVerticalCenterWithRecognizer:)];
            }
            [topViewSnapshot addGestureRecognizer:_topViewSnapshotPanGesture];
        }
        [self.topView addSubview:self.topViewSnapshot];
    }
}
- (void)removeTopViewSnapshot
{
  if (self.topViewSnapshot.superview) {
    [self.topViewSnapshot removeFromSuperview];
  }
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark
#pragma mark Geometry Methods

- (CGFloat)anchorRightTopViewCenter
{
  if (self.anchorRightPeekAmount) {
    return self.screenWidth + self.resettedCenter - self.anchorRightPeekAmount;
  } else if (self.anchorRightRevealAmount) {
    return self.resettedCenter + self.anchorRightRevealAmount;
  } else {
    return NSNotFound;
  }
}

- (CGFloat)anchorLeftTopViewCenter
{
  if (self.anchorLeftPeekAmount) {
    return -self.resettedCenter + self.anchorLeftPeekAmount;
  } else if (self.anchorLeftRevealAmount) {
    return -self.resettedCenter + (self.screenWidth - self.anchorLeftRevealAmount);
  } else {
    return NSNotFound;
  }
}

- (CGFloat)anchorTopTopViewCenter
{
    if (self.anchorTopPeekAmount) {
        return -self.resettedCenter + self.anchorTopPeekAmount;
    } else if (self.anchorTopRevealAmount) {
        return -self.resettedCenter + (self.screenWidth - self.anchorTopRevealAmount);
    } else {
        return NSNotFound;
    }
}

- (CGFloat)anchorBottomTopViewCenter
{
    if (self.anchorBottomPeekAmount) {
        return self.screenWidth + self.resettedCenter - self.anchorBottomPeekAmount;
    } else if (self.anchorBottomRevealAmount) {
        return self.resettedCenter + self.anchorBottomRevealAmount;
    } else {
        return NSNotFound;
    }
}

- (CGFloat)resettedCenter
{
  return ceil(self.screenWidth / 2);
}

- (CGFloat)resettedCenterVertical
{
    return ceil(self.screenHeight / 2);
}

- (CGFloat)screenWidth
{
  return [self screenWidthForOrientation:[UIApplication sharedApplication].statusBarOrientation];
}

- (CGFloat)screenHeight
{
    return [self screenHeightForOrientation:[UIApplication sharedApplication].statusBarOrientation];
}

- (CGFloat)screenWidthForOrientation:(UIInterfaceOrientation)orientation
{
  CGSize size = [UIScreen mainScreen].bounds.size;
  UIApplication *application = [UIApplication sharedApplication];
  if (UIInterfaceOrientationIsLandscape(orientation))
  {
    size = CGSizeMake(size.height, size.width);
  }
  if (application.statusBarHidden == NO)
  {
    size.height -= MIN(application.statusBarFrame.size.width, application.statusBarFrame.size.height);
  }
  return size.width;
}

- (CGFloat)screenHeightForOrientation:(UIInterfaceOrientation)orientation
{
    CGSize size = [UIScreen mainScreen].bounds.size;
    UIApplication *application = [UIApplication sharedApplication];
    if (UIInterfaceOrientationIsLandscape(orientation))
    {
        size = CGSizeMake(size.height, size.width);
    }
    if (application.statusBarHidden == NO)
    {
        size.height -= MIN(application.statusBarFrame.size.width, application.statusBarFrame.size.height);
    }
    return size.height;
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark
#pragma mark Appear Methods

- (void)underLeftWillAppear
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:ECSlidingViewUnderLeftWillAppear object:self userInfo:nil];
    });
    self.underRightView.hidden = YES;
    [self.underLeftViewController viewWillAppear:NO];
    self.underLeftView.hidden = NO;
    [self updateUnderLeftLayout];
    _underLeftShowing  = YES;
    _underRightShowing = NO;
}

- (void)underRightWillAppear
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:ECSlidingViewUnderRightWillAppear object:self userInfo:nil];
    });
    self.underLeftView.hidden = YES;
    [self.underRightViewController viewWillAppear:NO];
    self.underRightView.hidden = NO;
    [self updateUnderRightLayout];
    _underLeftShowing  = NO;
    _underRightShowing = YES;
}

- (void)underTopWillAppear
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:ECSlidingViewUnderTopWillAppear object:self userInfo:nil];
    });
    self.underBottomView.hidden = YES;
    [self.underTopViewController viewWillAppear:NO];
    self.underTopView.hidden = NO;
    [self updateUnderTopLayout];
    _underTopShowing  = YES;
    _underBottomShowing = NO;
}

- (void)underBottomWillAppear
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:ECSlidingViewUnderBottomWillAppear object:self userInfo:nil];
    });
    self.underTopView.hidden = YES;
    [self.underBottomViewController viewWillAppear:NO];
    self.underBottomView.hidden = NO;
    [self updateUnderBottomLayout];
    _underBottomShowing  = YES;
    _underTopShowing = NO;
}


- (void)topDidReset
{
  dispatch_async(dispatch_get_main_queue(), ^{
    [[NSNotificationCenter defaultCenter] postNotificationName:ECSlidingViewTopDidReset object:self userInfo:nil];
  });
  [self.topView removeGestureRecognizer:self.resetTapGesture];
  [self removeTopViewSnapshot];
  self.panGesture.enabled = YES;
  _underLeftShowing   = NO;
  _underRightShowing  = NO;
  _topViewIsOffScreen = NO;
}

- (void)topDidResetVertical
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:ECSlidingViewTopDidReset object:self userInfo:nil];
    });
    [self.topView removeGestureRecognizer:self.resetTapGesture];
    [self removeTopViewSnapshot];
    self.panGesture.enabled = YES;
    _underTopShowing   = NO;
    _underBottomShowing  = NO;
    _topViewIsOffScreen = NO;
}

- (BOOL)topViewHasFocus
{
  return !_underLeftShowing && !_underRightShowing && !_topViewIsOffScreen;
}


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark
#pragma mark Layout Updates
- (void)updateUnderLeftLayout
{
  if (self.underLeftWidthLayout == ECFullWidth) {
    [self.underLeftView setAutoresizingMask:self.autoResizeToFillScreen];
    [self.underLeftView setFrame:self.view.bounds];
  } else if (self.underLeftWidthLayout == ECVariableRevealWidth && !self.topViewIsOffScreen) {
    CGRect frame = self.view.bounds;
    CGFloat newWidth;
    
    if (UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
      newWidth = [UIScreen mainScreen].bounds.size.height - self.anchorRightPeekAmount;
    } else {
      newWidth = [UIScreen mainScreen].bounds.size.width - self.anchorRightPeekAmount;
    }
    
    frame.size.width = newWidth;
    
    self.underLeftView.frame = frame;
  } else if (self.underLeftWidthLayout == ECFixedRevealWidth) {
    CGRect frame = self.view.bounds;
    
    frame.size.width = self.anchorRightRevealAmount;
    self.underLeftView.frame = frame;
  } else {
    [NSException raise:@"Invalid Width Layout" format:@"underLeftWidthLayout must be a valid ECViewWidthLayout"];
  }
}

- (void)updateUnderRightLayout
{
  if (self.underRightWidthLayout == ECFullWidth) {
    [self.underRightViewController.view setAutoresizingMask:self.autoResizeToFillScreen];
    self.underRightView.frame = self.view.bounds;
  } else if (self.underRightWidthLayout == ECVariableRevealWidth) {
    CGRect frame = self.view.bounds;
    
    CGFloat newLeftEdge;
    CGFloat newWidth;
    
    if (UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
      newWidth = [UIScreen mainScreen].bounds.size.height;
    } else {
      newWidth = [UIScreen mainScreen].bounds.size.width;
    }
    
    if (self.topViewIsOffScreen) {
      newLeftEdge = 0;
    } else {
      newLeftEdge = self.anchorLeftPeekAmount;
      newWidth   -= self.anchorLeftPeekAmount;
    }
    
    frame.origin.x   = newLeftEdge;
    frame.size.width = newWidth;
    
    self.underRightView.frame = frame;
  } else if (self.underRightWidthLayout == ECFixedRevealWidth) {
    CGRect frame = self.view.bounds;
    
    CGFloat newLeftEdge = self.screenWidth - self.anchorLeftRevealAmount;
    CGFloat newWidth = self.anchorLeftRevealAmount;
    
    frame.origin.x   = newLeftEdge;
    frame.size.width = newWidth;
    
    self.underRightView.frame = frame;
  } else {
    [NSException raise:@"Invalid Width Layout" format:@"underRightWidthLayout must be a valid ECViewWidthLayout"];
  }
}

- (void)updateUnderTopLayout
{
    if (self.underTopHeightLayout == ECFullHeight) {
        [self.underTopView setAutoresizingMask:self.autoResizeToFillScreen];
        [self.underTopView setFrame:self.view.bounds];
    } else if (self.underLeftWidthLayout == ECVariableRevealHeight && !self.topViewIsOffScreen) {
        CGRect frame = self.view.bounds;
        CGFloat newHeight;
        
        //TODO: fix this
        if (UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
            newHeight = [UIScreen mainScreen].bounds.size.height - self.anchorRightPeekAmount;
        } else {
            newHeight = [UIScreen mainScreen].bounds.size.width - self.anchorRightPeekAmount;
        }
        
        frame.size.height = newHeight;
        
        self.underTopView.frame = frame;
    } else if (self.underTopHeightLayout == ECFixedRevealHeight) {
        CGRect frame = self.view.bounds;
        
        frame.size.width = self.anchorBottomRevealAmount;
        self.underTopView.frame = frame;
    } else {
        [NSException raise:@"Invalid Height Layout" format:@"underTopHeightLayout must be a valid ECViewHeightLayout"];
    }
}

- (void)updateUnderBottomLayout
{
    if (self.underBottomHeightLayout == ECFullHeight) {
        [self.underLeftView setAutoresizingMask:self.autoResizeToFillScreen];
        [self.underLeftView setFrame:self.view.bounds];
    } else if (self.underLeftWidthLayout == ECVariableRevealWidth && !self.topViewIsOffScreen) {
        CGRect frame = self.view.bounds;
        CGFloat newWidth;
        
        if (UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
            newWidth = [UIScreen mainScreen].bounds.size.height - self.anchorRightPeekAmount;
        } else {
            newWidth = [UIScreen mainScreen].bounds.size.width - self.anchorRightPeekAmount;
        }
        
        frame.size.width = newWidth;
        
        self.underLeftView.frame = frame;
    } else if (self.underLeftWidthLayout == ECFixedRevealWidth) {
        CGRect frame = self.view.bounds;
        
        frame.size.width = self.anchorRightRevealAmount;
        self.underLeftView.frame = frame;
    } else {
        [NSException raise:@"Invalid Width Layout" format:@"underLeftWidthLayout must be a valid ECViewWidthLayout"];
    }
}
@end
