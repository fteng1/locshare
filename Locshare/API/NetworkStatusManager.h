//
//  NetworkStatusManager.h
//  Locshare
//
//  Created by Felianne Teng on 8/6/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NetworkStatusManager : NSObject

+ (BOOL)isConnectedToInternet;

@end

NS_ASSUME_NONNULL_END
