//
//  ImagePickerViewController.h
//  Locshare
//
//  Created by Felianne Teng on 7/26/21.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol ImagePickerControllerDelegate

@optional
- (void)didFinishPicking:(NSArray *)images;
@optional
- (NSArray *)didTakePhoto;

@end

@interface ImagePickerViewController : UIViewController

@property (nonatomic, weak) id<ImagePickerControllerDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
