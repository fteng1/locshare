//
//  ImageManager.h
//  Locshare
//
//  Created by Felianne Teng on 7/20/21.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ImageManager : UIViewController

@property (strong, nonatomic) UIImage *image;
@property (strong, nonatomic) UIImageView *viewToSet;

+ (UIImage *)resizeImage:(UIImage *)image withSize:(CGSize)size;

- (void)presentImagePicker;
    
@end

NS_ASSUME_NONNULL_END
