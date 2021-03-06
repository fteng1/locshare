//
//  Post.m
//  Locshare
//
//  Created by Felianne Teng on 7/12/21.
//

#import "Post.h"
#import "Constants.h"
#import <Parse/Parse.h>
#import "AppDelegate.h"
#import "CachedUserManager.h"
#import "PostPhoto+CoreDataProperties.h"

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

+ (Post *)initFromCachedPost: (CachedPost *)post {
    Post *newPost = [Post new];
    // Get author of post from stored data
    NSFetchRequest *request = CachedUser.fetchRequest;
    [request setPredicate:[NSPredicate predicateWithFormat:CACHED_OBJECT_ID_FILTER_PREDICATE, post.authorId]];
    NSManagedObjectContext *context = ((AppDelegate *) UIApplication.sharedApplication.delegate).persistentContainer.viewContext;
    NSError *error = nil;
    NSArray *results = [context executeFetchRequest:request error:&error];
    if (error == nil && results.count > 0) {
        newPost.author = [CachedUserManager getPFUserFromCachedUser:[results firstObject]];
    }
    else {
        newPost.author = [PFUser new];
        newPost.author.objectId = post.authorId;
        newPost.author.username = post.authorUsername;
    }
    newPost.caption = post.caption;
    NSMutableArray *convertedPhotos = [NSMutableArray new];
    for (PostPhoto *obj in post.photosInPost) {
        [convertedPhotos addObject:[PFFileObject fileObjectWithName:POST_IMAGE_DEFAULT_NAME data:obj.photo]];
    }
    newPost.photos = convertedPhotos;
    newPost.numLikes = @(post.numLikes);
    newPost.numComments = @(post.numComments);
    newPost.authorUsername = post.authorUsername;
    newPost.location = post.location;
    newPost.comments = [NSMutableArray arrayWithArray:post.comments];
    newPost.private = post.private;
    newPost.objectId = post.objectId;
    return newPost;
}

- (void)cachedPost:(void (^)(CachedPost *, NSError *))completion {
    NSManagedObjectContext *context = ((AppDelegate *) UIApplication.sharedApplication.delegate).persistentContainer.viewContext;
    CachedPost *newPost = [NSEntityDescription insertNewObjectForEntityForName:CACHED_POST_CLASS_NAME inManagedObjectContext:context];
    newPost.authorId = self.author.objectId;
    newPost.authorUsername = self.authorUsername;
    newPost.caption = self.caption;
    newPost.comments = self.comments;
    newPost.createdAt = self.createdAt;
    newPost.location = self.location;
    newPost.numComments = [self.numComments integerValue];
    newPost.numLikes = [self.numLikes integerValue];
    newPost.private = self.private;
    newPost.objectId = self.objectId;
    
    for (PFFileObject *obj in self.photos) {
        [obj getDataInBackgroundWithBlock:^(NSData * _Nullable data, NSError * _Nullable error) {
            PostPhoto *photo = [NSEntityDescription insertNewObjectForEntityForName:CACHED_PHOTO_CLASS_NAME inManagedObjectContext:context];
            photo.photo = data;
            [newPost addPhotosInPostObject:photo];
            NSError *err = nil;
            [context save:&err];
            if (newPost.photosInPost.count == self.photos.count) {
                completion(newPost, nil);
            }
        }];
    }
}
@end
