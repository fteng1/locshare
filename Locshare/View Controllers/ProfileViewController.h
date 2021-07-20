//
//  ProfileViewController.h
//  Locshare
//
//  Created by Felianne Teng on 7/12/21.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

NS_ASSUME_NONNULL_BEGIN

@interface ProfileViewController : UIViewController

@property (strong, nonatomic) PFUser *user;
@property (assign, nonatomic) BOOL firstAccessedFromTab;

@end

NS_ASSUME_NONNULL_END
