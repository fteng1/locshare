//
//  ImageManager.m
//  Locshare
//
//  Created by Felianne Teng on 7/20/21.
//

#import "ImageManager.h"
@import Parse;

@interface ImageManager ()

@end

@implementation ImageManager

- (void)viewDidLoad {
    [super viewDidLoad];
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
    return newImage;
}

@end
