//
//  User.h
//  Locshare
//
//  Created by Felianne Teng on 7/12/21.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

NS_ASSUME_NONNULL_BEGIN

@interface User : PFObject<PFSubclassing>

@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) NSString *tagline;
@property (nonatomic, strong) NSNumber *numPosts;
@property (nonatomic, strong) NSData *profilePicture;
@property (nonatomic, strong) NSString *userID;

@end

NS_ASSUME_NONNULL_END
