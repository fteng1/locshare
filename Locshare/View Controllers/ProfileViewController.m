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
#import "ImageManager.h"
@import Parse;

@interface ProfileViewController () <UITabBarControllerDelegate, GMSMapViewDelegate, UIImagePickerControllerDelegate>

@property (weak, nonatomic) IBOutlet PFImageView *profilePictureView;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView;
@property (weak, nonatomic) IBOutlet UILabel *friendCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *postCountLabel;
@property (weak, nonatomic) IBOutlet GMSMapView *userMapView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveButton;
@property (weak, nonatomic) IBOutlet UIButton *friendButton;

@property (strong, nonatomic) NSDictionary *postsByLocationId;
@property (strong, nonatomic) NSArray *postLocations;

@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.userMapView.delegate = self;
    
    // If user accessed the profile via the tab bar, it is their own profile and they can edit
    if ([self profileIsEditable]) {
        if (self.tabBarController.delegate == nil) {
            self.tabBarController.delegate = self;
        }
        self.user = [PFUser currentUser];
        self.saveButton.title = @"Save";
        self.saveButton.enabled = true;
        self.descriptionTextView.editable = true;
        self.profilePictureView.userInteractionEnabled = true;
        [self.descriptionTextView resignFirstResponder];
        self.friendButton.hidden = true;
    }
    else
    {
        self.saveButton.title = @"";
        self.saveButton.enabled = false;
        self.descriptionTextView.editable = false;
        self.profilePictureView.userInteractionEnabled = false;
        
        // Handle friend button visibility/enabled state
        [self.friendButton setTitle:@"Already Friends" forState: UIControlStateSelected];
        [self.friendButton setTitle:@"Friend" forState: UIControlStateNormal];
        if (![self.user.objectId isEqual:[PFUser currentUser].objectId]) {
            self.friendButton.hidden = false;
            NSArray *friendList = [PFUser currentUser][@"friends"];
            if ([friendList containsObject:self.user.objectId]) {
                self.friendButton.selected = true;
            }
            else {
                self.friendButton.selected = false;
            }
        }
        else {
            self.friendButton.hidden = true;
        }
    }
    [self updateFields];
    [self fetchPosts];
}

- (IBAction)onFriendTap:(id)sender {
    PFUser *currUser = [PFUser currentUser];
    if (!self.friendButton.selected) {
        [self.user addObject:currUser.objectId forKey:@"friends"];
        [self.user incrementKey:@"numFriends"];
        [currUser addObject:self.user.objectId forKey:@"friends"];
        [currUser incrementKey:@"numFriends"];
    }
    else {
        [self.user removeObject:currUser.objectId forKey:@"friends"];
        [self.user incrementKey:@"numFriends" byAmount:@(-1)];
        [currUser removeObject:self.user.objectId forKey:@"friends"];
        [currUser incrementKey:@"numFriends" byAmount:@(-1)];
    }
    self.friendButton.selected = !self.friendButton.selected;
    [[PFUser currentUser] saveInBackground];
    [self.user saveInBackground];
}

- (void)updateFields {
    // Set text fields to user's current values
    self.usernameLabel.text = self.user.username;
    self.descriptionTextView.text = self.user[@"tagline"];
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
    [query whereKey:@"author" equalTo:self.user];
    [query orderByDescending:@"createdAt"];
    
    // Fetch posts of user from database
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable posts, NSError * _Nullable error) {
        if (error != nil) {
            NSLog(@"Error retrieving posts: %@", error);
        }
        else {
            if ([posts count] >= 1) {
                Post *mostRecentPost = posts[0];
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
                    [self.userMapView clear];
                    [[LocationManager shared] displayLocationsOnMap:self.userMapView locations:locations];
                    
                    // Set camera to be at location of most recent post
                    Location *mostRecentLocation = [self.postLocations filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"placeID like %@", mostRecentPost.location]][0];
                    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:mostRecentLocation.coordinate.latitude longitude:mostRecentLocation.coordinate.longitude zoom:10.0];
                    [self.userMapView setCamera:camera];
                }];
            }
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

- (BOOL)profileIsEditable {
    return self.tabBarController.selectedIndex == 3;
}

// Save currently selected description and profile picture to database
- (IBAction)onSaveTap:(id)sender {
    self.user[@"tagline"] = self.descriptionTextView.text;
    self.user[@"profilePicture"] = [Post getPFFileFromImage:self.profilePictureView.image];
    [self.user saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        [self updateFields];
    }];
    [self.descriptionTextView resignFirstResponder];
}

- (void)dismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion {
}

- (IBAction)onProfilePictureTap:(id)sender {
    ImageManager *imagePicker = [ImageManager new];
    imagePicker.viewToSet = self.profilePictureView;
    [self presentViewController:imagePicker animated:YES completion:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Bring up location view screen if marker is tapped
    if ([[segue identifier] isEqualToString:@"profileLocationSegue"]) {
        LocationMarker *marker = sender;
        LocationViewController *locationViewController = [segue destinationViewController];
        locationViewController.location = marker.location;
        locationViewController.postsToDisplay = self.postsByLocationId[marker.location.placeID];
        locationViewController.userToFilter = self.user;
        locationViewController.isUserFiltered = true;
    }
}

@end
