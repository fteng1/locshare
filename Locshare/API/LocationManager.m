//
//  LocationManager.m
//  Locshare
//
//  Created by Felianne Teng on 7/16/21.
//

#import "LocationManager.h"

@implementation LocationManager

// create a shared instance of the LocationManager to use in the app
+ (instancetype)shared {
    static LocationManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}

- (instancetype)init {
    // Initialize location manager
    self = [super init];
    self.desiredAccuracy = kCLLocationAccuracyBest;
    
    // Ask user for permission to use location
    [self requestWhenInUseAuthorization];
    self.distanceFilter = 50;
    [self startUpdatingLocation];
    
    return self;
}


@end
