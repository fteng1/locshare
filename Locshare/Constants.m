//
//  Constants.m
//  Locshare
//
//  Created by Felianne Teng on 8/2/21.
//
#import <Foundation/Foundation.h>
#import "Constants.h"
#import <UIKit/UIKit.h>

// API Keys and Requests
NSString * const KEYS_FILE_NAME = @"Keys";
NSString * const KEYS_FILE_EXTENSION = @"plist";
NSString * const GOOGLE_API_KEY_NAME = @"google_api_key";
NSString * const APPLICATION_ID_NAME = @"application_id";
NSString * const CLIENT_KEY_NAME = @"client_key";
NSString * const SERVER_URL = @"https://parseapi.back4app.com";
CGFloat const URL_TIMEOUT_INTERVAL = 10.0;

// Places API
NSString * const PLACES_AUTOCOMPLETE_URL = @"https://maps.googleapis.com/maps/api/place/autocomplete/json?input=%@&key=%@";
NSString * const PLACES_AUTOCOMPLETE_RETURNED_DATA_KEY = @"predictions";
NSString * const PLACES_NEARBY_RADIUS = @"1000";
NSString * const PLACES_NEARBY_URL = @"https://maps.googleapis.com/maps/api/place/nearbysearch/json?key=%@&location=%@&radius=%@";
NSString * const PLACES_NEARBY_RETURNED_DATA_KEY = @"results";
NSString * const PLACES_DETAILS_URL = @"https://maps.googleapis.com/maps/api/place/details/json?place_id=%@&key=%@";
NSString * const PLACES_DETAILS_RETURNED_DATA_KEY = @"result";
NSString * const AUTOCOMPLETE_RESULT_DESCRIPTION_KEY = @"description";
NSString * const AUTOCOMPLETE_RESULT_NAME_KEY = @"name";
NSString * const AUTOCOMPLETE_RESULT_PLACE_ID_KEY = @"place_id";
NSString * const PLACE_DETAILS_NAME_KEY = @"name";
NSString * const PLACE_DETAILS_GEOMETRY_KEY = @"geometry";
NSString * const PLACE_DETAILS_LOCATION_KEY = @"location";
NSString * const PLACE_DETAILS_LATITUDE_KEY = @"lat";
NSString * const PLACE_DETAILS_LONGITUDE_KEY = @"lng";

// UIAlert Titles
NSString * const OK_ACTION_TITLE = @"OK";
NSString * const URL_REQUEST_ERROR_TITLE = @"Network Error";
NSString * const UPDATE_USER_ERROR_TITLE = @"Update User Error";
NSString * const RETRIEVING_POSTS_ERROR_TITLE = @"Error Retrieving Posts";
NSString * const SAVE_SUCCESSFUL_TITLE = @"Save Successful";
NSString * const POST_ERROR_TITLE = @"Post Error";
NSString * const LOCATION_TAG_TITLE = @"Location Tag Error";
NSString * const POST_FAILED_TITLE = @"Cannot Make Post";
NSString * const UPDATE_LOCATION_ERROR_TITLE = @"Error Updating Location";
NSString * const RETRIEVE_POSTS_ERROR_TITLE = @"Error Retrieving Posts";
NSString * const FETCH_COMMENT_ERROR_TITLE = @"Error Fetching Comments";
NSString * const PROFILE_ERROR_TITLE = @"User Profile Error";
NSString * const SEARCH_ERROR_INITIAL_USERS_TITLE = @"Search Error";
NSString * const PERFORM_SEARCH_ERROR_TITLE = @"Search Error";
NSString * const REGISTER_ERROR_TITLE = @"Register Error";
NSString * const LOGIN_ERROR_TITLE = @"Login Error";
NSString * const LOGOUT_ERROR_TITLE = @"Logout Error";
NSString * const LOGOUT_SUCCESS_TITLE = @"Logout Successful";
NSString * const CAMERA_UNAVAILABLE_TITLE = @"Cannot Take Photo";
NSString * const FRIEND_REQUESTS_ERROR_TITLE = @"Request Error";
NSString * const NETWORK_ERROR_TITLE = @"Network Error";

