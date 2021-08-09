//
//  CachedUserManager.m
//  Locshare
//
//  Created by Felianne Teng on 8/6/21.
//

#import "CachedUserManager.h"
#import "Constants.h"
#import "Post.h"
#import "AppDelegate.h"

@implementation CachedUserManager

+ (PFUser *)getPFUserFromCachedUser:(CachedUser *)user {
    PFUser *toReturn = [PFUser new];
    toReturn[USER_FRIENDS_KEY] = user.friends;
    toReturn[USER_LIKED_POSTS_KEY] = user.likedPosts;
    toReturn[USER_PENDING_FRIENDS_KEY] = user.pendingFriends;
    toReturn[USER_REQUESTS_SENT_KEY] = user.requestsSent;
    toReturn[USER_PROFILE_PICTURE_KEY] = [Post getPFFileFromImage:[UIImage imageWithData:user.profilePicture]];
    toReturn.objectId = user.objectId;
    toReturn[USER_TAGLINE_KEY] = user.tagline;
    toReturn.username = user.username;
    toReturn[USER_NUM_FRIENDS_KEY] = @(user.numFriends);
    toReturn[USER_NUM_POSTS_KEY] = @(user.numPosts);
    return toReturn;
}

+ (CachedUser *)getCachedUserFromPFUser:(PFUser *)user {
    NSManagedObjectContext *context = ((AppDelegate *) UIApplication.sharedApplication.delegate).persistentContainer.viewContext;
    CachedUser *toReturn = [NSEntityDescription insertNewObjectForEntityForName:CACHED_USER_CLASS_NAME inManagedObjectContext:context];
    toReturn.friends = user[USER_FRIENDS_KEY];
    toReturn.likedPosts = user[USER_LIKED_POSTS_KEY];
    toReturn.pendingFriends = user[USER_PENDING_FRIENDS_KEY];
    toReturn.requestsSent = user[USER_REQUESTS_SENT_KEY];
    toReturn.profilePicture = [user[USER_PROFILE_PICTURE_KEY] getData];
    toReturn.objectId = user.objectId;
    toReturn.tagline = user[USER_TAGLINE_KEY];
    toReturn.username = user.username;
    toReturn.numFriends = [user[USER_NUM_FRIENDS_KEY] intValue];
    toReturn.numPosts = [user[USER_NUM_POSTS_KEY] intValue];
    return toReturn;
}

@end
