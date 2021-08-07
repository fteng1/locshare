//
//  NetworkStatusManager.m
//  Locshare
//
//  Created by Felianne Teng on 8/6/21.
//

#import "NetworkStatusManager.h"
#import <AFNetworking/AFNetworking.h>

@implementation NetworkStatusManager

+ (BOOL)isConnectedToInternet {
    return [AFNetworkReachabilityManager sharedManager].isReachable;
}

@end
