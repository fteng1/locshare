//
//  PhotoShareCell.h
//  Locshare
//
//  Created by Felianne Teng on 7/14/21.
//

#import <UIKit/UIKit.h>
@import Parse;

NS_ASSUME_NONNULL_BEGIN

@interface PhotoViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet PFImageView *photoImageView;

@end

NS_ASSUME_NONNULL_END
