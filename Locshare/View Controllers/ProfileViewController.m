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
#import "ImagePickerViewController.h"
@import Parse;

@interface ProfileViewController () <UITabBarControllerDelegate, GMSMapViewDelegate, ImagePickerControllerDelegate>

@property (weak, nonatomic) IBOutlet PFImageView *profilePictureView;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView;
@property (weak, nonatomic) IBOutlet UILabel *friendCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *postCountLabel;
@property (weak, nonatomic) IBOutlet GMSMapView *userMapView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveButton;
@property (weak, nonatomic) IBOutlet UIButton *friendButton;
@property (weak, nonatomic) IBOutlet UILabel *friendLabel;
@property (weak, nonatomic) IBOutlet UILabel *postLabel;

@property (strong, nonatomic) NSDictionary *postsByLocationId;
@property (strong, nonatomic) NSArray *postLocations;

@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.userMapView.delegate = self;
    
    [self setDefaultMapLocation];
    [self initializeUI];
    [self changeEditability];
    [self updateFields];
    [self fetchPosts];
}

- (void)setDefaultMapLocation {
    // Set default location of map to be the center of the US
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:40.745028 longitude:-100.657394 zoom:1.0];
    [self.userMapView setCamera:camera];
}

- (void)initializeUI {
    // Make profile image circular
    self.profilePictureView.layer.cornerRadius = self.profilePictureView.frame.size.height / 2;;
    self.profilePictureView.layer.masksToBounds = true;
    
    // Round borders of friend button
    self.friendButton.layer.cornerRadius = 5;
    self.friendButton.layer.masksToBounds = true;
}

- (void)changeEditability {
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
}

- (IBAction)onFriendTap:(id)sender {
    PFUser *currUser = [PFUser currentUser];
    NSNumber *incrementFriendAmount = @(1);
    if (!self.friendButton.selected) {
        [PFCloud callFunctionInBackground:@"friendUser" withParameters:@{@"userToEditID": self.user.objectId, @"friend": @(true), @"currentUserID": currUser.objectId}];
        [currUser addObject:self.user.objectId forKey:@"friends"];
    }
    else {
        [PFCloud callFunctionInBackground:@"friendUser" withParameters:@{@"userToEditID": self.user.objectId, @"friend": @(false), @"currentUserID": currUser.objectId}];
        incrementFriendAmount = @(-1);
        [currUser removeObject:self.user.objectId forKey:@"friends"];
    }
    
    // Update fields locally
    [self.user incrementKey:@"numFriends" byAmount:incrementFriendAmount];
    [currUser incrementKey:@"numFriends" byAmount:incrementFriendAmount];
    self.friendButton.selected = !self.friendButton.selected;
    [self updateFields];
    
    [currUser saveInBackground];
}

- (void)updateFields {
    // Set text fields to user's current values
    self.usernameLabel.text = self.user.username;
    self.descriptionTextView.text = self.user[@"tagline"];
    self.friendCountLabel.text = [NSString stringWithFormat:@"%@", self.user[@"numFriends"]];
    // Check if text should be plural or singular
    if ([self.friendCountLabel.text isEqual:@"1"]) {
        self.friendLabel.text = @"friend";
    }
    else {
        self.friendLabel.text = @"friends";
    }
    self.postCountLabel.text = [NSString stringWithFormat:@"%@", self.user[@"numPosts"]];
    if ([self.postCountLabel.text isEqual:@"1"]) {
        self.postLabel.text = @"post";
    }
    else {
        self.postLabel.text = @"posts";
    }
    
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
                    [[LocationManager shared] displayLocationsOnMap:self.userMapView locations:locations userFiltering:true];
                    
                    // Set camera to be at location of most recent post
                    NSArray *filteredLocation = [self.postLocations filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"placeID like %@", mostRecentPost.location]];
                    if ([filteredLocation count] > 0) {
                        Location *mostRecentLocation = filteredLocation[0];
                        GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:mostRecentLocation.coordinate.latitude longitude:mostRecentLocation.coordinate.longitude zoom:10.0];
                        [self.userMapView setCamera:camera];
                    }
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

- (IBAction)onProfilePictureTap:(id)sender {
    [self performSegueWithIdentifier:@"chooseProfileSegue" sender:nil];
}

- (void)didFinishPicking:(NSArray *)images {
    self.profilePictureView.image = [images firstObject];
}

- (IBAction)onRefreshTap:(id)sender {
    [self updateFields];
    [self fetchPosts];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Bring up location view screen if marker is tapped
    if ([[segue identifier] isEqualToString:@"profileLocationSegue"]) {
        LocationMarker *marker = sender;
        LocationViewController *locationViewController = [segue destinationViewController];
        locationViewController.location = marker.location;
        locationViewController.postsToDisplay = self.postsByLocationId[marker.location.placeID];
        locationViewController.userToFilter = self.user;
        locationViewController.isUserFiltered = marker.userFiltered;
    }
    // Bring up image picker screen if profile picture is tapped
    if ([[segue identifier] isEqualToString:@"chooseProfileSegue"]) {
        ImagePickerViewController *imagePicker = [segue destinationViewController];
        imagePicker.delegate = self;
        imagePicker.useCamera = false;
        imagePicker.limitSelection = 1;
    }
}

@end
