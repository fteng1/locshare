//
//  UserSearchCell.h
//  Locshare
//
//  Created by Felianne Teng on 7/22/21.
//

#import <UIKit/UIKit.h>
@import Parse;

NS_ASSUME_NONNULL_BEGIN

@interface UserSearchCell : UITableViewCell

@property (weak, nonatomic) IBOutlet PFImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UIButton *acceptRequestButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *acceptRequestButtonWidthConstraint;
@property (weak, nonatomic) IBOutlet UIButton *declineRequestButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *declineRequestButtonWidthConstraint;

@property (strong, nonatomic) PFUser *user;

- (void)setFieldsWithUser;

@end

NS_ASSUME_NONNULL_END
