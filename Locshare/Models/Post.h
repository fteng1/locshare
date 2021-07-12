//
//  Post.h
//  Locshare
//
//  Created by Felianne Teng on 7/12/21.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
#import "Location.h"

NS_ASSUME_NONNULL_BEGIN

@interface Post : NSObject

@property (nonatomic, strong) NSString *postID;
@property (nonatomic, strong) NSString *userID;
@property (nonatomic, strong) PFUser *author;

@property (nonatomic, strong) NSString *caption;
@property (nonatomic, strong) NSMutableArray *photos;
@property (nonatomic, strong) NSNumber *numLikes;
@property (nonatomic, strong) NSNumber *numComments;
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) Location *location;
@property (nonatomic, strong) NSDate *createdAt;
@property (nonatomic, strong) NSMutableArray *comments;

@end

NS_ASSUME_NONNULL_END
