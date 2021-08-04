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
#import "SceneDelegate.h"
#import "LoginViewController.h"
#import "AlertManager.h"
#import "Constants.h"

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

- (void)viewWillAppear:(BOOL)animated {
    [self displayVisibleLocations];
}

- (void)updateDefaultPosition {
    // Get most updated position
    CLLocation *currentLocation = [LocationManager shared].location;
    
    GMSCameraPosition *camera = nil;
    if (currentLocation != nil) {
        // Set camera of map to be at current position
        camera = [GMSCameraPosition cameraWithLatitude:currentLocation.coordinate.latitude longitude:currentLocation.coordinate.longitude zoom:MAP_FEED_DEFAULT_ZOOM];

        // Display current location on map
        self.homeMapView.myLocationEnabled = YES;
        self.homeMapView.settings.myLocationButton = YES;
    }
    else {
        // Set default location to be center of US
        camera = [ProjectLocations defaultLocation];
    }
    [self.homeMapView setCamera:camera];
    self.homeMapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
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
    PFQuery *geoQuery = [PFQuery queryWithClassName:LOCATION_PARSE_CLASS_NAME];
    [geoQuery whereKey:LOCATION_COORDINATE_KEY withinGeoBoxFromSouthwest:southWest toNortheast:northEast];
    [geoQuery whereKey:LOCATION_NUM_POSTS_KEY greaterThanOrEqualTo:[ProjectNumbers zero]];
    
    // Retrieve results from Parse using asynchronous call
    [geoQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable locations, NSError * _Nullable error) {
        NSMutableSet *friendsWithSelf = [NSMutableSet setWithArray:[PFUser currentUser][USER_FRIENDS_KEY]];
        [friendsWithSelf addObject:[PFUser currentUser].objectId];
        
        // Only show locations on the map with posts from friends/current user or have public posts
        NSMutableArray *visibleLocations = [NSMutableArray new];
        for (Location *loc in locations) {
            if (loc.hasPublicPosts) {
                [visibleLocations addObject:loc];
            }
            else {
                // Check if any users with posts are the current user or the current user's friends
                NSSet *usersWithPosts = [NSMutableSet setWithArray:loc.usersWithPosts];
                if ([friendsWithSelf intersectsSet:usersWithPosts]) {
                    [visibleLocations addObject:loc];
                };
            }
            
        }
        [[LocationManager shared] displayLocationsOnMap:self.homeMapView locations:visibleLocations userFiltering:false];
    }];
}

// Perform segue to view posts at location screen when marker is tapped
- (BOOL)mapView:(GMSMapView *)mapView didTapMarker:(GMSMarker *)marker {
    [self performSegueWithIdentifier:HOME_TO_LOCATION_SEGUE sender:marker];
    return true;
}

// Show newly visible locations once map is moved
- (void)mapView:(GMSMapView *)mapView willMove:(BOOL)gesture {
    [self displayVisibleLocations];
}

- (IBAction)onLogoutTap:(id)sender {
    [PFUser logOutInBackgroundWithBlock:^(NSError * _Nullable error) {
        // PFUser.current() will now be nil
        if (error != nil) {
            [AlertManager displayAlertWithTitle:LOGOUT_ERROR_TITLE text:LOGOUT_ERROR_MESSAGE presenter:self];
        }
        else {
            // After logout, return to login screen
            [AlertManager displayAlertWithTitle:LOGOUT_SUCCESS_TITLE text:LOGOUT_SUCCESS_MESSAGE presenter:self];
            SceneDelegate *sceneDelegate = (SceneDelegate *)self.view.window.windowScene.delegate;

            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:STORYBOARD_NAME bundle:nil];
            LoginViewController *loginViewController = [storyboard instantiateViewControllerWithIdentifier:LOGIN_VIEW_CONTROLLER_IDENTIFIER];
            sceneDelegate.window.rootViewController = loginViewController;
        }
    }];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Bring up location view screen if marker is tapped
    if ([[segue identifier] isEqualToString:HOME_TO_LOCATION_SEGUE]) {
        LocationMarker *marker = sender;
        LocationViewController *locationViewController = [segue destinationViewController];
        locationViewController.location = marker.location;
        locationViewController.isUserFiltered = false;
    }
}

- (IBAction)onRefreshTap:(id)sender {
    [self displayVisibleLocations];
}

@end
