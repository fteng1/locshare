//
//  Location.m
//  Locshare
//
//  Created by Felianne Teng on 7/12/21.
//

#import "Location.h"
#import <Parse/Parse.h>
#import "LocationManager.h"

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
    // Get details about location from place ID
    [[LocationManager shared] getPlaceDetails:placeId completion:^(NSDictionary * _Nonnull locInfo, NSError * _Nonnull error) {
        Location *newLoc = [Location new];
        newLoc.name = locInfo[@"name"];
        newLoc.latitude = locInfo[@"geometry"][@"location"][@"lat"];
        newLoc.longitude = locInfo[@"geometry"][@"location"][@"lng"];
        newLoc.numPosts = @(1);
        newLoc.placeID = placeId;
        [newLoc saveInBackground];
    }];
}
@end
