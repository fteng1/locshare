//
//  LocationMarker.m
//  Locshare
//
//  Created by Felianne Teng on 7/19/21.
//

#import "LocationMarker.h"

@implementation LocationMarker

-(instancetype)initMarkerWithPosition:(CLLocationCoordinate2D)coord withLocation:(Location *)loc {
    self = [super init];
    self.position = coord;
    self.location = loc;
    
    return self;
}
@end
