//
//  ImagePickerViewController.h
//  Locshare
//
//  Created by Felianne Teng on 7/26/21.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol ImagePickerControllerDelegate

- (void)didFinishPicking:(NSArray *)images;

@end

@interface ImagePickerViewController : UIViewController

@property (nonatomic, weak) id<ImagePickerControllerDelegate> delegate;
@property (assign, nonatomic) BOOL useCamera;
@property (assign, nonatomic) NSInteger limitSelection;

@end

NS_ASSUME_NONNULL_END