// UIAlert Messages
NSString * const URL_REQUEST_ERROR_MESSAGE = @"Could not complete network request";
NSString * const UPDATE_USER_ERROR_MESSAGE = @"Error retrieving latest data about user";
NSString * const RETRIEVING_POSTS_ERROR_MESSAGE = @"Could not fetch posts from server";
NSString * const SAVE_SUCCESSFUL_MESSAGE = @"Profile has been saved successfully";
NSString * const POST_ERROR_MESSAGE = @"Error sharing the current post";
NSString * const LOCATION_TAG_MESSAGE = @"Could not tag the location successfully";
NSString * const POST_FAILED_MESSAGE = @"User must select a valid location to make a post";
NSString * const UPDATE_LOCATION_ERROR_MESSAGE = @"Could not fetch this location";
NSString * const RETRIEVE_POSTS_ERROR_MESSAGE = @"Could not fetch posts at this location";
NSString * const FETCH_COMMENT_ERROR_MESSAGE = @"Could not retrieve comments on this post";
NSString * const PROFILE_ERROR_MESSAGE = @"Could not obtain the current user profile";
NSString * const SEARCH_ERROR_INITIAL_USERS_MESSAGE = @"Could not fetch initial users";
NSString * const PERFORM_SEARCH_ERROR_MESSAGE = @"Could not perform the given search";
NSString * const REGISTER_ERROR_MESSAGE = @"Could not register the provided user";
NSString * const LOGIN_ERROR_MESSAGE = @"Could not login the provided user";
NSString * const LOGOUT_ERROR_MESSAGE = @"Could not logout the current user";
NSString * const LOGOUT_SUCCESS_MESSAGE = @"Logout Successful";
NSString * const CAMERA_UNAVAILABLE_MESSAGE = @"Camera is not available on this device";
NSString * const FRIEND_REQUESTS_ERROR_MESSAGE = @"Error fetching the user's friend requests";
NSString * const NETWORK_ERROR_MESSAGE = @"User is not connected to the internet";

// Button UI Properties
CGFloat const BUTTON_CORNER_RADIUS = 5;
BOOL const MASKS_TO_BOUNDS = true;
CGFloat const BUTTON_BORDER_WIDTH = 1;
NSString * const FRIEND_BUTTON_TITLE_DEFAULT = @"Friend";
NSString * const FRIEND_BUTTON_REQUEST_SENT = @"Friend Request Sent";
NSString * const FRIEND_BUTTON_RESPOND_TO_REQUEST = @"Respond to Request";
NSString * const FRIEND_BUTTON_ALREADY_FRIENDS = @"Already Friends";
NSString * const LIKE_BUTTON_IMAGE_NORMAL = @"heart";
NSString * const LIKE_BUTTON_IMAGE_SELECTED = @"heart.fill";

// ImageView UI Properties
CGFloat const PROFILE_PICTURE_CORNER_RADIUS_RATIO = 2;
NSString * const DEFAULT_PROFILE_PICTURE_NAME = @"photo";
NSString * const LOCK_IMAGE_NAME = @"lock";
NSString * const LOCK_OPEN_IMAGE_NAME = @"lock.open";

// Text Field/View UI Properties
CGFloat const TEXT_FIELD_CORNER_RADIUS = 10.0;
NSString * const CAPTION_PLACEHOLDER_TEXT = @"Write a caption...";
BOOL const CLIPS_TO_BOUNDS = true;

// TableView UI Properties
CGFloat const TABLE_VIEW_BORDER_WIDTH = 0.5;

// CollectionView UI Properties
CGFloat const PHOTO_PREVIEW_COLLECTION_VIEW_SPACING = 1;
CGFloat const POST_PREVIEW_COLLECTION_VIEW_SPACING = 2;
CGFloat const POST_PREVIEW_COLLECTION_VIEW_POSTS_PER_LINE = 3;
NSInteger const IMAGE_PICKER_PHOTOS_PER_LINE = 5;
NSInteger const IMAGE_PICKER_COLLECTION_VIEW_SPACING = 1;

// SearchBar UI Properties
CGFloat const SEARCH_BAR_ANIMATION_DURATION = 0.3;
CGFloat const SEARCH_BAR_CONSTRAINT_MULTIPLIER = 1;
CGFloat const SEARCH_BAR_CONSTRAINT_CONSTANT = 10;
CGFloat const SEARCH_BAR_CONSTRAINT_PRIORITY = 1000;

