//
//  UserSearchCell.m
//  Locshare
//
//  Created by Felianne Teng on 7/22/21.
//

#import "UserSearchCell.h"
#import "Constants.h"

@implementation UserSearchCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    // Round borders of accept friend button
    self.acceptRequestButton.layer.cornerRadius = BUTTON_CORNER_RADIUS;
    self.acceptRequestButton.layer.masksToBounds = MASKS_TO_BOUNDS;
    self.acceptRequestButton.layer.borderColor = [ProjectColors tintColor];
    self.acceptRequestButton.layer.borderWidth = BUTTON_BORDER_WIDTH;
    
    // Round borders of decline friend button
    self.declineRequestButton.layer.cornerRadius = BUTTON_CORNER_RADIUS;
    self.declineRequestButton.layer.masksToBounds = MASKS_TO_BOUNDS;
    self.declineRequestButton.layer.borderColor = [ProjectColors tintColor];
    self.declineRequestButton.layer.borderWidth = BUTTON_BORDER_WIDTH;
    
    // Make profile image circular
    self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.height / PROFILE_PICTURE_CORNER_RADIUS_RATIO;
    self.profileImageView.layer.masksToBounds = MASKS_TO_BOUNDS;
    
}

- (void)setFieldsWithUser {
    self.usernameLabel.text = self.user[USER_USERNAME_KEY];
    self.descriptionLabel.text = self.user[USER_TAGLINE_KEY];
    self.profileImageView.file = self.user[USER_PROFILE_PICTURE_KEY];
    [self.profileImageView loadInBackground];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (IBAction)acceptRequest:(id)sender {
    PFUser *currUser = [PFUser currentUser];
    
    NSDictionary *parameters = @{CLOUD_CODE_USER_TO_EDIT_KEY: self.user.objectId, CLOUD_CODE_FRIEND_KEY: @(true), CLOUD_CODE_CURRENT_USER_KEY: currUser.objectId};
    // Remove request from list of pending requests
    [PFCloud callFunctionInBackground:CLOUD_CODE_FRIEND_REQUEST_RESPONSE_FUNCTION withParameters:parameters];
    
    NSNumber *incrementFriendAmount = [ProjectNumbers one];
    // Update both users' friends list
    [PFCloud callFunctionInBackground:CLOUD_CODE_FRIEND_USER_FUNCTION withParameters:parameters];
    [currUser addObject:self.user.objectId forKey:USER_FRIENDS_KEY];
    
    // Update fields locally
    [self.user incrementKey:USER_NUM_FRIENDS_KEY byAmount:incrementFriendAmount];
    [currUser incrementKey:USER_NUM_FRIENDS_KEY byAmount:incrementFriendAmount];
    [currUser removeObject:self.user.objectId forKey:USER_PENDING_FRIENDS_KEY];
    
    [currUser saveInBackground];
    [self.delegate didFinishRespondingToFriendRequest:self.cellIndex];
}

- (IBAction)declineRequest:(id)sender {
    PFUser *currUser = [PFUser currentUser];
    
    NSDictionary *parameters = @{CLOUD_CODE_USER_TO_EDIT_KEY: self.user.objectId, CLOUD_CODE_CURRENT_USER_KEY: currUser.objectId};
    // Remove request from list of pending requests
    [PFCloud callFunctionInBackground:CLOUD_CODE_FRIEND_REQUEST_RESPONSE_FUNCTION withParameters:parameters];
    
    // Update fields locally
    [currUser removeObject:self.user.objectId forKey:USER_PENDING_FRIENDS_KEY];
    
    [currUser saveInBackground];
    [self.delegate didFinishRespondingToFriendRequest:self.cellIndex];
}

@end
