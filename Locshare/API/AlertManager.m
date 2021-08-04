//
//  AlertManager.m
//  Locshare
//
//  Created by Felianne Teng on 8/2/21.
//

#import "AlertManager.h"
#import "Constants.h"

@interface AlertManager ()

@end

@implementation AlertManager

- (void)viewDidLoad {
    [super viewDidLoad];
}

+ (void)displayAlertWithTitle:(NSString *)title text:(NSString *)text presenter:(UIViewController *)presenter {
    // Make alert for when no camera is available
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:text preferredStyle:(UIAlertControllerStyleAlert)];
    // create an OK action
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:OK_ACTION_TITLE style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {}];
    // add the OK action to the alert controller
    [alert addAction:okAction];
    [presenter presentViewController:alert animated:YES completion:^{}];
}

@end
