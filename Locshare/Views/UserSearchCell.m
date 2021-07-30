//
//  UserSearchCell.m
//  Locshare
//
//  Created by Felianne Teng on 7/22/21.
//

#import "UserSearchCell.h"

@implementation UserSearchCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    // Round borders of accept friend button
    self.acceptRequestButton.layer.cornerRadius = 5;
    self.acceptRequestButton.layer.masksToBounds = true;
    self.acceptRequestButton.layer.borderColor = [[UIColor colorWithRed:104/255.0 green:176/255.0 blue:171/255.0 alpha:1.0] CGColor];
    self.acceptRequestButton.layer.borderWidth = 1;
    
    // Round borders of decline friend button
    self.declineRequestButton.layer.cornerRadius = 5;
    self.declineRequestButton.layer.masksToBounds = true;
    self.declineRequestButton.layer.borderColor = [[UIColor colorWithRed:104/255.0 green:176/255.0 blue:171/255.0 alpha:1.0] CGColor];
    self.declineRequestButton.layer.borderWidth = 1;
    
    // Make profile image circular
    self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.height / 2;;
    self.profileImageView.layer.masksToBounds = true;
    
}

- (void)setFieldsWithUser:(PFUser *)user {
    self.usernameLabel.text = user[@"username"];
    self.descriptionLabel.text = user[@"tagline"];
    self.profileImageView.file = user[@"profilePicture"];
    [self.profileImageView loadInBackground];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
