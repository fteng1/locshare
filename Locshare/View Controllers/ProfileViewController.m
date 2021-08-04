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
#import "Constants.h"

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
    GMSCameraPosition *camera = [ProjectLocations defaultLocation];
    [self.userMapView setCamera:camera];
}

- (void)initializeUI {
    // Make profile image circular
    self.profilePictureView.layer.cornerRadius = self.profilePictureView.frame.size.height / PROFILE_PICTURE_CORNER_RADIUS_RATIO;
    self.profilePictureView.layer.masksToBounds = MASKS_TO_BOUNDS;
    
    // Round borders of friend button
    self.friendButton.layer.cornerRadius = BUTTON_CORNER_RADIUS;
    self.friendButton.layer.masksToBounds = MASKS_TO_BOUNDS;
    self.friendButton.layer.borderColor = [ProjectColors tintColor];
    self.friendButton.layer.borderWidth = BUTTON_BORDER_WIDTH;
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
        
        [self setFriendButtonDisplay];
    }
}

- (void)setFriendButtonDisplay {
    // Handle friend button visibility/enabled state
    [self.friendButton setTitle:FRIEND_BUTTON_TITLE_DEFAULT forState: UIControlStateNormal];
    [self.friendButton setTitle:FRIEND_BUTTON_REQUEST_SENT forState: UIControlStateSelected];
    if (![self.user.objectId isEqual:[PFUser currentUser].objectId]) {
        self.friendButton.hidden = false;
        NSArray *friendList = [PFUser currentUser][USER_FRIENDS_KEY];
        NSArray *requestedList = [PFUser currentUser][USER_REQUESTS_SENT_KEY];
        NSArray *pendingList = [PFUser currentUser][USER_PENDING_FRIENDS_KEY];
        if ([pendingList containsObject:self.user.objectId]) {
            [self.friendButton setTitle:FRIEND_BUTTON_RESPOND_TO_REQUEST forState: UIControlStateSelected];
            self.friendButton.selected = true;
            self.friendButton.userInteractionEnabled = false;
        }
        else {
            self.friendButton.userInteractionEnabled = true;
            if ([friendList containsObject:self.user.objectId]) {
                [self.friendButton setTitle:FRIEND_BUTTON_ALREADY_FRIENDS forState: UIControlStateSelected];
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

- (IBAction)onFriendTap:(id)sender {
    PFUser *currUser = [PFUser currentUser];
    // Update fields in database
    if (!self.friendButton.selected) {
        // Send friend request if request not yet sent
        [PFCloud callFunctionInBackground:CLOUD_CODE_SEND_FRIEND_REQUEST_FUNCTION withParameters:@{CLOUD_CODE_USER_TO_EDIT_KEY: self.user.objectId, CLOUD_CODE_FRIEND_KEY: @(true), CLOUD_CODE_CURRENT_USER_KEY: currUser.objectId}];
        [currUser addObject:self.user.objectId forKey:USER_REQUESTS_SENT_KEY];
    }
    else {
        if ([(NSArray *)[PFUser currentUser][USER_FRIENDS_KEY] containsObject:self.user.objectId]) {
            [PFCloud callFunctionInBackground:CLOUD_CODE_FRIEND_USER_FUNCTION withParameters:@{CLOUD_CODE_USER_TO_EDIT_KEY: self.user.objectId, CLOUD_CODE_FRIEND_KEY: @(false), CLOUD_CODE_CURRENT_USER_KEY: currUser.objectId}];
            [currUser removeObject:self.user.objectId forKey:USER_FRIENDS_KEY];
            [currUser incrementKey:USER_NUM_FRIENDS_KEY byAmount:[ProjectNumbers negativeOne]];
            [self updateUserValues];
        }
        else {
            // Remove friend request if request not yet responded to
            [PFCloud callFunctionInBackground:CLOUD_CODE_SEND_FRIEND_REQUEST_FUNCTION withParameters:@{CLOUD_CODE_USER_TO_EDIT_KEY: self.user.objectId, CLOUD_CODE_FRIEND_KEY: @(false), CLOUD_CODE_CURRENT_USER_KEY: currUser.objectId}];
            [currUser removeObject:self.user.objectId forKey:USER_REQUESTS_SENT_KEY];
        }
    }
    
    // Update fields locally
    self.friendButton.selected = !self.friendButton.selected;
    [self setFriendButtonDisplay];
    [self updateFields];
    
    [currUser saveInBackground];
}

- (void)updateUserValues {
    // Get new information about the user from the database
    [self.user fetchInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
        if (error) {
            [AlertManager displayAlertWithTitle:UPDATE_USER_ERROR_TITLE text:UPDATE_USER_ERROR_MESSAGE presenter:self];
        }
        else {
            [self updateFields];
            [self setFriendButtonDisplay];
        }
    }];
    [[PFUser currentUser] fetchInBackground];
}

- (void)updateFields {
    // Set text fields to user's current values
    self.usernameLabel.text = self.user.username;
    self.descriptionTextView.text = self.user[USER_TAGLINE_KEY];
    self.friendCountLabel.text = [NSString stringWithFormat:OBJECT_STRING, self.user[USER_NUM_FRIENDS_KEY]];
    // Check if text should be plural or singular
    if ([self.user[USER_NUM_FRIENDS_KEY] isEqual:[ProjectNumbers one]]) {
        self.friendLabel.text = FRIEND_LABEL_SINGULAR;
    }
    else {
        self.friendLabel.text = FRIEND_LABEL_PLURAL;
    }
    self.postCountLabel.text = [NSString stringWithFormat:OBJECT_STRING, self.user[USER_NUM_POSTS_KEY]];
    if ([self.user[USER_NUM_POSTS_KEY] isEqual:[ProjectNumbers one]]) {
        self.postLabel.text = POST_LABEL_SINGULAR;
    }
    else {
        self.postLabel.text = POST_LABEL_PLURAL;
    }
    
    // Load profile picture
    PFFileObject *imageToDisplay = self.user[USER_PROFILE_PICTURE_KEY];
    self.profilePictureView.image = [UIImage systemImageNamed:DEFAULT_PROFILE_PICTURE_NAME];
    self.profilePictureView.file = imageToDisplay;
    [self.profilePictureView loadInBackground];
}

- (void)fetchPosts {
    PFQuery *query = [PFQuery queryWithClassName:POST_PARSE_CLASS_NAME];
    [query whereKey:POST_AUTHOR_KEY equalTo:self.user];
    [query orderByDescending:POST_CREATED_AT_KEY];
    NSMutableArray *friendsOfSelf = [PFUser currentUser][USER_FRIENDS_KEY];
    [friendsOfSelf addObject:[PFUser currentUser].objectId];
    if (![friendsOfSelf containsObject:self.user.objectId]) {
        // If this profile's user is not friends with the current user, only display public posts
        [query whereKey:POST_PRIVATE_KEY equalTo:[NSNumber numberWithBool:false]];
    }
    
    // Fetch posts of user from database
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable posts, NSError * _Nullable error) {
        if (error != nil) {
            [AlertManager displayAlertWithTitle:RETRIEVING_POSTS_ERROR_TITLE text:RETRIEVING_POSTS_ERROR_MESSAGE presenter:self];
        }
        else {
            if ([posts count] >= 1) {
                Post *mostRecentPost = [posts firstObject];
                NSMutableArray *locationIds = [[NSMutableArray alloc] init];
                for (Post *post in posts) {
                    if (![locationIds containsObject:post.location]) {
                        [locationIds addObject:post.location];
                    }
                }
                
                // Fetch relevant locations from database
                PFQuery *locQuery = [PFQuery queryWithClassName:LOCATION_PARSE_CLASS_NAME];
                [locQuery whereKey:LOCATION_PLACE_ID_KEY containedIn:locationIds];
                [locQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable locations, NSError * _Nullable error) {
                    self.postLocations = locations;
                    self.postsByLocationId = [self groupByLocation:posts];
                    [self.userMapView clear];
                    [[LocationManager shared] displayLocationsOnMap:self.userMapView locations:locations userFiltering:true];
                    
                    // Set camera to be at location of most recent post
                    NSArray *filteredLocation = [self.postLocations filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:MOST_RECENT_POST_PREDICATE, mostRecentPost.location]];
                    if ([filteredLocation count] > 0) {
                        Location *mostRecentLocation = [filteredLocation firstObject];
                        GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:mostRecentLocation.coordinate.latitude longitude:mostRecentLocation.coordinate.longitude zoom:MAP_FEED_DEFAULT_ZOOM];
                        [self.userMapView setCamera:camera];
                    }
                }];
            }
        }
    }];
}

