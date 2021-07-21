//
//  Post.h
//  Locshare
//
//  Created by Felianne Teng on 7/12/21.
//

#import <Foundation/Foundation.h>
#import "Parse/Parse.h"
#import "Location.h"

NS_ASSUME_NONNULL_BEGIN

@interface Post : PFObject<PFSubclassing>

@property (nonatomic, strong) PFUser *author;
@property (nonatomic, strong) NSString *caption;
@property (nonatomic, strong) NSMutableArray *photos;
@property (nonatomic, strong) NSNumber *numLikes;
@property (nonatomic, strong) NSNumber *numComments;
@property (nonatomic, strong) NSString *authorUsername;
@property (nonatomic, strong) NSString *location;
@property (nonatomic, strong) NSMutableArray *comments;

+ (Post *) initPost: ( NSArray * _Nullable )images withCaption: ( NSString * _Nullable )caption withLocation: (NSString * _Nullable)loc;
+ (void) makePost: (Post *)post completion:(void (^)(NSString *, NSError *))completion;
+ (PFFileObject *)getPFFileFromImage: (UIImage * _Nullable)image;

@end

NS_ASSUME_NONNULL_END
