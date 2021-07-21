//
//  ImageManager.m
//  Locshare
//
//  Created by Felianne Teng on 7/20/21.
//

#import "ImageManager.h"
@import Parse;

@interface ImageManager () <UIImagePickerControllerDelegate>

@end

@implementation ImageManager

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"Test");
    [self presentImagePicker];
}

// Resizes image to the specified size
+ (UIImage *)resizeImage:(UIImage *)image withSize:(CGSize)size {
    UIImageView *resizeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    
    resizeImageView.contentMode = UIViewContentModeScaleAspectFill;
    resizeImageView.image = image;
    
    UIGraphicsBeginImageContext(size);
    [resizeImageView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    NSLog(@"Resize");
    return newImage;
}

- (void)takePhotoForImageView:(PFImageView *)imageView {
    UIImagePickerController *imagePicker = [UIImagePickerController new];
    imagePicker.allowsEditing = YES;
    NSLog(@"TakePhoto");
    // The Xcode simulator does not support taking pictures, so let's first check that the camera is indeed supported on the device before trying to present it.
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    }
    else {
        NSLog(@"The camera is not available");
    }
    [self presentViewController:imagePicker animated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey,id> *)info {
    NSLog(@"Finished");
    // Get the image captured by the UIImagePickerController
    UIImage *editedImage = info[UIImagePickerControllerEditedImage];
    editedImage = [ImageManager resizeImage:editedImage withSize:CGSizeMake(400, 300)];
    self.image = editedImage;
    self.viewToSet.image = editedImage;
    // Dismiss UIImagePickerController to go back to your original view controller
    UIViewController *presenter = self.presentingViewController;
    [self dismissViewControllerAnimated:YES completion:nil];
    [presenter dismissViewControllerAnimated:YES completion:nil];
}

- (void)presentImagePicker {
    NSLog(@"Present");
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

@end