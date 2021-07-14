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

@interface PostViewController () <UIImagePickerControllerDelegate, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UISearchBar *locationSearchBar;
@property (weak, nonatomic) IBOutlet UIImageView *imagePickView;
@property (weak, nonatomic) IBOutlet UITextView *captionTextView;
@property (weak, nonatomic) IBOutlet UITableView *autocompleteTableView;

@property (strong, nonatomic) NSArray *autocompleteResults;
@property (strong, nonatomic) NSString *locationID;

@end

@implementation PostViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.autocompleteTableView.delegate = self;
    self.autocompleteTableView.dataSource = self;
    self.locationSearchBar.delegate = self;
    
    self.captionTextView.placeholder = @"Write a caption...";
}

- (IBAction)onCameraTap:(id)sender {
    UIImagePickerController *imagePickerVC = [UIImagePickerController new];
    imagePickerVC.delegate = self;
    imagePickerVC.allowsEditing = YES;
    
    // The Xcode simulator does not support taking pictures, so let's first check that the camera is indeed supported on the device before trying to present it.
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        imagePickerVC.sourceType = UIImagePickerControllerSourceTypeCamera;
    }
    else {
        NSLog(@"The camera is not available");
    }
    [self presentViewController:imagePickerVC animated:YES completion:nil];
}

- (IBAction)onPhotoLibraryTap:(id)sender {
    UIImagePickerController *imagePickerVC = [UIImagePickerController new];
    imagePickerVC.delegate = self;
    imagePickerVC.allowsEditing = YES;
    
    imagePickerVC.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self presentViewController:imagePickerVC animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey,id> *)info {
    // Get the image captured by the UIImagePickerController
    UIImage *originalImage = info[UIImagePickerControllerOriginalImage];
    UIImage *editedImage = info[UIImagePickerControllerEditedImage];

    // Do something with the images (based on your use case)
    self.imagePickView.image = [self resizeImage:editedImage withSize:CGSizeMake(400, 300)];
    
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

- (IBAction)shareButton:(id)sender {
    if (self.locationSearchBar.text.length != 0) {
        [Location tagLocation:self.locationID completion:^(NSString *locID, NSError * _Nonnull error) {
            if (error != nil) {
                NSLog(@"Location tag failed: %@", error.localizedDescription);
            }
            else {
                // Make new post with the given location ID
                Post *newPost = [Post initPost:self.imagePickView.image withCaption:self.captionTextView.text withLocation:locID];
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
        // TODO: Popup telling users to input a valid location
    }
}

- (void)getSuggestedLocations:(NSString *)searchQuery {
    // Get API key from Keys.plist
    NSString *path = [[NSBundle mainBundle] pathForResource: @"Keys" ofType: @"plist"];
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile: path];
    
    // Format searchQuery by replacing spaces with '+'
    searchQuery = [searchQuery stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    
    // Return suggested autocomplete locations from Places API
    NSString *gMapsAPIKey = [dict objectForKey: @"google_api_key"];
    NSURL *url = [NSURL URLWithString: [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/autocomplete/json?input=%@&key=%@", searchQuery, gMapsAPIKey]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10.0];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error != nil) {
           NSLog(@"%@", [error localizedDescription]);
        }
        else {
            NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            self.autocompleteResults = dataDictionary[@"predictions"];
            [self.autocompleteTableView reloadData];
        }
    }];
    [task resume];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.autocompleteResults count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LocationAutocompleteCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LocationAutocompleteCell"];
    
    // List name of suggested location in the cell
    NSDictionary *loc = self.autocompleteResults[indexPath.row];
    cell.locationLabel.text = loc[@"description"];
    return cell;
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    // Let user cancel once a location is being searched
    searchBar.showsCancelButton = YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    // Dismiss search term once cancel is pressed
    searchBar.showsCancelButton = NO;
    self.autocompleteTableView.hidden = true;
    [searchBar resignFirstResponder];
}

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
    self.locationSearchBar.text = self.autocompleteResults[indexPath.row][@"description"];
    self.locationID = self.autocompleteResults[indexPath.row][@"place_id"];
    self.autocompleteTableView.hidden = true;
}

- (IBAction)dismissKeyboard:(id)sender {
    // after typing in the caption text view, tapping anywhere in the view dismisses the keyboard
    [self.captionTextView resignFirstResponder];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
