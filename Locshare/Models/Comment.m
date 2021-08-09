//
//  Comment.m
//  Locshare
//
//  Created by Felianne Teng on 7/12/21.
//

#import "Comment.h"
#import "CachedUserManager.h"
#import "Constants.h"
#import "AppDelegate.h"

@implementation Comment

@dynamic author;
@dynamic username;
@dynamic text;
@dynamic postID;

+ (nonnull NSString *)parseClassName {
    return @"Comment";
}

+ (instancetype)initWithText:(NSString *)text author:(PFUser *)author post:(Post *)post {
    Comment *newComment = [[Comment alloc] init];
    newComment.author = author;
    newComment.username = author.username;
    newComment.text = text;
    newComment.postID = post.objectId;
    return newComment;
}

+ (Comment *) initFromCachedComment: (CachedComment *)comment {
    Comment *newComment = [Comment new];
    NSFetchRequest *request = CachedComment.fetchRequest;
    [request setPredicate:[NSPredicate predicateWithFormat:CACHED_OBJECT_ID_FILTER_PREDICATE, comment.authorId]];
    NSManagedObjectContext *context = ((AppDelegate *) UIApplication.sharedApplication.delegate).persistentContainer.viewContext;
    NSError *error = nil;
    NSArray *results = [context executeFetchRequest:request error:&error];
    if (error == nil && results.count > 0) {
        newComment.author = [CachedUserManager getPFUserFromCachedUser:[results firstObject]];
    }
    newComment.username = comment.username;
    newComment.text = comment.text;
    newComment.postID = comment.postID;
    return newComment;
}

- (CachedComment *)cachedComment {
    NSManagedObjectContext *context = ((AppDelegate *) UIApplication.sharedApplication.delegate).persistentContainer.viewContext;
    CachedComment *toStore = [NSEntityDescription insertNewObjectForEntityForName:CACHED_COMMENT_CLASS_NAME inManagedObjectContext:context];
    toStore.authorId = self.author.objectId;
    toStore.username = self.username;
    toStore.text = self.text;
    toStore.postID = self.postID;
    return toStore;
}

@end
