//
//  Location.m
//  Locshare
//
//  Created by Felianne Teng on 7/12/21.
//

#import "Location.h"
#import <Parse/Parse.h>
#import "LocationManager.h"
#import "Post.h"

@implementation Location

@dynamic name;
@dynamic coordinate;
@dynamic numPosts;
@dynamic placeID;
@dynamic usersWithPosts;
@dynamic hasPublicPosts;

+ (nonnull NSString *)parseClassName {
    return @"Location";
}

// Function to update Location object in Parse to reflect new post
+ (void)tagLocation:(NSString *)placeId newPost:(Post *)post completion:(void (^)(NSError *))completion{
    PFQuery *query = [PFQuery queryWithClassName:@"Location"];
    [query whereKey:@"placeID" equalTo:placeId];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *place, NSError *error) {
        if (place != nil) {
            // Check if Location with given placeID already exists in Parse
            if ([place count] != 0) {
                // If already exists, increase number of posts by 1
                Location *loc = place[0];
                [loc incrementKey:@"numPosts"];
                [loc addObject:post.objectId forKey:@"usersWithPosts"];
                if (!post.private) {
                    loc.hasPublicPosts = true;
                }
                [loc saveInBackground];
            }
            else {
                // If does not exist, create new Location
                [Location initLocation:placeId newPost:post];
            }
            completion(nil);
        } else {
            completion(error);
        }
    }];
}

// Create new location given the place ID and author of new post
+ (void)initLocation:(NSString *)placeId newPost:(Post *)post {
    // Get details about location from place ID
    [[LocationManager shared] getPlaceDetails:placeId completion:^(NSDictionary * _Nonnull locInfo, NSError * _Nonnull error) {
        Location *newLoc = [Location new];
        newLoc.name = locInfo[@"name"];
        NSNumber *latitude = locInfo[@"geometry"][@"location"][@"lat"];
        NSNumber *longitude = locInfo[@"geometry"][@"location"][@"lng"];
        newLoc.coordinate = [PFGeoPoint geoPointWithLatitude:[latitude floatValue] longitude:[longitude floatValue]];
        newLoc.numPosts = @(1);
        newLoc.placeID = placeId;
        newLoc.usersWithPosts = [[NSMutableArray alloc] init];
        [newLoc.usersWithPosts addObject:post.objectId];
        if (!post.private) {
            newLoc.hasPublicPosts = true;
        }
        [newLoc saveInBackground];
    }];
}
@end
