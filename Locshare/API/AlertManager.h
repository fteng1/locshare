//
//  AlertManager.h
//  Locshare
//
//  Created by Felianne Teng on 8/2/21.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AlertManager : UIViewController

+ (void)displayAlertWithTitle:(NSString *)title text:(NSString *)text presenter:(UIViewController *)presenter;

@end

NS_ASSUME_NONNULL_END
