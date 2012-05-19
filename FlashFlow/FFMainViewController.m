//
//  FFMainViewController.m
//  FlashFlow
//
//  Created by Rob on 5/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FFMainViewController.h"
#define API_URL @"ec2-184-169-224-115.us-west-1.compute.amazonaws.com"

@interface FFMainViewController ()

@end


@implementation FFMainViewController
@synthesize left,right,center;
@synthesize scrollView;
@synthesize contentView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.scrollView.pagingEnabled = TRUE;
    CGSize scrollSize = self.view.frame.size;
    CGPoint scrollOrigin = self.view.frame.origin;
    scrollSize.width *= 3;
    scrollOrigin.x += self.view.frame.size.width;
    self.scrollView.contentSize = self.contentView.frame.size;
    self.scrollView.contentOffset = self.contentView.frame.origin;
    [[BBJLocationManager sharedManager] startUpdatingLocation];
    
    // XXX
    [BBJLocationManager sharedManager].delegate = self;
     
	// Do any additional setup after loading the view.
    center = [[UIImageView alloc] initWithFrame:self.view.frame];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {

    // Only update location once here... 
    [[BBJLocationManager sharedManager] stopUpdatingLocation];
    
    NSURL* apiUrl = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/photos/stream?ll=%f,%f",
                                          API_URL,
                                          newLocation.coordinate.latitude,
                                          newLocation.coordinate.longitude]];    
    
    NSDictionary* response = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfURL:apiUrl] 
                                                             options:0 
                                                               error:nil];
    NSLog(@"Respose: %@",response);
    
    NSArray* imageStreamUrlStrings = [[response objectForKey:@"photos"] valueForKey:@"url"];
    NSURL* imageURL = [NSURL URLWithString:[imageStreamUrlStrings objectAtIndex:0]];
    UIImage* center_image = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:imageURL]];
    center = [[UIImageView alloc] initWithFrame:self.view.frame];
    center.image = center_image;
    [self.contentView addSubview:center];

    imageURL = [NSURL URLWithString:[imageStreamUrlStrings objectAtIndex:1]];
    UIImage* right_image = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:imageURL]];
    CGRect rightFrame = self.view.frame;
    rightFrame.origin.x += self.view.frame.size.width;
    right = [[UIImageView alloc] initWithFrame:rightFrame];
    right.image = right_image;
    [self.contentView addSubview:right];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSLog(@"Stopped acceleratiing");
    
}
                                                                                 
- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
