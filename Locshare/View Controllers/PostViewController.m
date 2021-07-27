//
//  PostViewController.m
//  Locshare
//
//  Created by Felianne Teng on 7/12/21.
//

#import "PostViewController.h"
#import <UITextView_Placeholder/UITextView+Placeholder.h>
#import "Post.h"
#import "LocationAutocompleteCell.h"
#import "Location.h"
#import <QBImagePickerController/QBImagePickerController.h>
#import "PhotoViewCell.h"
#import "LocationManager.h"
#import "ImageManager.h"
#import "ImagePickerViewController.h"

@interface PostViewController () <ImagePickerControllerDelegate, UIImagePickerControllerDelegate, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UICollectionViewDelegate, UICollectionViewDataSource>

@property (weak, nonatomic) IBOutlet UISearchBar *locationSearchBar;
@property (weak, nonatomic) IBOutlet UICollectionView *pickedPhotosCollectionView;
@property (weak, nonatomic) IBOutlet UITextView *captionTextView;
@property (weak, nonatomic) IBOutlet UITableView *autocompleteTableView;

@property (strong, nonatomic) NSArray *autocompleteResults;
@property (strong, nonatomic) NSString *locationID;
@property (strong, nonatomic) NSArray *photosToUpload;
@property (nonatomic, strong) PHImageRequestOptions *requestOptions;
@property (strong, nonatomic) UIImageView *storageView;

@end

@implementation PostViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Initialize view controller
    self.autocompleteTableView.delegate = self;
    self.autocompleteTableView.dataSource = self;
    self.locationSearchBar.delegate = self;
    self.captionTextView.placeholder = @"Write a caption...";
    self.photosToUpload = [[NSMutableArray alloc] init];
    
    [self configureRequestOptions];
    
    // Initialize CollectionView
    self.pickedPhotosCollectionView.delegate = self;
    self.pickedPhotosCollectionView.dataSource = self;
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *) self.pickedPhotosCollectionView.collectionViewLayout;
    layout.minimumInteritemSpacing = 1;
    layout.minimumLineSpacing = 1;
    
    [self.pickedPhotosCollectionView reloadData];
    self.storageView = [UIImageView new];
}

- (void)configureRequestOptions {
    // Options for making requests regarding PHImages
    self.requestOptions = [[PHImageRequestOptions alloc] init];
    self.requestOptions.resizeMode = PHImageRequestOptionsResizeModeExact;
    self.requestOptions.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    // Makes calls to requestOptions synchronous
    self.requestOptions.synchronous = YES;
}

// Take photo using the phone camera when the camera icon is tapped, if available
- (IBAction)onCameraTap:(id)sender {
    ImageManager *imagePicker = [ImageManager new];
    imagePicker.viewToSet = self.storageView;
    [self setDefinesPresentationContext:YES];
    imagePicker.modalPresentationStyle = UIModalPresentationCurrentContext;
    [self presentViewController:imagePicker animated:YES completion:nil];
}

// Choose multiple photos from the photo library
- (IBAction)onPhotoLibraryTap:(id)sender {
    [self performSegueWithIdentifier:@"imagePickerSegue" sender:nil];
}

// Make post when share button is pressed
- (IBAction)shareButton:(id)sender {
    if (self.locationSearchBar.text.length != 0) {
        Post *newPost = [Post initPost:self.photosToUpload withCaption:self.captionTextView.text withLocation:self.locationID];
            // Make new post with the given location ID
            [Post makePost:newPost completion:^(NSString * userPostID, NSError * _Nullable error) {
                if (error != nil) {
                    NSLog(@"Post share failed: %@", error.localizedDescription);
                }
                else {
                    NSLog(@"Post shared successfully");
                    [Location tagLocation:self.locationID newPost:userPostID completion:^(NSError * _Nonnull error) {
                        if (error != nil) {
                            NSLog(@"Location tag failed: %@", error.localizedDescription);
                        }
                    }];
                    PFUser *currentUser = [PFUser currentUser];
                    [currentUser incrementKey:@"numPosts"];
                    [currentUser saveInBackground];
                }
            }];
        [self performSegueWithIdentifier:@"afterPostSegue" sender:nil];
    }
    else {
        // Make alert for when no location is inputted
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Cannot Make Post" message:@"User must select a valid location to make a post" preferredStyle:(UIAlertControllerStyleAlert)];
        // create an OK action
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {}];
        // add the OK action to the alert controller
        [alert addAction:okAction];
        [self presentViewController:alert animated:YES completion:^{}];
    }
}