// Post Properties
NSString * const POST_PARSE_CLASS_NAME = @"Post";
CGFloat const POST_IMAGE_COMPRESSION_QUALITY = 1.0;
NSString * const POST_IMAGE_DEFAULT_NAME = @"image.png";
NSString * const POST_AUTHOR_KEY = @"author";
NSString * const POST_CREATED_AT_KEY = @"createdAt";
NSString * const POST_PRIVATE_KEY = @"private";
NSString * const POST_LOCATION_KEY = @"location";
NSString * const POST_NUM_LIKES_KEY = @"numLikes";
NSString * const DEFAULT_POST_PREVIEW_IMAGE_NAME = @"photo";

// Location Properties
NSString * const LOCATION_PARSE_CLASS_NAME = @"Location";
NSString * const LOCATION_PLACE_ID_KEY = @"placeID";
NSString * const LOCATION_OBJECT_ID_KEY = @"objectId";
NSString * const LOCATION_COORDINATE_KEY = @"coordinate";
NSString * const LOCATION_NUM_POSTS_KEY = @"numPosts";
NSString * const LOCATION_USERS_WITH_POSTS_KEY = @"usersWithPosts";

// Comment Properties
NSString * const COMMENT_PARSE_CLASS_NAME = @"Comment";
NSString * const COMMENT_POST_ID_KEY = @"postID";

// User properties
NSString * const USER_PARSE_CLASS_NAME = @"_User";
NSString * const USER_USERNAME_KEY = @"username";
NSString * const USER_TAGLINE_KEY = @"tagline";
NSString * const USER_PROFILE_PICTURE_KEY = @"profilePicture";
NSString * const USER_NUM_FRIENDS_KEY = @"numFriends";
NSString * const USER_PENDING_FRIENDS_KEY = @"pendingFriends";
NSString * const USER_FRIENDS_KEY = @"friends";
NSString * const USER_REQUESTS_SENT_KEY = @"requestsSent";
NSString * const USER_OBJECT_ID_KEY = @"objectId";
NSString * const USER_NUM_POSTS_KEY = @"numPosts";
NSString * const USER_LIKED_POSTS_KEY = @"likedPosts";

// Cloud Code Requests
NSString * const CLOUD_CODE_USER_TO_EDIT_KEY = @"userToEditID";
NSString * const CLOUD_CODE_CURRENT_USER_KEY = @"currentUserID";
NSString * const CLOUD_CODE_FRIEND_KEY = @"friend";
NSString * const CLOUD_CODE_FRIEND_USER_FUNCTION = @"friendUser";
NSString * const CLOUD_CODE_FRIEND_REQUEST_RESPONSE_FUNCTION = @"respondToFriendRequest";
NSString * const CLOUD_CODE_SEND_FRIEND_REQUEST_FUNCTION = @"sendFriendRequest";

// Label UI Properties
NSString * const FRIEND_LABEL_SINGULAR = @"friend";
NSString * const FRIEND_LABEL_PLURAL = @"friends";
NSString * const POST_LABEL_SINGULAR = @"post";
NSString * const POST_LABEL_PLURAL = @"posts";
NSString * const LIKE_LABEL_SINGULAR = @"like";
NSString * const LIKE_LABEL_PLURAL = @"likes";

// MapView Properties
CGFloat const MAP_FEED_DEFAULT_ZOOM = 10.0;
CGFloat const LOCATION_VIEW_DEFAULT_ZOOM = 12.0;

// Segues
NSString * const PROFILE_TO_LOCATION_SEGUE = @"profileLocationSegue";
NSString * const CHOOSE_PROFILE_PHOTO_SEGUE = @"chooseProfileSegue";
NSString * const PROFILE_TO_FRIEND_REQUESTS_SEGUE = @"friendRequestSegue";
NSString * const CAMERA_SEGUE = @"cameraSegue";
NSString * const IMAGE_PICKER_SEGUE = @"imagePickerSegue";
NSString * const AFTER_POST_SEGUE = @"afterPostSegue";
NSString * const PROFILE_FROM_REQUESTS_SEGUE = @"profileFromRequests";
NSString * const DETAIL_SEGUE = @"detailSegue";
NSString * const HEADER_TO_PROFILE_SEGUE = @"profileSegue";
NSString * const LOGGED_IN_SEGUE = @"loginSegue";
NSString * const HOME_TO_LOCATION_SEGUE = @"locationSegue";

// Profile Tab Constants
NSString * const MOST_RECENT_POST_PREDICATE = @"placeID like %@";
NSString * const GROUP_POSTS_KEY_PATH = @"@distinctUnionOfObjects.location";
NSString * const POSTS_AT_LOCATION_PREDICATE = @"location like %@";
NSInteger const PROFILE_TAB_INDEX = 3;

