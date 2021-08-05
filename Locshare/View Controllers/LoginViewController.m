//
//  LoginViewController.m
//  Locshare
//
//  Created by Felianne Teng on 7/12/21.
//

#import "LoginViewController.h"
#import <Parse/Parse.h>
#import "AlertManager.h"
#import "Constants.h"

@interface LoginViewController ()

@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)registerUser {
    // initialize a user object
    PFUser *newUser = [PFUser user];
    
    // set user properties
    newUser.username = self.usernameField.text;
    newUser.password = self.passwordField.text;
    
    // call sign up function on the object
    [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError * error) {
        if (error != nil) {
            [AlertManager displayAlertWithTitle:REGISTER_ERROR_TITLE text:REGISTER_ERROR_MESSAGE presenter:self];
        } else {
            // manually segue to logged in view
            [self performSegueWithIdentifier:LOGGED_IN_SEGUE sender:nil];
        }
    }];
}

- (void)loginUser {
    // Save inputted properties
    NSString *username = self.usernameField.text;
    NSString *password = self.passwordField.text;
    
    // Check that user is in the Parse database
    [PFUser logInWithUsernameInBackground:username password:password block:^(PFUser * user, NSError *  error) {
        if (error != nil) {
            [AlertManager displayAlertWithTitle:LOGIN_ERROR_TITLE text:LOGIN_ERROR_MESSAGE presenter:self];
        } else {
            // display view controller that needs to shown after successful login
            [self performSegueWithIdentifier:LOGGED_IN_SEGUE sender:nil];
        }
    }];
}

- (IBAction)inSignInTap:(id)sender {
    [self loginUser];
    
}

- (IBAction)onRegisterTap:(id)sender {
    [self registerUser];
}

@end
