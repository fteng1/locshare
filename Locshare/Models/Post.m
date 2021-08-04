//
//  Post.m
//  Locshare
//
//  Created by Felianne Teng on 7/12/21.
//

#import "Post.h"
#import "Constants.h"

@implementation Post

@dynamic author;
@dynamic caption;
@dynamic photos;
@dynamic numLikes;
@dynamic numComments;
@dynamic authorUsername;
@dynamic location;
@dynamic comments;
@dynamic private;

+ (nonnull NSString *)parseClassName {
    return POST_PARSE_CLASS_NAME;
}

+ (Post *) initPost: ( NSArray * _Nullable )images withCaption: ( NSString * _Nullable )caption withLocation: (NSString * _Nullable)locID private:(BOOL)isPrivate {
    // Initialize fields
    Post *newPost = [Post new];
    newPost.photos = [[NSMutableArray alloc] init];
    
    for (UIImage *image in images)  {
        [newPost.photos addObject:[self getPFFileFromImage:image]];
    }
    newPost.author = [PFUser currentUser];
    newPost.caption = caption;
    newPost.numLikes = [ProjectNumbers zero];
    newPost.numComments = [ProjectNumbers zero];
    newPost.authorUsername = [PFUser currentUser].username;
    newPost.comments = [[NSMutableArray alloc] init];
    newPost.location = locID;
    newPost.private = isPrivate;
    return newPost;
}

+ (void) makePost: (Post *)post completion:(void (^)(NSString *, NSError *))completion{
    [post saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (error == nil) {
            completion(post.author.objectId, nil);
        }
        else {
            completion(nil, error);
        }
    }];
    
}

// Returns PFFile representation of UIImage
+ (PFFileObject *)getPFFileFromImage: (UIImage * _Nullable)image {
    // check if image is not nil
    if (!image) {
        return nil;
    }
    NSData *imageData = UIImageJPEGRepresentation(image, POST_IMAGE_COMPRESSION_QUALITY);
    
    // get image data and check if that is not nil
    if (!imageData) {
        return nil;
    }
    return [PFFileObject fileObjectWithName:POST_IMAGE_DEFAULT_NAME data:imageData];
}

@end
