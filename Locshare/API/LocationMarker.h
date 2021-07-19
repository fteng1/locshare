//
//  LocationMarker.h
//  Locshare
//
//  Created by Felianne Teng on 7/19/21.
//

#import <GoogleMaps/GoogleMaps.h>
#import "Location.h"

NS_ASSUME_NONNULL_BEGIN

@interface LocationMarker : GMSMarker

@property (strong, nonatomic) Location *location;

-(instancetype)initMarkerWithPosition:(CLLocationCoordinate2D)coord withLocation:(Location *)loc;

@end

NS_ASSUME_NONNULL_END