// Storyboard Identifiers
NSString * const AUTOCOMPLETE_CELL_IDENTIFIER = @"LocationAutocompleteCell";
NSString * const PHOTO_CELL_IDENTIFIER = @"PhotoViewCell";
NSString * const POST_CELL_IDENTIFIER = @"PostLocationCell";
NSString * const COMMENT_CELL_IDENTIFIER = @"CommentCell";
NSString * const SEARCH_CELL_IDENTIFIER = @"UserSearchCell";
NSString * const LOGIN_VIEW_CONTROLLER_IDENTIFIER = @"LoginViewController";
NSString * const IMAGE_PICKER_CELL_IDENTIFIER = @"ImagePickerCell";
NSString * const TAB_BAR_CONTROLLER_IDENTIFIER = @"TabBarController";
NSString * const FRIEND_REQUEST_CELL_IDENTIFIER = @"RequestCell";
NSString * const STORYBOARD_NAME = @"Main";

// ImagePicker Selection Limits
NSInteger const MAX_NUM_PROFILE_PHOTO_SELECTION = 1;
NSInteger const MAX_NUM_POST_PHOTO_SELECTION = 6;

// Date Handling
NSString * const DATE_FORMAT = @"yyyy-MM-dd HH:mm:ss Z";

// User Search Constants
NSInteger const INITIAL_USER_QUERY_LIMIT = 10;
NSString * const SEARCH_BAR_REGEX_MODIFIERS = @"i";

// ImagePicker Constants
NSString * const PHOTO_CREATION_DATE_KEY = @"creationDate";
CGFloat const CAPTURE_PHOTO_ANIMATION_DURATION = 0.05;
CGFloat const FULL_IMAGE_WIDTH = 400;
CGFloat const FULL_IMAGE_HEIGHT = 300;
CGFloat const IMAGE_THUMBNAIL_WIDTH = 128;
CGFloat const IMAGE_THUMBNAIL_HEIGHT = 128;

// Format Strings
NSString * const LOCATION_STRING = @"%f,%f";
NSString * const OBJECT_STRING = @"%@";

// Core Data
NSString * const CACHED_USER_CLASS_NAME = @"CachedUser";
NSString * const CACHED_LOCATION_CLASS_NAME = @"CachedLocation";
NSString * const CACHED_POST_CLASS_NAME = @"CachedPost";
NSString * const CACHED_COMMENT_CLASS_NAME = @"CachedComment";
NSString * const CACHED_OBJECT_ID_FILTER_PREDICATE = @"objectId == %@";
NSString * const CACHED_PLACE_ID_FILTER_PREDICATE = @"placeID == %@";
NSString * const CACHED_POST_CREATED_AT_KEY = @"createdAt";
NSString * const CACHED_LOCATION_FILTER_PREDICATE = @"location == %@";

// Misc. Constants
NSString * const EMPTY_STRING = @"";
CGFloat const KEYBOARD_DISTANCE_FROM_TEXT_FIELD = 10;


@implementation ProjectColors

+ (CGColorRef)tintColor {
    return [[UIColor colorWithRed:104/255.0 green:176/255.0 blue:171/255.0 alpha:1.0] CGColor];
}

+ (UIColor *)tanBackgroundColor {
    return [UIColor colorWithRed:250/255.0 green:243/255.0 blue:221/255.0 alpha:1];
}

@end


@implementation ProjectNumbers

+ (NSNumber *)zero {
    return [NSNumber numberWithInteger:0];
};

+ (NSNumber *)one {
    return [NSNumber numberWithInteger:1];
};
+ (NSNumber *)negativeOne {
    return [NSNumber numberWithInteger:-1];
};

@end


@implementation ProjectLocations

+ (GMSCameraPosition *)defaultLocation {
    return [GMSCameraPosition cameraWithLatitude:40.745028 longitude:-100.657394 zoom:1.0];
}

@end


@implementation ProjectFonts

+ (UIFont *)searchBarFont {
    return [UIFont fontWithName:@"Kohinoor Devanagari" size:17];
}

+ (UIFont *)tabBarFont {
    return [UIFont fontWithName:@"Kohinoor Devanagari" size:12];
}
+ (UIFont *)navigationBarFont {
    return [UIFont fontWithName:@"Kohinoor Devanagari" size:17];
}

@end
