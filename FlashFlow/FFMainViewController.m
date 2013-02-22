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
    
    [self uploadImage];
    
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

- (void) uploadImage {
    
    NSHTTPURLResponse* response2 = nil;
    NSData *returnData2 = [NSURLConnection sendSynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://192.168.1.104:8080/"]] returningResponse:&response2 error:nil];
    NSString* returnString2 = [[NSString alloc] initWithData:returnData2 encoding:NSUTF8StringEncoding];
    //NSLog(@"%@", returnString2);
    NSLog(@"%@",[response2 allHeaderFields]);
    
    NSMutableURLRequest* request1= [[NSMutableURLRequest alloc] init];
    [request1 setURL:[NSURL URLWithString:@"http://192.168.1.104:8080/login/"]];
    [request1 setHTTPMethod:@"POST"];

    NSArray* all = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
    NSString* csrfValue = nil;
    for (NSHTTPCookie* cookie in all) {
        if ([cookie.name isEqualToString:@"csrftoken"]) {
            csrfValue = cookie.value;
        }
    }
    NSLog(@"%@", all);

    NSString* postString = [NSString stringWithFormat:@"username=robcavin&password=franz51Rein&csrfmiddlewaretoken=%@",csrfValue];
    [request1 setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSHTTPURLResponse* response = nil;
    NSData *returnData1 = [NSURLConnection sendSynchronousRequest:request1 returningResponse:&response error:nil];
    NSString* returnString1 = [[NSString alloc] initWithData:returnData1 encoding:NSUTF8StringEncoding];
    NSLog(@"%@", returnString1);
    NSLog(@"%@",[response allHeaderFields]);
    
    
    NSString *urlString = @"http://192.168.1.104:8080/image/upload/";
    NSString *filename = @"foo.jpg";
    NSMutableURLRequest* request= [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"POST"];
    
    NSString *boundary = @"abcboundary123";
    
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [request addValue:csrfValue forHTTPHeaderField:@"X-CSRFToken"];
    [request addValue:contentType forHTTPHeaderField: @"Content-Type"];
    NSMutableData *postbody = [NSMutableData data];

    /*[postbody appendData:[[NSString stringWithFormat:@"Content-Type: multipart/form-data; boundary=%@\r\n\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
*/
    [postbody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [postbody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"csrfmiddlewaretoken\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [postbody appendData:[csrfValue dataUsingEncoding:NSUTF8StringEncoding]];
    
    [postbody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [postbody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"image\"; filename=\"%@\"\r\n", filename] dataUsingEncoding:NSUTF8StringEncoding]];
    [postbody appendData:[@"Content-Type: image/jpeg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSLog(@"%@",[[NSString alloc] initWithData:postbody encoding:NSUTF8StringEncoding]);
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"foo" ofType:@"jpg"];
    NSData *imageData = [NSData dataWithContentsOfFile:filePath];
    [postbody appendData:imageData];
    [postbody appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request setHTTPBody:postbody];
    
    NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    NSString* returnString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
    NSLog(@"%@", returnString);
}

- (IBAction)pickImage:(id)sender {
    UIImagePickerController* imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.delegate = self;
    imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self.view addSubview:imagePickerController.view];
}


- (void)imagePickerController:(UIImagePickerController *)picker 
        didFinishPickingImage:(UIImage *)image
                  editingInfo:(NSDictionary *)editingInfo
{
    [picker dismissModalViewControllerAnimated:YES];
    picker.view.hidden = YES;
    picker = nil;
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissModalViewControllerAnimated:YES];
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
