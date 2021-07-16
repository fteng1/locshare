//
//  LocationManager.m
//  Locshare
//
//  Created by Felianne Teng on 7/16/21.
//

#import "LocationManager.h"

@implementation LocationManager
NSString *gMapsAPIKey;

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
    
    // Get API key from Keys.plist
    NSString *path = [[NSBundle mainBundle] pathForResource: @"Keys" ofType: @"plist"];
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile: path];
    gMapsAPIKey = [dict objectForKey: @"google_api_key"];
    
    return self;
}

// Get suggested autocomplete locations from Places API
- (void)getSuggestedLocations:(NSString *)searchQuery completion:(void (^)(NSArray *, NSError *))completion{
    // Format searchQuery by replacing spaces with '+'
    searchQuery = [searchQuery stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    
    // Construct URL and make request
    NSURL *url = [NSURL URLWithString: [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/autocomplete/json?input=%@&key=%@", searchQuery, gMapsAPIKey]];
    [self makeURLRequest:url completion:^(NSDictionary * dataDictionary, NSError * error) {
        if (error == nil) {
            completion(dataDictionary[@"predictions"], nil);
        }
        else {
            completion(nil, error);
        }
    }];
}

// Get recommended locations from Places API based on current location
- (void)getNearbyLocations:(void (^)(NSArray *, NSError *))completion{
    // Construct URL
    NSString *locationString = [NSString stringWithFormat:@"%f,%f", self.location.coordinate.latitude, self.location.coordinate.longitude];
    NSString *radiusString = @"1000";
    NSURL *url = [NSURL URLWithString: [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/nearbysearch/json?key=%@&location=%@&radius=%@", gMapsAPIKey, locationString, radiusString]];
    
    // Make API request using URL
    [self makeURLRequest:url completion:^(NSDictionary * dataDictionary, NSError * error) {
        if (error == nil) {
            completion(dataDictionary[@"results"], nil);
        }
        else {
            completion(nil, error);
        }
    }];
}

// Handles the url request given a url parameter
- (void)makeURLRequest:(NSURL *)url completion:(void (^)(NSDictionary *, NSError *))completion {
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10.0];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error != nil) {
           NSLog(@"%@", [error localizedDescription]);
            completion(nil, error);
        }
        else {
            NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            completion(dataDictionary, nil);
        }
    }];
    [task resume];
}

@end