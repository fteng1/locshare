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
    
    // If user accessed the profile via the tab bar, it is their own profile and they can edit
    if ([self profileIsEditable]) {
        self.saveButton.title = @"Save";
        self.saveButton.enabled = true;
        self.descriptionTextView.editable = true;
        self.profilePictureView.userInteractionEnabled = true;
    }
    else
    {
        self.saveButton.title = @"";
        self.saveButton.enabled = false;
        self.descriptionTextView.editable = false;
        self.profilePictureView.userInteractionEnabled = false;
    }
    [self fetchPosts];
    [self updateFields];
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
    [query whereKey:@"objectId" containedIn:self.user[@"posts"]];
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
                    [[LocationManager shared] displayLocationsOnMap:self.userMapView locations:locations];
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

- (IBAction)onProfilePictureTap:(id)sender {
    UIImagePickerController *imagePicker = [UIImagePickerController new];
    imagePicker.delegate = self;
    imagePicker.allowsEditing = YES;
    
    // The Xcode simulator does not support taking pictures, so let's first check that the camera is indeed supported on the device before trying to present it.
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    }
    else {
        NSLog(@"The camera is not available");
    }
    [self presentViewController:imagePicker animated:YES completion:nil];
}

// Use when camera is used to take photo, can only choose one photo
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey,id> *)info {
    // Get the image captured by the UIImagePickerController
    UIImage *editedImage = info[UIImagePickerControllerEditedImage];
    editedImage = [[ImageManager shared] resizeImage:editedImage withSize:CGSizeMake(400, 300)];
    self.profilePictureView.image = editedImage;
    
    // Dismiss UIImagePickerController to go back to your original view controller
    [self dismissViewControllerAnimated:YES completion:nil];
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
