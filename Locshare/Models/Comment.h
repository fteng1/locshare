//
//  Comment.h
//  Locshare
//
//  Created by Felianne Teng on 7/12/21.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
#import "Post.h"
#import "CachedComment+CoreDataProperties.h"

NS_ASSUME_NONNULL_BEGIN

@interface Comment : PFObject<PFSubclassing>

@property (nonatomic, strong) PFUser *author;
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSString *postID;

+ (instancetype)initWithText:(NSString *)text author:(PFUser *)author post:(Post *)post;
+ (Comment *) initFromCachedComment: (CachedComment *)comment;
- (CachedComment *)cachedComment;

@end

NS_ASSUME_NONNULL_END
