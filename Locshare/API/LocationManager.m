//
//  LocationManager.m
//  Locshare
//
//  Created by Felianne Teng on 7/16/21.
//

#import "LocationManager.h"
#import "LocationMarker.h"
#import "AlertManager.h"
#import "Constants.h"

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
    NSString *path = [[NSBundle mainBundle] pathForResource: KEYS_FILE_NAME ofType: KEYS_FILE_EXTENSION];
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile: path];
    gMapsAPIKey = [dict objectForKey: GOOGLE_API_KEY_NAME];
    
    return self;
}

// Get suggested autocomplete locations from Places API
- (void)getSuggestedLocations:(NSString *)searchQuery completion:(void (^)(NSArray *, NSError *))completion{
    // Format searchQuery by replacing spaces with '+'
    searchQuery = [searchQuery stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    
    // Construct URL and make request
    NSURL *url = [NSURL URLWithString: [NSString stringWithFormat: PLACES_AUTOCOMPLETE_URL, searchQuery, gMapsAPIKey]];
    [self makeURLRequest:url completion:^(NSDictionary * dataDictionary, NSError * error) {
        if (error == nil) {
            completion(dataDictionary[PLACES_AUTOCOMPLETE_RETURNED_DATA_KEY], nil);
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
    NSURL *url = [NSURL URLWithString: [NSString stringWithFormat: PLACES_NEARBY_URL, gMapsAPIKey, locationString, PLACES_NEARBY_RADIUS]];
    
    // Make API request using URL
    [self makeURLRequest:url completion:^(NSDictionary * dataDictionary, NSError * error) {
        if (error == nil) {
            completion(dataDictionary[PLACES_NEARBY_RETURNED_DATA_KEY], nil);
        }
        else {
            completion(nil, error);
        }
    }];
}

// Get details of a specified place given the place id
- (void)getPlaceDetails:(NSString *)placeId completion:(void (^)(NSDictionary *, NSError *))completion{
    // Construct URL
    NSURL *url = [NSURL URLWithString: [NSString stringWithFormat:PLACES_DETAILS_URL, placeId, gMapsAPIKey]];
    
    // Make API request using URL
    [self makeURLRequest:url completion:^(NSDictionary *dataDictionary, NSError * error) {
        if (error == nil) {
            completion(dataDictionary[PLACES_DETAILS_RETURNED_DATA_KEY], nil);
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
            [AlertManager displayAlertWithTitle:URL_REQUEST_ERROR_TITLE text:URL_REQUEST_ERROR_MESSAGE presenter:self.delegate];
            completion(nil, error);
        }
        else {
            NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            completion(dataDictionary, nil);
        }
    }];
    [task resume];
}

// Display a given array of posts on a map as markers
- (void)displayLocationsOnMap:(GMSMapView *)mapView locations:(NSArray *)locations userFiltering:(BOOL)filter {
    [mapView clear];
    for (Location *loc in locations) {
        CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(loc.coordinate.latitude, loc.coordinate.longitude);
        LocationMarker *marker = [[LocationMarker alloc] initMarkerWithPosition:coord withLocation:loc];
        marker.userFiltered = filter;
        marker.map = mapView;
    }
}

@end
