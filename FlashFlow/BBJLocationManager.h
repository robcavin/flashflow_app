//
//  BBJLocationManager.h
//  FlashFlow
//
//  Created by Rob on 5/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface BBJLocationManager : CLLocationManager <CLLocationManagerDelegate>

+ (BBJLocationManager*) sharedManager;

@end
