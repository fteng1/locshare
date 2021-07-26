//
//  ImagePickerCell.h
//  Locshare
//
//  Created by Felianne Teng on 7/26/21.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ImagePickerCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *indexLabel;
@property (weak, nonatomic) IBOutlet UIImageView *selectedView;

@end

NS_ASSUME_NONNULL_END
