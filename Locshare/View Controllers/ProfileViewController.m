//
//  ProfileViewController.m
//  Locshare
//
//  Created by Felianne Teng on 7/12/21.
//

#import "ProfileViewController.h"
#import <Parse/Parse.h>
#import "SceneDelegate.h"
#import "LoginViewController.h"

@interface ProfileViewController ()

@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)onLogoutTap:(id)sender {
    [PFUser logOutInBackgroundWithBlock:^(NSError * _Nullable error) {
        // PFUser.current() will now be nil
        if (error != nil) {
            NSLog(@"User log out failed: %@", error.localizedDescription);
        }
        else {
            // After logout, return to login screen
            NSLog(@"User logged out successfully");
            SceneDelegate *sceneDelegate = (SceneDelegate *)self.view.window.windowScene.delegate;

            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            LoginViewController *loginViewController = [storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
            sceneDelegate.window.rootViewController = loginViewController;
        }
    }];
}

@end
