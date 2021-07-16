//
//  LocationManager.h
//  Locshare
//
//  Created by Felianne Teng on 7/16/21.
//

#import <CoreLocation/CoreLocation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LocationManager : CLLocationManager

+ (instancetype)shared;

- (void)getSuggestedLocations:(NSString *)searchQuery completion:(void (^)(NSArray *, NSError *))completion;
- (void)getNearbyLocations:(void (^)(NSArray *, NSError *))completion;

@end

NS_ASSUME_NONNULL_END
