//
//  Comment.h
//  Locshare
//
//  Created by Felianne Teng on 7/12/21.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

NS_ASSUME_NONNULL_BEGIN

@interface Comment : NSObject

@property (nonatomic, strong) PFUser *author;
@property (nonatomic, strong) NSString *userID;
@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSDate *createdAt;

@end

NS_ASSUME_NONNULL_END
