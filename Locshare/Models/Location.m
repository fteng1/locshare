//
//  Location.m
//  Locshare
//
//  Created by Felianne Teng on 7/12/21.
//

#import "Location.h"
#import <Parse/Parse.h>

@implementation Location

@dynamic name;
@dynamic latitude;
@dynamic longitude;
@dynamic numPosts;
@dynamic placeID;

+ (nonnull NSString *)parseClassName {
    return @"Location";
}

// Function to update Location object in Parse to reflect new post
+ (void)tagLocation:(NSString *)placeId completion:(void (^)(NSString *, NSError *))completion{
    PFQuery *query = [PFQuery queryWithClassName:@"Location"];
    [query whereKey:@"placeID" equalTo:placeId];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *place, NSError *error) {
        if (place != nil) {
            // Check if Location with given placeID already exists in Parse
            if ([place count] != 0) {
                // If already exists, increase number of posts by 1
                Location *loc = place[0];
                [loc incrementKey:@"numPosts"];
                [loc saveInBackground];
            }
            else {
                // If does not exist, create new Location
                [Location initLocation:placeId];
            }
            completion(placeId, nil);
        } else {
            NSLog(@"%@", error.localizedDescription);
            completion(nil, error);
        }
    }];
}

// Create new location given the place ID
+ (void)initLocation:(NSString *)placeId {
    // Get API key from Keys.plist
    NSString *path = [[NSBundle mainBundle] pathForResource: @"Keys" ofType: @"plist"];
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile: path];
    
    // Return suggested autocomplete locations from Places API
    NSString *gMapsAPIKey = [dict objectForKey: @"google_api_key"];
    NSURL *url = [NSURL URLWithString: [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/details/json?place_id=%@&key=%@", placeId, gMapsAPIKey]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10.0];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error != nil) {
           NSLog(@"%@", [error localizedDescription]);
        }
        else {
            // Create new Location instance from returned place details
            NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            NSDictionary *locInfo = dataDictionary[@"result"];
            Location *newLoc = [Location new];
            newLoc.name = locInfo[@"name"];
            newLoc.latitude = locInfo[@"geometry"][@"location"][@"lat"];
            newLoc.longitude = locInfo[@"geometry"][@"location"][@"lng"];
            newLoc.numPosts = @(1);
            newLoc.placeID = placeId;
            [newLoc saveInBackground];
        }
    }];
    [task resume];
}
@end
