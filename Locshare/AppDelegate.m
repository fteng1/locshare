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
#import "Constants.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Read keys from Keys.plist
    NSString *path = [[NSBundle mainBundle] pathForResource: KEYS_FILE_NAME ofType: KEYS_FILE_EXTENSION];
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile: path];
    
    NSString *extractedExpr = APPLICATION_ID_NAME;
    NSString *appID = [dict objectForKey: extractedExpr];
    NSString *clientKey = [dict objectForKey: CLIENT_KEY_NAME];
    NSString *gmapsAPIKey = [dict objectForKey:GOOGLE_API_KEY_NAME];
    
    // Initialize Parse server
    ParseClientConfiguration *config = [ParseClientConfiguration  configurationWithBlock:^(id<ParseMutableClientConfiguration> configuration) {
        
        configuration.applicationId = appID;
        configuration.clientKey = clientKey;
        configuration.server = SERVER_URL;
    }];
    
    [Parse initializeWithConfiguration:config];

    // Authenticate API key with Google Maps Services
    [GMSServices provideAPIKey:gmapsAPIKey];
    [GMSPlacesClient provideAPIKey:gmapsAPIKey];
    
    [self configureKeyboardManager];
    
    // Set font of tab bar and navigation bar
    [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[ProjectFonts tabBarFont], NSFontAttributeName, nil] forState:UIControlStateNormal];
    [[UIBarButtonItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[ProjectFonts navigationBarFont], NSFontAttributeName, nil] forState:UIControlStateNormal];

    return YES;
}

- (void)configureKeyboardManager {
    [IQKeyboardManager sharedManager].enable = true;
    [IQKeyboardManager sharedManager].keyboardDistanceFromTextField = KEYBOARD_DISTANCE_FROM_TEXT_FIELD;
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