- (NSDictionary *)groupByLocation:(NSArray *)posts {
    // Get all distinct place IDs
    NSArray *postGroups = [posts valueForKeyPath:GROUP_POSTS_KEY_PATH];
    NSMutableDictionary *groupedById = [[NSMutableDictionary alloc] init];
    
    // Get array of posts with the given place ID and create a key-value pair in the dictionary
    for (NSString *placeID in postGroups) {
        NSArray *postsAtPlace = [posts filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:POSTS_AT_LOCATION_PREDICATE, placeID]];
        [groupedById setObject:postsAtPlace forKey:placeID];
    }
    return groupedById;
}

// Perform segue to view posts at location screen when marker is tapped
- (BOOL)mapView:(GMSMapView *)mapView didTapMarker:(GMSMarker *)marker {
    [self performSegueWithIdentifier:PROFILE_TO_LOCATION_SEGUE sender:marker];
    return true;
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
    // If user goes to this screen via the tab bar, the page displays the current user profile
    if ([tabBarController.viewControllers indexOfObject:viewController] == PROFILE_TAB_INDEX) {
        self.isEditable = true;
        self.user = [PFUser currentUser];
        [self updateFields];
    }
}

// Save currently selected description and profile picture to database
- (IBAction)onSaveTap:(id)sender {
    self.user[USER_TAGLINE_KEY] = self.descriptionTextView.text;
    self.user[USER_PROFILE_PICTURE_KEY] = [Post getPFFileFromImage:self.profilePictureView.image];
    [self.user saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        [self updateFields];
        [AlertManager displayAlertWithTitle:SAVE_SUCCESSFUL_TITLE text:SAVE_SUCCESSFUL_MESSAGE presenter:self];
    }];
    [self.descriptionTextView resignFirstResponder];
}

