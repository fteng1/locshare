//
//  PostViewController.m
//  Locshare
//
//  Created by Felianne Teng on 7/12/21.
//

#import "PostViewController.h"
#import <UITextView_Placeholder/UITextView+Placeholder.h>
#import "Post.h"

@interface PostViewController () <UIImagePickerControllerDelegate>
@property (weak, nonatomic) IBOutlet UISearchBar *locationSearchBar;
@property (weak, nonatomic) IBOutlet UIImageView *imagePickView;
@property (weak, nonatomic) IBOutlet UITextView *captionTextView;

@end

@implementation PostViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
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
    self.imagePickView.image = [self resizeImage:editedImage withSize:CGSizeMake(300, 300)];
    
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
//    Post *newPost = [Post initPost:self.pickedImageView.image withCaption:self.captionTextView.text];
//    [Post postUserImage:newPost withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
//        if (error != nil) {
//            NSLog(@"Post share failed: %@", error.localizedDescription);
//        }
//        else {
//            [self.delegate didPost:newPost];
//            NSLog(@"Post shared successfully");
//            PFUser *currentUser = [PFUser currentUser];
//            [currentUser incrementKey:@"numPosts"];
//            [currentUser saveInBackground];
//        }
//    }];
//    [self dismissViewControllerAnimated:YES completion:nil];
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
