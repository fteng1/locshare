//
//  CommentCell.h
//  Locshare
//
//  Created by Felianne Teng on 7/23/21.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CommentCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *commentTextLabel;
@property (weak, nonatomic) IBOutlet UILabel *timestampLabel;


@end

NS_ASSUME_NONNULL_END
