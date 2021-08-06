//
//  CachedUserManager.h
//  Locshare
//
//  Created by Felianne Teng on 8/6/21.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
#import "CachedUser+CoreDataClass.h"

NS_ASSUME_NONNULL_BEGIN

@interface CachedUserManager : NSObject

+ (PFUser *)getPFUserFromCachedUser:(CachedUser *)user;
+ (CachedUser *)getCachedUserFromPFUser:(PFUser *)user;

@end

NS_ASSUME_NONNULL_END
