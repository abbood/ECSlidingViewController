//
//  NorthernViewController.m
//  ECSlidingViewController
//
//  Created by Abdullah Bakhach on 1/2/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "NorthernViewController.h"

@interface NorthernViewController()
@property (nonatomic, strong) NSArray *menuItems;
@end

@implementation NorthernViewController


@synthesize menuItems;

- (void)awakeFromNib
{
    self.menuItems = [NSArray arrayWithObjects:@"First", @"Second", @"Third", @"Navigation", nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.slidingViewController setAnchorBottomRevealAmount:420.0f];
    self.slidingViewController.underTopHeightLayout = ECFullHeight;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    return self.menuItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = @"MenuItemCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    
    cell.textLabel.text = [self.menuItems objectAtIndex:indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = [NSString stringWithFormat:@"%@Top", [self.menuItems objectAtIndex:indexPath.row]];
    
    UIViewController *newTopViewController = [self.storyboard instantiateViewControllerWithIdentifier:identifier];
    
    [self.slidingViewController anchorTopViewOffScreenTo:ECRight animations:nil onComplete:^{
        CGRect frame = self.slidingViewController.topViewController.view.frame;
        self.slidingViewController.topViewController = newTopViewController;
        self.slidingViewController.topViewController.view.frame = frame;
        [self.slidingViewController resetTopView];
    }];
}
@end
