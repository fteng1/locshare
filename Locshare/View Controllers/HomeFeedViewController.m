//
//  HomeFeedViewController.m
//  Locshare
//
//  Created by Felianne Teng on 7/12/21.
//

#import "HomeFeedViewController.h"
#import <GoogleMaps/GoogleMaps.h>
#import <GooglePlaces/GooglePlaces.h>
#import <Parse/Parse.h>
#import "Location.h"

@interface HomeFeedViewController () <CLLocationManagerDelegate>
@property (weak, nonatomic) IBOutlet GMSMapView *homeMapView;

@end

CLLocationManager *locationManager;
CLLocation * _Nullable currentLocation;
GMSPlacesClient *placesClient;
float preciseLocationZoomLevel;
float approximateLocationZoomLevel;

@implementation HomeFeedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Initialize the location manager.
    locationManager = [[CLLocationManager alloc] init];
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [locationManager requestWhenInUseAuthorization];
    locationManager.distanceFilter = 50;
    [locationManager startUpdatingLocation];
    locationManager.delegate = self;

    placesClient = [GMSPlacesClient sharedClient];
    
    // Get the current location using the location manager
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;

    // Ask user for permission to use location
    [locationManager requestWhenInUseAuthorization];
    [locationManager startUpdatingLocation];
    
    // Set initial camera position of the MapView
    [self updateDefaultPosition];
    [self displayVisibleLocations];
}

- (void)updateDefaultPosition {
    // Get most updated position
    CLLocation *currentLocation = locationManager.location;
    
    if (currentLocation != nil) {
        // Set camera of map to be at current position
        GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:currentLocation.coordinate.latitude longitude:currentLocation.coordinate.longitude zoom:10.0];
        [self.homeMapView setCamera:camera];
        self.homeMapView.settings.myLocationButton = YES;
        self.homeMapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        // Display current location on map
        self.homeMapView.myLocationEnabled = YES;
    }
    else {
        // TODO: change default location if no current location
    }
}

- (CGRect)getVisibleRegion {
    // Find region currently visible in homeMapView
    GMSVisibleRegion visRegion = self.homeMapView.projection.visibleRegion;
    GMSCoordinateBounds *coordBounds = [[GMSCoordinateBounds alloc] initWithRegion:visRegion];
    
    // Get dimensions for the CGRect
    CGFloat width = coordBounds.northEast.longitude - coordBounds.southWest.longitude;
    CGFloat height = coordBounds.northEast.latitude - coordBounds.southWest.latitude;
    CGRect window = CGRectMake(coordBounds.southWest.longitude, coordBounds.southWest.latitude, width, height);
    return window;
}

- (void)displayVisibleLocations {
    // Get coordinates currently shown on MapView
    CGRect currentlyVisible = [self getVisibleRegion];
    
    // Retrieve locations that fall within the visible region on the map and have posts
    PFQuery *query = [PFQuery queryWithClassName:@"Location"];
    [query whereKey:@"longitude" greaterThanOrEqualTo:@(currentlyVisible.origin.x)];
    [query whereKey:@"latitude" greaterThanOrEqualTo:@(currentlyVisible.origin.y)];
    [query whereKey:@"longitude" lessThanOrEqualTo:@(currentlyVisible.origin
     .x + currentlyVisible.size.width)];
    [query whereKey:@"latitude" lessThanOrEqualTo:@(currentlyVisible.origin
     .y + currentlyVisible.size.height)];
    [query whereKey:@"numPosts" greaterThanOrEqualTo:@(0)];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable locations, NSError * _Nullable error) {
        for (Location *loc in locations) {
            GMSMarker *marker = [GMSMarker markerWithPosition:CLLocationCoordinate2DMake([loc.latitude doubleValue], [loc.longitude doubleValue])];
            marker.map = self.homeMapView;
        }
    }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
