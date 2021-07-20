//
//  ProfileViewController.m
//  Locshare
//
//  Created by Felianne Teng on 7/12/21.
//

#import "ProfileViewController.h"
#import "SceneDelegate.h"
#import "LoginViewController.h"
#import <GoogleMaps/GoogleMaps.h>
#import "Post.h"
#import "LocationManager.h"
#import "LocationMarker.h"
#import "LocationViewController.h"
@import Parse;

@interface ProfileViewController () <UITabBarControllerDelegate, GMSMapViewDelegate>

@property (weak, nonatomic) IBOutlet PFImageView *profilePictureView;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *friendCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *postCountLabel;
@property (weak, nonatomic) IBOutlet GMSMapView *userMapView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *editButton;

@property (strong, nonatomic) NSDictionary *postsByLocationId;
@property (strong, nonatomic) NSArray *postLocations;

@end

@implementation ProfileViewController

// sets initial value for accessed property
- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super initWithCoder:decoder];
    if (self) {
        self.firstAccessedFromTab = true;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.userMapView.delegate = self;
    
    if (self.tabBarController.delegate == nil && self.firstAccessedFromTab) {
        self.tabBarController.delegate = self;
        self.user = [PFUser currentUser];
    }
    
    [self fetchPosts];
    [self updateFields];
}

- (void)updateFields {
    // Set text fields to user's current values
    self.usernameLabel.text = self.user.username;
    self.descriptionLabel.text = self.user[@"tagline"];
    self.friendCountLabel.text = [NSString stringWithFormat:@"%@", self.user[@"numFriends"]];
    self.postCountLabel.text = [NSString stringWithFormat:@"%@", self.user[@"numPosts"]];
    
    // Load profile picture
    PFFileObject *imageToDisplay = self.user[@"profilePicture"];
    self.profilePictureView.image = [UIImage systemImageNamed:@"photo"];
    self.profilePictureView.file = imageToDisplay;
    [self.profilePictureView loadInBackground];
}

- (void)fetchPosts {
    PFQuery *query = [PFQuery queryWithClassName:@"Post"];
    [query whereKey:@"objectId" containedIn:self.user[@"posts"]];
    
    // Fetch posts of user from database
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable posts, NSError * _Nullable error) {
        if (error != nil) {
            NSLog(@"Error retrieving posts: %@", error);
        }
        else {
            NSMutableArray *locationIds = [[NSMutableArray alloc] init];
            for (Post *post in posts) {
                if (![locationIds containsObject:post.location]) {
                    [locationIds addObject:post.location];
                }
            }
            
            // Fetch relevant locations from database
            PFQuery *locQuery = [PFQuery queryWithClassName:@"Location"];
            [locQuery whereKey:@"placeID" containedIn:locationIds];
            [locQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable locations, NSError * _Nullable error) {
                self.postLocations = locations;
                self.postsByLocationId = [self groupByLocation:posts];
                [[LocationManager shared] displayLocationsOnMap:self.userMapView locations:locations];
            }];
        }
    }];
}

- (NSDictionary *)groupByLocation:(NSArray *)posts {
    // Get all distinct place IDs
    NSArray *postGroups = [posts valueForKeyPath:@"@distinctUnionOfObjects.location"];
    NSMutableDictionary *groupedById = [[NSMutableDictionary alloc] init];
    
    // Get array of posts with the given place ID and create a key-value pair in the dictionary
    for (NSString *placeID in postGroups) {
        NSArray *postsAtPlace = [posts filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"location like %@", placeID]];
        [groupedById setObject:postsAtPlace forKey:placeID];
    }
    return groupedById;
}

// Perform segue to view posts at location screen when marker is tapped
- (BOOL)mapView:(GMSMapView *)mapView didTapMarker:(GMSMarker *)marker {
    [self performSegueWithIdentifier:@"profileLocationSegue" sender:marker];
    return true;
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
    // If user goes to this screen via the tab bar, the page displays the current user profile
    if ([tabBarController.viewControllers indexOfObject:viewController] == 3) {
        self.user = [PFUser currentUser];
        [self updateFields];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Bring up location view screen if marker is tapped
    if ([[segue identifier] isEqualToString:@"profileLocationSegue"]) {
        LocationMarker *marker = sender;
        LocationViewController *locationViewController = [segue destinationViewController];
        locationViewController.location = marker.location;
        locationViewController.postsToDisplay = self.postsByLocationId[marker.location.placeID];
        locationViewController.userToFilter = self.user;
    }
}

@end
