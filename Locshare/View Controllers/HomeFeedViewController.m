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
#import "LocationManager.h"
#import "LocationMarker.h"
#import "LocationViewController.h"

@interface HomeFeedViewController () <CLLocationManagerDelegate, GMSMapViewDelegate>
@property (weak, nonatomic) IBOutlet GMSMapView *homeMapView;

@end

GMSPlacesClient *placesClient;

@implementation HomeFeedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Set up for Places API
    placesClient = [GMSPlacesClient sharedClient];
    
    // Set initial camera position of the MapView
    [self updateDefaultPosition];
    [self displayVisibleLocations];
    
    self.homeMapView.delegate = self;
}

- (void)updateDefaultPosition {
    // Get most updated position
    CLLocation *currentLocation = [LocationManager shared].location;
    
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

- (GMSCoordinateBounds *)getVisibleRegion {
    // Find region currently visible in homeMapView
    GMSVisibleRegion visRegion = self.homeMapView.projection.visibleRegion;
    GMSCoordinateBounds *coordBounds = [[GMSCoordinateBounds alloc] initWithRegion:visRegion];
    return coordBounds;
}

// Update currently shown regions on MapView to display locations that have posts
- (void)displayVisibleLocations {
    // Get coordinates currently shown on MapView
    GMSCoordinateBounds *currentlyVisible = [self getVisibleRegion];
    PFGeoPoint *southWest = [PFGeoPoint geoPointWithLatitude:currentlyVisible.southWest.latitude longitude:currentlyVisible.southWest.longitude];
    PFGeoPoint *northEast = [PFGeoPoint geoPointWithLatitude:currentlyVisible.northEast.latitude longitude:currentlyVisible.northEast.longitude];
    
    // Set query to find locations that fall within the visible region on the map and have posts
    PFQuery *query = [PFQuery queryWithClassName:@"Location"];
    [query whereKey:@"coordinate" withinGeoBoxFromSouthwest:southWest toNortheast:northEast];
    [query whereKey:@"numPosts" greaterThanOrEqualTo:@(0)];
    
    // Retrieve results from Parse using asynchronous call
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable locations, NSError * _Nullable error) {
        for (Location *loc in locations) {
            CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(loc.coordinate.latitude, loc.coordinate.longitude);
            LocationMarker *marker = [[LocationMarker alloc] initMarkerWithPosition:coord withLocation:loc];
            marker.map = self.homeMapView;
        }
    }];
}

// Perform segue to view posts at location screen when marker is tapped
- (BOOL)mapView:(GMSMapView *)mapView didTapMarker:(GMSMarker *)marker {
    [self performSegueWithIdentifier:@"locationSegue" sender:marker];
    return true;
}

// Show newly visible locations once map is moved
- (void)mapView:(GMSMapView *)mapView willMove:(BOOL)gesture {
    [self displayVisibleLocations];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Bring up location view screen if marker is tapped
    if ([[segue identifier] isEqualToString:@"locationSegue"]) {
        LocationMarker *marker = sender;
        LocationViewController *locationViewController = [segue destinationViewController];
        locationViewController.location = marker.location;
    }
}

@end
