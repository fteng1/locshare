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

// Update currently shown regions on MapView to display locations that have posts
- (void)displayVisibleLocations {
    // Get coordinates currently shown on MapView
    CGRect currentlyVisible = [self getVisibleRegion];
    
    // Set query to find locations that fall within the visible region on the map and have posts
    PFQuery *query = [PFQuery queryWithClassName:@"Location"];
    [query whereKey:@"longitude" greaterThanOrEqualTo:@(currentlyVisible.origin.x)];
    [query whereKey:@"latitude" greaterThanOrEqualTo:@(currentlyVisible.origin.y)];
    [query whereKey:@"longitude" lessThanOrEqualTo:@(currentlyVisible.origin
     .x + currentlyVisible.size.width)];
    [query whereKey:@"latitude" lessThanOrEqualTo:@(currentlyVisible.origin
     .y + currentlyVisible.size.height)];
    [query whereKey:@"numPosts" greaterThanOrEqualTo:@(0)];
    // TODO: account for longitude discontinuity
    
    // Retrieve results from Parse using asynchronous call
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable locations, NSError * _Nullable error) {
        for (Location *loc in locations) {
            CLLocationCoordinate2D coord = CLLocationCoordinate2DMake([loc.latitude doubleValue], [loc.longitude doubleValue]);
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
