//
//  AppDelegate.h
//  Locshare
//
//  Created by Felianne Teng on 7/12/21.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (readonly, strong) NSPersistentContainer *persistentContainer;

- (void)saveContext;

@end

