//
//  Post.m
//  Locshare
//
//  Created by Felianne Teng on 7/12/21.
//

#import "Post.h"

@implementation Post

@dynamic postID;
@dynamic userID;
@dynamic author;
@dynamic caption;
@dynamic photos;
@dynamic numLikes;
@dynamic numComments;
@dynamic authorUsername;
@dynamic location;
@dynamic comments;

+ (nonnull NSString *)parseClassName {
    return @"Post";
}

+ (Post *) initPost: ( NSArray * _Nullable )images withCaption: ( NSString * _Nullable )caption withLocation: (NSString * _Nullable)locID {
    // Initialize fields
    Post *newPost = [Post new];
    newPost.photos = [[NSMutableArray alloc] init];
    
    for (UIImage *image in images)  {
        [newPost.photos addObject:[self getPFFileFromImage:image]];
    }
    
    newPost.author = [PFUser currentUser];
    newPost.caption = caption;
    newPost.numLikes = @(0);
    newPost.numComments = @(0);
    newPost.authorUsername = [PFUser currentUser].username;
    newPost.comments = [[NSMutableArray alloc] init];
    newPost.location = locID;
    return newPost;
}

+ (void) makePost: (Post *)post withCompletion: (PFBooleanResultBlock  _Nullable)completion {
    [post saveInBackgroundWithBlock: completion];
    
}

// Returns PFFile representation of UIImage
+ (PFFileObject *)getPFFileFromImage: (UIImage * _Nullable)image {
    // check if image is not nil
    if (!image) {
        return nil;
    }
    
    NSData *imageData = UIImagePNGRepresentation(image);
    // get image data and check if that is not nil
    if (!imageData) {
        return nil;
    }
    
    return [PFFileObject fileObjectWithName:@"image.png" data:imageData];
}

@end
