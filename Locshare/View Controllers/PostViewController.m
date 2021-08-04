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
#import "PhotoViewCell.h"
#import "LocationManager.h"
#import "ImageManager.h"
#import "ImagePickerViewController.h"
#import "AlertManager.h"
#import "Constants.h"

@interface PostViewController () <ImagePickerControllerDelegate, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UICollectionViewDelegate, UICollectionViewDataSource>

@property (weak, nonatomic) IBOutlet UISearchBar *locationSearchBar;
@property (weak, nonatomic) IBOutlet UICollectionView *pickedPhotosCollectionView;
@property (weak, nonatomic) IBOutlet UITextView *captionTextView;
@property (weak, nonatomic) IBOutlet UITableView *autocompleteTableView;
@property (weak, nonatomic) IBOutlet UIImageView *mapImage;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *searchBarLeadingConstraint;
@property (weak, nonatomic) IBOutlet UISwitch *privateSwitch;
@property (weak, nonatomic) IBOutlet UIImageView *lockImageView;

@property (strong, nonatomic) NSArray *autocompleteResults;
@property (strong, nonatomic) NSString *locationID;
@property (strong, nonatomic) NSArray *photosToUpload;
@property (strong, nonatomic) UIImageView *storageView;

@end

@implementation PostViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Initialize view controller
    self.autocompleteTableView.delegate = self;
    self.autocompleteTableView.dataSource = self;
    self.locationSearchBar.delegate = self;
    self.captionTextView.placeholder = CAPTION_PLACEHOLDER_TEXT;
    self.photosToUpload = [[NSArray alloc] init];
        
    // Initialize CollectionView
    self.pickedPhotosCollectionView.delegate = self;
    self.pickedPhotosCollectionView.dataSource = self;
    [self setCollectionViewLayout];
    
    [self initializeUI];
    
    [self.pickedPhotosCollectionView reloadData];
    self.storageView = [UIImageView new];
}

- (void)initializeUI {
    // Change color of search bar
    self.locationSearchBar.searchTextField.backgroundColor = [ProjectColors tanBackgroundColor];
    [self.locationSearchBar setSearchFieldBackgroundImage:[UIImage new] forState:UIControlStateNormal];
    self.locationSearchBar.searchTextField.layer.cornerRadius = TEXT_FIELD_CORNER_RADIUS;
    self.locationSearchBar.searchTextField.clipsToBounds = CLIPS_TO_BOUNDS;
    self.locationSearchBar.searchTextField.font = [ProjectFonts searchBarFont];
        
    // Add border to autocompleted results table view
    self.autocompleteTableView.layer.borderWidth = TABLE_VIEW_BORDER_WIDTH;
    self.autocompleteTableView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    
    self.captionTextView.layer.cornerRadius = TEXT_FIELD_CORNER_RADIUS;
    self.captionTextView.clipsToBounds = CLIPS_TO_BOUNDS;
}

- (void)setCollectionViewLayout {
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *) self.pickedPhotosCollectionView.collectionViewLayout;
    layout.minimumInteritemSpacing = PHOTO_PREVIEW_COLLECTION_VIEW_SPACING;
    layout.minimumLineSpacing = PHOTO_PREVIEW_COLLECTION_VIEW_SPACING;
    
    // size of posts depends on device size
    CGFloat itemWidth = self.pickedPhotosCollectionView.collectionViewLayout.collectionViewContentSize.width;
    CGFloat itemHeight = self.pickedPhotosCollectionView.collectionViewLayout.collectionViewContentSize.height;
    layout.itemSize = CGSizeMake(itemWidth, itemHeight);
}

// Take photo using the phone camera when the camera icon is tapped, if available
- (IBAction)onCameraTap:(id)sender {
    [self performSegueWithIdentifier:CAMERA_SEGUE sender:nil];
}

// Choose multiple photos from the photo library
- (IBAction)onPhotoLibraryTap:(id)sender {
    [self performSegueWithIdentifier:IMAGE_PICKER_SEGUE sender:nil];
}

