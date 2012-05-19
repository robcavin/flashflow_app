//
//  BBJLocationManager.m
//  FlashFlow
//
//  Created by Rob on 5/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BBJLocationManager.h"

@implementation BBJLocationManager

BBJLocationManager* _sharedManager;

+ (BBJLocationManager*) sharedManager {
    if (!_sharedManager) {
        _sharedManager = [[BBJLocationManager alloc] init];
        _sharedManager.delegate = _sharedManager;
        _sharedManager.distanceFilter = kCLDistanceFilterNone;
        _sharedManager.desiredAccuracy = kCLLocationAccuracyBest;
    }        
    return _sharedManager;
}

@end
