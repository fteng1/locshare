//
//  AppDelegate.m
//  Locshare
//
//  Created by Felianne Teng on 7/12/21.
//

#import "AppDelegate.h"
#import <Parse/Parse.h>
#import <GoogleMaps/GoogleMaps.h>
#import <GooglePlaces/GooglePlaces.h>
#import <IQKeyboardManager/IQKeyboardManager.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Read keys from Keys.plist
    NSString *path = [[NSBundle mainBundle] pathForResource: @"Keys" ofType: @"plist"];
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile: path];
    
    NSString *extractedExpr = @"application_id";
    NSString *appID = [dict objectForKey: extractedExpr];
    NSString *clientKey = [dict objectForKey: @"client_key"];
    NSString *gmapsAPIKey = [dict objectForKey:@"google_api_key"];
    
    // Initialize Parse server
    ParseClientConfiguration *config = [ParseClientConfiguration  configurationWithBlock:^(id<ParseMutableClientConfiguration> configuration) {
        
        configuration.applicationId = appID;
        configuration.clientKey = clientKey;
        configuration.server = @"https://parseapi.back4app.com";
    }];
    
    [Parse initializeWithConfiguration:config];

    // Authenticate API key with Google Maps Services
    [GMSServices provideAPIKey:gmapsAPIKey];
    [GMSPlacesClient provideAPIKey:gmapsAPIKey];
    
    [self configureKeyboardManager];

    return YES;
}

- (void)configureKeyboardManager {
    [IQKeyboardManager sharedManager].enable = true;
    [IQKeyboardManager sharedManager].keyboardDistanceFromTextField = 10;
    [IQKeyboardManager sharedManager].enableAutoToolbar = false;
    [IQKeyboardManager sharedManager].shouldResignOnTouchOutside = true;
}


#pragma mark - UISceneSession lifecycle


- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}


- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions {
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
}


@end
