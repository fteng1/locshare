//
//  HomeFeedViewController.m
//  Locshare
//
//  Created by Felianne Teng on 7/12/21.
//

#import "HomeFeedViewController.h"
#import <GoogleMaps/GoogleMaps.h>
#import <GooglePlaces/GooglePlaces.h>

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
}


- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    
    // Get most updated position
    CLLocation *currentLocation = [locations lastObject];

    // Set camera of map to be at current position
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:currentLocation.coordinate.latitude longitude:currentLocation.coordinate.longitude zoom:10.0];
    [self.homeMapView setCamera:camera];
    self.homeMapView.settings.myLocationButton = YES;
    self.homeMapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    // Display current location on map
    self.homeMapView.myLocationEnabled = YES;
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
