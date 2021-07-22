//
//  Location.h
//  Locshare
//
//  Created by Felianne Teng on 7/12/21.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

NS_ASSUME_NONNULL_BEGIN

@interface Location : PFObject<PFSubclassing>

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) PFGeoPoint *coordinate;
@property (nonatomic, strong) NSNumber *numPosts;
@property (nonatomic, strong) NSString *placeID;
@property (nonatomic, strong) NSMutableArray *usersWithPosts;

+ (void)tagLocation:(NSString *)placeId newPost:(NSString *)postId completion:(void (^)(NSError *))completion;

@end

NS_ASSUME_NONNULL_END
