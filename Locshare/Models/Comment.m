//
//  Comment.m
//  Locshare
//
//  Created by Felianne Teng on 7/12/21.
//

#import "Comment.h"

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

@end
