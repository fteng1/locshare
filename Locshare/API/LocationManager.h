//
//  LocationManager.h
//  Locshare
//
//  Created by Felianne Teng on 7/16/21.
//

#import <CoreLocation/CoreLocation.h>
#import <GoogleMaps/GoogleMaps.h>

NS_ASSUME_NONNULL_BEGIN

@interface LocationManager : CLLocationManager

+ (instancetype)shared;

- (void)getSuggestedLocations:(NSString *)searchQuery completion:(void (^)(NSArray *, NSError *))completion;
- (void)getNearbyLocations:(void (^)(NSArray *, NSError *))completion;
- (void)makeURLRequest:(NSURL *)url completion:(void (^)(NSDictionary *, NSError *))completion;
- (void)getPlaceDetails:(NSString *)placeId completion:(void (^)(NSDictionary *, NSError *))completion;
- (void)displayLocationsOnMap:(GMSMapView *)mapView locations:(NSArray *)locations userFiltering:(BOOL)filter;

@end

NS_ASSUME_NONNULL_END
