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
#import "AlertManager.h"

@import Parse;

@interface ProfileViewController () <UITabBarControllerDelegate, GMSMapViewDelegate, ImagePickerControllerDelegate>

@property (weak, nonatomic) IBOutlet PFImageView *profilePictureView;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView;
@property (weak, nonatomic) IBOutlet UILabel *friendCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *postCountLabel;
@property (weak, nonatomic) IBOutlet GMSMapView *userMapView;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;
@property (weak, nonatomic) IBOutlet UIButton *friendButton;
@property (weak, nonatomic) IBOutlet UILabel *friendLabel;
@property (weak, nonatomic) IBOutlet UILabel *postLabel;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *requestsButton;

@property (strong, nonatomic) NSDictionary *postsByLocationId;
@property (strong, nonatomic) NSArray *postLocations;
@property (assign, nonatomic) BOOL isEditable;

@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.userMapView.delegate = self;
    if (self.user == nil) {
        self.user = [PFUser currentUser];
        self.isEditable = true;
    }
    else {
        self.isEditable = false;
    }
    
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
    self.friendButton.layer.borderColor = [[UIColor colorWithRed:104/255.0 green:176/255.0 blue:171/255.0 alpha:1.0] CGColor];
    self.friendButton.layer.borderWidth = 1;
}

- (void)changeEditability {
    // If user accessed the profile via the tab bar, it is their own profile and they can edit
    if (self.isEditable) {
        if (self.tabBarController.delegate == nil) {
            self.tabBarController.delegate = self;
        }
        self.saveButton.hidden = false;
        self.descriptionTextView.editable = true;
        self.profilePictureView.userInteractionEnabled = true;
        [self.descriptionTextView resignFirstResponder];
        self.friendButton.hidden = true;
        self.navigationItem.rightBarButtonItem = self.requestsButton;
    }
    else
    {
        self.saveButton.hidden = true;
        self.descriptionTextView.editable = false;
        self.profilePictureView.userInteractionEnabled = false;
        self.navigationItem.rightBarButtonItem = nil;
        
        // Handle friend button visibility/enabled state
        [self.friendButton setTitle:@"Friend" forState: UIControlStateNormal];
        [self.friendButton setTitle:@"Friend Request Sent" forState: UIControlStateSelected];
        if (![self.user.objectId isEqual:[PFUser currentUser].objectId]) {
            self.friendButton.hidden = false;
            NSArray *friendList = [PFUser currentUser][@"friends"];
            NSArray *requestedList = [PFUser currentUser][@"requestsSent"];
            NSArray *pendingList = [PFUser currentUser][@"pendingFriends"];
            if ([pendingList containsObject:self.user.objectId]) {
                [self.friendButton setTitle:@"Respond to Request" forState: UIControlStateSelected];
                self.friendButton.selected = true;
                self.friendButton.userInteractionEnabled = false;
            }
            else {
                self.friendButton.userInteractionEnabled = true;
                if ([friendList containsObject:self.user.objectId]) {
                    [self.friendButton setTitle:@"Already Friends" forState: UIControlStateSelected];
                    self.friendButton.selected = true;
                }
                else if ([requestedList containsObject:self.user.objectId]) {
                    self.friendButton.selected = true;
                }
                else {
                    self.friendButton.selected = false;
                }
            }
        }
        else {
            // hide friend button when the user views their own profile
            self.friendButton.hidden = true;
        }
    }
}

- (IBAction)onFriendTap:(id)sender {
    PFUser *currUser = [PFUser currentUser];
    // Update fields in database
    if (!self.friendButton.selected) {
        // Send friend request if request not yet sent
        [PFCloud callFunctionInBackground:@"sendFriendRequest" withParameters:@{@"userToEditID": self.user.objectId, @"friend": @(true), @"currentUserID": currUser.objectId}];
        [currUser addObject:self.user.objectId forKey:@"requestsSent"];
    }
    else {
        if ([(NSArray *)[PFUser currentUser][@"friends"] containsObject:self.user.objectId]) {
            [PFCloud callFunctionInBackground:@"friendUser" withParameters:@{@"userToEditID": self.user.objectId, @"friend": @(false), @"currentUserID": currUser.objectId}];
            [currUser removeObject:self.user.objectId forKey:@"friends"];
            [self.friendButton setTitle:@"Friend Request Sent" forState: UIControlStateSelected];
        }
        else {
            // Remove friend request if request not yet responded to
            [PFCloud callFunctionInBackground:@"sendFriendRequest" withParameters:@{@"userToEditID": self.user.objectId, @"friend": @(false), @"currentUserID": currUser.objectId}];
            [currUser removeObject:self.user.objectId forKey:@"requestsSent"];
        }
    }
    
    // Update fields locally
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
    NSMutableArray *friendsOfSelf = [PFUser currentUser][@"friends"];
    [friendsOfSelf addObject:[PFUser currentUser].objectId];
    if (![friendsOfSelf containsObject:self.user.objectId]) {
        // If this profile's user is not friends with the current user, only display public posts
        [query whereKey:@"private" equalTo:[NSNumber numberWithBool:false]];
    }
    
    // Fetch posts of user from database
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable posts, NSError * _Nullable error) {
        if (error != nil) {
            [AlertManager displayAlertWithTitle:@"Error Retrieving Posts" text:@"Could not fetch posts from server" presenter:self];
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
        self.isEditable = true;
        self.user = [PFUser currentUser];
        [self updateFields];
    }
}

// Save currently selected description and profile picture to database
- (IBAction)onSaveTap:(id)sender {
    self.user[@"tagline"] = self.descriptionTextView.text;
    self.user[@"profilePicture"] = [Post getPFFileFromImage:self.profilePictureView.image];
    [self.user saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        [self updateFields];
        [AlertManager displayAlertWithTitle:@"Save Successful" text:@"Profile has been saved successfully" presenter:self];
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

- (IBAction)onRequestsTap:(id)sender {
    [self performSegueWithIdentifier:@"friendRequestSegue" sender:nil];
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