- (IBAction)onProfilePictureTap:(id)sender {
    [self performSegueWithIdentifier:CHOOSE_PROFILE_PHOTO_SEGUE sender:nil];
}

- (void)didFinishPicking:(NSArray *)images {
    self.profilePictureView.image = [images firstObject];
}

- (IBAction)onRefreshTap:(id)sender {
    [self updateUserValues];
    [self fetchPosts];
}

- (IBAction)onRequestsTap:(id)sender {
    [self performSegueWithIdentifier:PROFILE_TO_FRIEND_REQUESTS_SEGUE sender:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Bring up location view screen if marker is tapped
    if ([[segue identifier] isEqualToString:PROFILE_TO_LOCATION_SEGUE]) {
        LocationMarker *marker = sender;
        LocationViewController *locationViewController = [segue destinationViewController];
        locationViewController.location = marker.location;
        locationViewController.postsToDisplay = self.postsByLocationId[marker.location.placeID];
        locationViewController.userToFilter = self.user;
        locationViewController.isUserFiltered = marker.userFiltered;
    }
    // Bring up image picker screen if profile picture is tapped
    if ([[segue identifier] isEqualToString:CHOOSE_PROFILE_PHOTO_SEGUE]) {
        ImagePickerViewController *imagePicker = [segue destinationViewController];
        imagePicker.delegate = self;
        imagePicker.useCamera = false;
        imagePicker.limitSelection = MAX_NUM_PROFILE_PHOTO_SELECTION;
    }
}

@end
