//
//  FFMainViewController.h
//  FlashFlow
//
//  Created by Rob on 5/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BBJLocationManager.h"

@interface FFMainViewController : UIViewController <CLLocationManagerDelegate,UIScrollViewDelegate> {
}

@property (strong,nonatomic) UIImageView* left;
@property (strong,nonatomic) UIImageView* center;
@property (strong,nonatomic) UIImageView* right;
@property (strong,nonatomic) IBOutlet UIScrollView* scrollView;
@property (strong,nonatomic) IBOutlet UIView* contentView;

@end
