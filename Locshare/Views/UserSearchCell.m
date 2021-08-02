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

- (void)setFieldsWithUser {
    self.usernameLabel.text = self.user[@"username"];
    self.descriptionLabel.text = self.user[@"tagline"];
    self.profileImageView.file = self.user[@"profilePicture"];
    [self.profileImageView loadInBackground];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (IBAction)acceptRequest:(id)sender {
    PFUser *currUser = [PFUser currentUser];
    
    NSDictionary *parameters = @{@"userToEditID": self.user.objectId, @"friend": @(true), @"currentUserID": currUser.objectId};
    // Remove request from list of pending requests
    [PFCloud callFunctionInBackground:@"respondToFriendRequest" withParameters:parameters];
    
    NSNumber *incrementFriendAmount = @(1);
    // Update both users' friends list
    [PFCloud callFunctionInBackground:@"friendUser" withParameters:parameters];
    [currUser addObject:self.user.objectId forKey:@"friends"];
    
    // Update fields locally
    [self.user incrementKey:@"numFriends" byAmount:incrementFriendAmount];
    [currUser incrementKey:@"numFriends" byAmount:incrementFriendAmount];
    [currUser removeObject:self.user.objectId forKey:@"pendingFriends"];
    
    [currUser saveInBackground];
    [self.delegate didFinishRespondingToFriendRequest:self.cellIndex];
}

- (IBAction)declineRequest:(id)sender {
    PFUser *currUser = [PFUser currentUser];
    
    NSDictionary *parameters = @{@"userToEditID": self.user.objectId, @"currentUserID": currUser.objectId};
    // Remove request from list of pending requests
    [PFCloud callFunctionInBackground:@"respondToFriendRequest" withParameters:parameters];
    
    // Update fields locally
    [currUser removeObject:self.user.objectId forKey:@"pendingFriends"];
    
    [currUser saveInBackground];
    [self.delegate didFinishRespondingToFriendRequest:self.cellIndex];
}

@end
