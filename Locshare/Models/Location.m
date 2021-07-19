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
@dynamic coordinate;
@dynamic numPosts;
@dynamic placeID;
@dynamic posts;

+ (nonnull NSString *)parseClassName {
    return @"Location";
}

// Function to update Location object in Parse to reflect new post
+ (void)tagLocation:(NSString *)placeId newPost:(NSString *)postId completion:(void (^)(NSError *))completion{
    PFQuery *query = [PFQuery queryWithClassName:@"Location"];
    [query whereKey:@"placeID" equalTo:placeId];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *place, NSError *error) {
        if (place != nil) {
            // Check if Location with given placeID already exists in Parse
            if ([place count] != 0) {
                // If already exists, increase number of posts by 1
                Location *loc = place[0];
                [loc incrementKey:@"numPosts"];
                [loc addObject:postId forKey:@"posts"];
                [loc saveInBackground];
            }
            else {
                // If does not exist, create new Location
                [Location initLocation:placeId newPost:postId];
            }
            completion(nil);
        } else {
            NSLog(@"%@", error.localizedDescription);
            completion(error);
        }
    }];
}

// Create new location given the place ID and new post
+ (void)initLocation:(NSString *)placeId newPost:(NSString *)postID {
    // Get details about location from place ID
    [[LocationManager shared] getPlaceDetails:placeId completion:^(NSDictionary * _Nonnull locInfo, NSError * _Nonnull error) {
        Location *newLoc = [Location new];
        newLoc.name = locInfo[@"name"];
        NSNumber *latitude = locInfo[@"geometry"][@"location"][@"lat"];
        NSNumber *longitude = locInfo[@"geometry"][@"location"][@"lng"];
        newLoc.coordinate = [PFGeoPoint geoPointWithLatitude:[latitude floatValue] longitude:[longitude floatValue]];
        newLoc.numPosts = @(1);
        newLoc.placeID = placeId;
        newLoc.posts = [[NSMutableArray alloc] init];
        [newLoc.posts addObject:postID];
        [newLoc saveInBackground];
    }];
}
@end