- (void)getSuggestedLocations:(NSString *)searchQuery {
    [[LocationManager shared] getSuggestedLocations:searchQuery completion:^(NSArray * _Nonnull results, NSError * _Nonnull error) {
        if (error == nil) {
            self.autocompleteResults = results;
            [self.autocompleteTableView reloadData];
        }
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.autocompleteResults count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LocationAutocompleteCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LocationAutocompleteCell"];
    
    // List name of suggested location in the cell
    NSDictionary *loc = self.autocompleteResults[indexPath.row];
    if (loc[@"description"] != nil) {
        cell.locationLabel.text = loc[@"description"];
    }
    else {
        cell.locationLabel.text = loc[@"name"];
    }
    return cell;
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    // Let user cancel once a location is being searched
    searchBar.showsCancelButton = YES;
    
    // Initially show locations close to the user
    self.autocompleteTableView.hidden = false;
    [[LocationManager shared] getNearbyLocations:^(NSArray * _Nonnull nearby, NSError * _Nonnull error) {
        self.autocompleteResults = nearby;
        [self.autocompleteTableView reloadData];
    }];

}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    // Dismiss search term once cancel is pressed
    searchBar.showsCancelButton = NO;
    self.autocompleteTableView.hidden = true;
    [searchBar resignFirstResponder];
}

// Upon tapping search, display the suggested results from Place API
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    searchBar.showsCancelButton = NO;
    
    // Show autocompleted results
    if (searchBar.text.length != 0) {
        self.autocompleteTableView.hidden = false;
        [self getSuggestedLocations:searchBar.text];
    }
    [searchBar resignFirstResponder];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Once a suggested location is selected, update text in search bar
    if (self.autocompleteResults[indexPath.row][@"description"] != nil) {
        self.locationSearchBar.text = self.autocompleteResults[indexPath.row][@"description"];
    }
    else {
        self.locationSearchBar.text = self.autocompleteResults[indexPath.row][@"name"];
    }
    self.locationID = self.autocompleteResults[indexPath.row][@"place_id"];
    self.autocompleteTableView.hidden = true;
    self.locationSearchBar.showsCancelButton = NO;
}

- (IBAction)dismissKeyboard:(id)sender {
    // after typing in the caption text view, tapping anywhere in the view dismisses the keyboard
    [self.captionTextView resignFirstResponder];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSInteger numItems = [self.photosToUpload count];
    // Always display at least one item to show default image
    if (numItems == 0) {
        return 1;
    }
    else {
        return numItems;
    }
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    // Set image for given cell
    PhotoViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PhotoViewCell" forIndexPath:indexPath];
    if ([self.photosToUpload count] != 0) {
        cell.photoImageView.image = self.photosToUpload[indexPath.item];
    }
    return cell;
}

- (void)didFinishPicking:(NSArray *)images {
    self.photosToUpload = images;
    [self.pickedPhotosCollectionView reloadData];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Bring up image picker view if photo or camera button is pressed
    if ([[segue identifier] isEqualToString:@"imagePickerSegue"] || [[segue identifier] isEqualToString:@"cameraSegue"]) {
        ImagePickerViewController *imagePickerController = [segue destinationViewController];
        imagePickerController.delegate = self;
        if ([[segue identifier] isEqualToString:@"cameraSegue"]) {
            imagePickerController.useCamera = true;
        }
        else {
            imagePickerController.useCamera = false;
        }
    }
}

@end
