//
//  LocationViewController.h
//  Locshare
//
//  Created by Felianne Teng on 7/12/21.
//

#import <UIKit/UIKit.h>
#import "Location.h"

NS_ASSUME_NONNULL_BEGIN

@interface LocationViewController : UIViewController

@property (strong, nonatomic) Location *location;
@property (strong, nonatomic) NSArray *postsToDisplay;
@property (strong, nonatomic) PFUser *userToFilter;

@end

NS_ASSUME_NONNULL_END
