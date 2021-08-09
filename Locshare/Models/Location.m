//
//  Location.m
//  Locshare
//
//  Created by Felianne Teng on 7/12/21.
//

#import "Location.h"
#import <Parse/Parse.h>
#import "LocationManager.h"
#import "Constants.h"
#import "AppDelegate.h"

@implementation Location

@dynamic name;
@dynamic coordinate;
@dynamic numPosts;
@dynamic placeID;
@dynamic usersWithPosts;
@dynamic hasPublicPosts;

+ (nonnull NSString *)parseClassName {
    return LOCATION_PARSE_CLASS_NAME;
}

// Function to update Location object in Parse to reflect new post
+ (void)tagLocation:(NSString *)placeId newPost:(Post *)post completion:(void (^)(NSError *))completion{
    PFQuery *query = [PFQuery queryWithClassName:LOCATION_PARSE_CLASS_NAME];
    [query whereKey:LOCATION_PLACE_ID_KEY equalTo:placeId];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *place, NSError *error) {
        if (place != nil) {
            // Check if Location with given placeID already exists in Parse
            if ([place count] != 0) {
                // If already exists, increase number of posts by 1
                Location *loc = [place firstObject];
                [loc incrementKey:LOCATION_NUM_POSTS_KEY];
                [loc addObject:post.objectId forKey:LOCATION_USERS_WITH_POSTS_KEY];
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
        newLoc.name = locInfo[PLACE_DETAILS_NAME_KEY];
        NSNumber *latitude = locInfo[PLACE_DETAILS_GEOMETRY_KEY][PLACE_DETAILS_LOCATION_KEY][PLACE_DETAILS_LATITUDE_KEY];
        NSNumber *longitude = locInfo[PLACE_DETAILS_GEOMETRY_KEY][PLACE_DETAILS_LOCATION_KEY][PLACE_DETAILS_LONGITUDE_KEY];
        newLoc.coordinate = [PFGeoPoint geoPointWithLatitude:[latitude floatValue] longitude:[longitude floatValue]];
        newLoc.numPosts = [ProjectNumbers one];
        newLoc.placeID = placeId;
        newLoc.usersWithPosts = [[NSMutableArray alloc] init];
        [newLoc.usersWithPosts addObject:post.author.objectId];
        if (!post.private) {
            newLoc.hasPublicPosts = true;
        }
        [newLoc saveInBackground];
    }];
}

+ (Location *)initFromCachedLocation: (CachedLocation *)loc {
    Location *newLoc = [Location new];
    newLoc.name = loc.name;
    newLoc.coordinate = [PFGeoPoint geoPointWithLatitude:loc.latitude longitude:loc.longitude];
    newLoc.numPosts = @(loc.numPosts);
    newLoc.placeID = loc.placeID;
    newLoc.usersWithPosts = [NSMutableArray arrayWithArray:loc.usersWithPosts];
    newLoc.hasPublicPosts = loc.hasPublicPosts;
    return newLoc;
}

- (CachedLocation *)cachedLocation {
    NSManagedObjectContext *context = ((AppDelegate *) UIApplication.sharedApplication.delegate).persistentContainer.viewContext;
    CachedLocation *newLoc = [NSEntityDescription insertNewObjectForEntityForName:CACHED_LOCATION_CLASS_NAME inManagedObjectContext:context];
    newLoc.usersWithPosts = self.usersWithPosts;
    newLoc.hasPublicPosts = self.hasPublicPosts;
    newLoc.name = self.name;
    newLoc.placeID = self.placeID;
    newLoc.latitude = self.coordinate.latitude;
    newLoc.longitude = self.coordinate.longitude;
    newLoc.numPosts = [self.numPosts intValue];
    return newLoc;
}


@end
