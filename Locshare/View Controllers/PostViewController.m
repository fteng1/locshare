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
#import "PhotoShareCell.h"
#import "LocationManager.h"

@interface PostViewController () <QBImagePickerControllerDelegate, UIImagePickerControllerDelegate, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UICollectionViewDelegate, UICollectionViewDataSource>

@property (weak, nonatomic) IBOutlet UISearchBar *locationSearchBar;
@property (weak, nonatomic) IBOutlet UICollectionView *pickedPhotosCollectionView;
@property (weak, nonatomic) IBOutlet UITextView *captionTextView;
@property (weak, nonatomic) IBOutlet UITableView *autocompleteTableView;

@property (strong, nonatomic) NSArray *autocompleteResults;
@property (strong, nonatomic) NSString *locationID;
@property (strong, nonatomic) NSMutableArray *photosToUpload;
@property (nonatomic, strong) PHImageRequestOptions *requestOptions;

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
    
    // Options for making requests regarding PHImages
    self.requestOptions = [[PHImageRequestOptions alloc] init];
    self.requestOptions.resizeMode = PHImageRequestOptionsResizeModeExact;
    self.requestOptions.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    // Makes calls to requestOptions synchronous
    self.requestOptions.synchronous = YES;
    
    // Initialize CollectionView
    self.pickedPhotosCollectionView.delegate = self;
    self.pickedPhotosCollectionView.dataSource = self;
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *) self.pickedPhotosCollectionView.collectionViewLayout;
    layout.minimumInteritemSpacing = 1;
    layout.minimumLineSpacing = 1;
    
    [self.pickedPhotosCollectionView reloadData];
}

- (IBAction)onCameraTap:(id)sender {
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

// Choose a photo from the photo library
- (IBAction)onPhotoLibraryTap:(id)sender {
    QBImagePickerController *imagePicker = [QBImagePickerController new];
    imagePicker.delegate = self;
    imagePicker.allowsMultipleSelection = YES;
    imagePicker.maximumNumberOfSelection = 6;
    imagePicker.showsNumberOfSelectedAssets = YES;
    
    [self presentViewController:imagePicker animated:YES completion:nil];
}

// Use when multiple photos are selected from the photo library
- (void)qb_imagePickerController:(QBImagePickerController *)imagePickerController didFinishPickingAssets:(NSArray *)assets {
    // Remove any existing photos in array
    [self.photosToUpload removeAllObjects];
    
    // Add each selected image into photosToUpload array
    for (PHAsset *photo in assets) {
        PHImageManager *manager = [PHImageManager defaultManager];
        
        // Convert asset from PHAsset to UIImage
        [manager requestImageForAsset:photo targetSize:PHImageManagerMaximumSize contentMode:PHImageContentModeDefault options:self.requestOptions resultHandler:^void(UIImage *image, NSDictionary *info) {
                // Add converted photo to photos array
                [self.photosToUpload addObject:[self resizeImage:image withSize:CGSizeMake(400, 300)]];
         }];
    }
    [self.pickedPhotosCollectionView reloadData];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

// Use when camera is used to take photo, can only choose one photo
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey,id> *)info {
    // Remove any existing photos in array
    [self.photosToUpload removeAllObjects];
    
    // Get the image captured by the UIImagePickerController
    UIImage *editedImage = info[UIImagePickerControllerEditedImage];
    editedImage = [self resizeImage:editedImage withSize:CGSizeMake(400, 300)];
    [self.photosToUpload addObject:editedImage];
    [self.pickedPhotosCollectionView reloadData];
    
    // Dismiss UIImagePickerController to go back to your original view controller
    [self dismissViewControllerAnimated:YES completion:nil];
}

// Resizes image to the specified size
- (UIImage *)resizeImage:(UIImage *)image withSize:(CGSize)size {
    UIImageView *resizeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    
    resizeImageView.contentMode = UIViewContentModeScaleAspectFill;
    resizeImageView.image = image;
    
    UIGraphicsBeginImageContext(size);
    [resizeImageView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

// Make post when share button is pressed
- (IBAction)shareButton:(id)sender {
    if (self.locationSearchBar.text.length != 0) {
        [Location tagLocation:self.locationID completion:^(NSString *locID, NSError * _Nonnull error) {
            if (error != nil) {
                NSLog(@"Location tag failed: %@", error.localizedDescription);
            }
            else {
                // Make new post with the given location ID
                Post *newPost = [Post initPost:self.photosToUpload withCaption:self.captionTextView.text withLocation:locID];
                [Post makePost:newPost withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
                    if (error != nil) {
                        NSLog(@"Post share failed: %@", error.localizedDescription);
                    }
                    else {
                        NSLog(@"Post shared successfully");
                        PFUser *currentUser = [PFUser currentUser];
                        [currentUser incrementKey:@"numPosts"];
                        [currentUser saveInBackground];
                    }
                }];
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
    self.locationSearchBar.text = self.autocompleteResults[indexPath.row][@"description"];
    self.locationID = self.autocompleteResults[indexPath.row][@"place_id"];
    self.autocompleteTableView.hidden = true;
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
    PhotoShareCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PhotoShareCell" forIndexPath:indexPath];
    if ([self.photosToUpload count] != 0) {
        cell.photoImageView.image = self.photosToUpload[indexPath.item];
    }
    return cell;
}
@end
