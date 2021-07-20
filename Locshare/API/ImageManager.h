//
//  ImageManager.h
//  Locshare
//
//  Created by Felianne Teng on 7/20/21.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ImageManager : UIImagePickerController

+ (instancetype)shared;

- (UIImage *)resizeImage:(UIImage *)image withSize:(CGSize)size;
    
@end

NS_ASSUME_NONNULL_END