// Make post when share button is pressed
- (IBAction)shareButton:(id)sender {
    if (self.locationSearchBar.text.length != 0) {
        Post *newPost = [Post initPost:self.photosToUpload withCaption:self.captionTextView.text withLocation:self.locationID private:self.privateSwitch.isOn];
        // Make new post with the given location ID
        [Post makePost:newPost completion:^(NSString * userPostID, NSError * _Nullable error) {
            if (error != nil) {
                [AlertManager displayAlertWithTitle:POST_ERROR_TITLE text:POST_ERROR_MESSAGE presenter:self];
            }
            else {
                [Location tagLocation:self.locationID newPost:newPost completion:^(NSError * _Nonnull error) {
                    if (error != nil) {
                        [AlertManager displayAlertWithTitle:LOCATION_TAG_TITLE text:LOCATION_TAG_MESSAGE presenter:self];
                    }
                }];
                PFUser *currentUser = [PFUser currentUser];
                [currentUser incrementKey:USER_NUM_POSTS_KEY];
                [currentUser saveInBackground];
            }
        }];
        [self performSegueWithIdentifier:AFTER_POST_SEGUE sender:nil];
    }
    else {
        // Make alert for when no location is inputted
        [AlertManager displayAlertWithTitle:POST_FAILED_TITLE text:POST_FAILED_MESSAGE presenter:self];
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
    LocationAutocompleteCell *cell = [tableView dequeueReusableCellWithIdentifier:AUTOCOMPLETE_CELL_IDENTIFIER];
    
    // List name of suggested location in the cell
    NSDictionary *loc = self.autocompleteResults[indexPath.row];
    if (loc[AUTOCOMPLETE_RESULT_DESCRIPTION_KEY] != nil) {
        cell.locationLabel.text = loc[AUTOCOMPLETE_RESULT_DESCRIPTION_KEY];
    }
    else {
        cell.locationLabel.text = loc[AUTOCOMPLETE_RESULT_NAME_KEY];
    }
    
    return cell;
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    // Expand search bar
    [UIView animateWithDuration:SEARCH_BAR_ANIMATION_DURATION animations:^{
        [self.view layoutIfNeeded];
        [self animateSearchBar:true];
    }];
    
    // Let user cancel once a location is being searched
    searchBar.showsCancelButton = YES;
    
    // Initially show locations close to the user
    self.autocompleteTableView.hidden = false;
    [[LocationManager shared] getNearbyLocations:^(NSArray * _Nonnull nearby, NSError * _Nonnull error) {
        self.autocompleteResults = nearby;
        [self.autocompleteTableView reloadData];
    }];

}

- (void)animateSearchBar:(BOOL)showSearchBar {
    // Animate search bar to expand fully and hide
    self.mapImage.hidden = showSearchBar;
    [self.view removeConstraint:self.searchBarLeadingConstraint];
    if (showSearchBar) {
        self.searchBarLeadingConstraint = [NSLayoutConstraint constraintWithItem:self.locationSearchBar attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view.safeAreaLayoutGuide attribute:NSLayoutAttributeLeading multiplier:SEARCH_BAR_CONSTRAINT_MULTIPLIER constant:SEARCH_BAR_CONSTRAINT_CONSTANT];
        [self.view addConstraint:self.searchBarLeadingConstraint];
    }
    else {
        self.searchBarLeadingConstraint = [NSLayoutConstraint constraintWithItem:self.locationSearchBar attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.mapImage attribute:NSLayoutAttributeTrailing multiplier:SEARCH_BAR_CONSTRAINT_MULTIPLIER constant:SEARCH_BAR_CONSTRAINT_CONSTANT];
    }
    self.searchBarLeadingConstraint.priority = SEARCH_BAR_CONSTRAINT_PRIORITY;
    [self.view addConstraint:self.searchBarLeadingConstraint];
    [self.view layoutIfNeeded];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    // Dismiss search term once cancel is pressed
    searchBar.showsCancelButton = NO;
    self.autocompleteTableView.hidden = true;
    
    // Shrink search bar
    [UIView animateWithDuration:0.3 animations:^{
        [self.view layoutIfNeeded];
        [self animateSearchBar:false];
    }];
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
    if (self.autocompleteResults[indexPath.row][AUTOCOMPLETE_RESULT_DESCRIPTION_KEY] != nil) {
        self.locationSearchBar.text = self.autocompleteResults[indexPath.row][AUTOCOMPLETE_RESULT_DESCRIPTION_KEY];
    }
    else {
        self.locationSearchBar.text = self.autocompleteResults[indexPath.row][AUTOCOMPLETE_RESULT_NAME_KEY];
    }
    self.locationID = self.autocompleteResults[indexPath.row][LOCATION_PLACE_ID_KEY];
    self.autocompleteTableView.hidden = true;
    self.locationSearchBar.showsCancelButton = NO;
    
    // Shrink search bar
    [UIView animateWithDuration:SEARCH_BAR_ANIMATION_DURATION animations:^{
        [self.view layoutIfNeeded];
        [self animateSearchBar:false];
    }];}

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

- (IBAction)onSwitch:(id)sender {
    if (self.privateSwitch.on) {
        self.lockImageView.image = [UIImage systemImageNamed:@"lock"];
    }
    else {
        self.lockImageView.image = [UIImage systemImageNamed:@"lock.open"];
    }
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    // Set image for given cell
    PhotoViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:PHOTO_CELL_IDENTIFIER forIndexPath:indexPath];
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
    if ([[segue identifier] isEqualToString:IMAGE_PICKER_SEGUE] || [[segue identifier] isEqualToString:CAMERA_SEGUE]) {
        ImagePickerViewController *imagePickerController = [segue destinationViewController];
        imagePickerController.delegate = self;
        imagePickerController.limitSelection = MAX_NUM_POST_PHOTO_SELECTION;
        if ([[segue identifier] isEqualToString:CAMERA_SEGUE]) {
            imagePickerController.useCamera = true;
        }
        else {
            imagePickerController.useCamera = false;
        }
    }
}

@end
