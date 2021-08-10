//
//  Constants.h
//  Locshare
//
//  Created by Felianne Teng on 8/2/21.
//

#ifndef Constants_h
#define Constants_h
#import <UIKit/UIKit.h>
#import <GoogleMaps/GoogleMaps.h>

// API Keys and Requests
extern NSString * const KEYS_FILE_NAME;
extern NSString * const KEYS_FILE_EXTENSION;
extern NSString * const GOOGLE_API_KEY_NAME;
extern NSString * const APPLICATION_ID_NAME;
extern NSString * const CLIENT_KEY_NAME;
extern NSString * const SERVER_URL;
extern CGFloat const URL_TIMEOUT_INTERVAL;

// Places API
extern NSString * const PLACES_AUTOCOMPLETE_URL;
extern NSString * const PLACES_AUTOCOMPLETE_RETURNED_DATA_KEY;
extern NSString * const PLACES_NEARBY_RADIUS;
extern NSString * const PLACES_NEARBY_URL;
extern NSString * const PLACES_NEARBY_RETURNED_DATA_KEY;
extern NSString * const PLACES_DETAILS_URL;
extern NSString * const PLACES_DETAILS_RETURNED_DATA_KEY;
extern NSString * const AUTOCOMPLETE_RESULT_DESCRIPTION_KEY;
extern NSString * const AUTOCOMPLETE_RESULT_NAME_KEY;
extern NSString * const AUTOCOMPLETE_RESULT_PLACE_ID_KEY;
extern NSString * const PLACE_DETAILS_NAME_KEY;
extern NSString * const PLACE_DETAILS_GEOMETRY_KEY;
extern NSString * const PLACE_DETAILS_LOCATION_KEY;
extern NSString * const PLACE_DETAILS_LATITUDE_KEY;
extern NSString * const PLACE_DETAILS_LONGITUDE_KEY;

// UIAlert Titles
extern NSString * const OK_ACTION_TITLE;
extern NSString * const URL_REQUEST_ERROR_TITLE;
extern NSString * const UPDATE_USER_ERROR_TITLE;
extern NSString * const RETRIEVING_POSTS_ERROR_TITLE;
extern NSString * const SAVE_SUCCESSFUL_TITLE;
extern NSString * const POST_ERROR_TITLE;
extern NSString * const LOCATION_TAG_TITLE;
extern NSString * const POST_FAILED_TITLE;
extern NSString * const UPDATE_LOCATION_ERROR_TITLE;
extern NSString * const RETRIEVE_POSTS_ERROR_TITLE;
extern NSString * const FETCH_COMMENT_ERROR_TITLE;
extern NSString * const PROFILE_ERROR_TITLE;
extern NSString * const SEARCH_ERROR_INITIAL_USERS_TITLE;
extern NSString * const PERFORM_SEARCH_ERROR_TITLE;
extern NSString * const REGISTER_ERROR_TITLE;
extern NSString * const LOGIN_ERROR_TITLE;
extern NSString * const LOGOUT_ERROR_TITLE;
extern NSString * const LOGOUT_SUCCESS_TITLE;
extern NSString * const CAMERA_UNAVAILABLE_TITLE;
extern NSString * const FRIEND_REQUESTS_ERROR_TITLE;
extern NSString * const NETWORK_ERROR_TITLE;

// UIAlert Messages
extern NSString * const URL_REQUEST_ERROR_MESSAGE;
extern NSString * const UPDATE_USER_ERROR_MESSAGE;
extern NSString * const RETRIEVING_POSTS_ERROR_MESSAGE;
extern NSString * const SAVE_SUCCESSFUL_MESSAGE;
extern NSString * const POST_ERROR_MESSAGE;
extern NSString * const LOCATION_TAG_MESSAGE;
extern NSString * const POST_FAILED_MESSAGE;
extern NSString * const UPDATE_LOCATION_ERROR_MESSAGE;
extern NSString * const RETRIEVE_POSTS_ERROR_MESSAGE;
extern NSString * const FETCH_COMMENT_ERROR_MESSAGE;
extern NSString * const PROFILE_ERROR_MESSAGE;
extern NSString * const SEARCH_ERROR_INITIAL_USERS_MESSAGE;
extern NSString * const PERFORM_SEARCH_ERROR_MESSAGE;
extern NSString * const REGISTER_ERROR_MESSAGE;
extern NSString * const LOGIN_ERROR_MESSAGE;
extern NSString * const LOGOUT_ERROR_MESSAGE;
extern NSString * const LOGOUT_SUCCESS_MESSAGE;
extern NSString * const CAMERA_UNAVAILABLE_MESSAGE;
extern NSString * const FRIEND_REQUESTS_ERROR_MESSAGE;
extern NSString * const NETWORK_ERROR_MESSAGE;

// Button UI Properties
extern CGFloat const BUTTON_CORNER_RADIUS;
extern BOOL const MASKS_TO_BOUNDS;
extern CGFloat const BUTTON_BORDER_WIDTH;
extern NSString * const FRIEND_BUTTON_TITLE_DEFAULT;
extern NSString * const FRIEND_BUTTON_REQUEST_SENT;
extern NSString * const FRIEND_BUTTON_RESPOND_TO_REQUEST;
extern NSString * const FRIEND_BUTTON_ALREADY_FRIENDS;
extern NSString * const LIKE_BUTTON_IMAGE_NORMAL;
extern NSString * const LIKE_BUTTON_IMAGE_SELECTED;

// ImageView UI Properties
extern CGFloat const PROFILE_PICTURE_CORNER_RADIUS_RATIO;
extern NSString * const DEFAULT_PROFILE_PICTURE_NAME;
extern NSString * const LOCK_IMAGE_NAME;
extern NSString * const LOCK_OPEN_IMAGE_NAME;

// Text Field/View UI Properties
extern CGFloat const TEXT_FIELD_CORNER_RADIUS;
extern NSString * const CAPTION_PLACEHOLDER_TEXT;
extern BOOL const CLIPS_TO_BOUNDS;

// TableView UI Properties
extern CGFloat const TABLE_VIEW_BORDER_WIDTH;

// CollectionView UI Properties
extern CGFloat const PHOTO_PREVIEW_COLLECTION_VIEW_SPACING;
extern CGFloat const POST_PREVIEW_COLLECTION_VIEW_SPACING;
extern CGFloat const POST_PREVIEW_COLLECTION_VIEW_POSTS_PER_LINE;
extern NSInteger const IMAGE_PICKER_PHOTOS_PER_LINE;
extern NSInteger const IMAGE_PICKER_COLLECTION_VIEW_SPACING;

// SearchBar UI Properties
extern CGFloat const SEARCH_BAR_ANIMATION_DURATION;
extern CGFloat const SEARCH_BAR_CONSTRAINT_MULTIPLIER;
extern CGFloat const SEARCH_BAR_CONSTRAINT_CONSTANT;
extern CGFloat const SEARCH_BAR_CONSTRAINT_PRIORITY;

// Post Properties
extern NSString * const POST_PARSE_CLASS_NAME;
extern CGFloat const POST_IMAGE_COMPRESSION_QUALITY;
extern NSString * const POST_IMAGE_DEFAULT_NAME;
extern NSString * const POST_AUTHOR_KEY;
extern NSString * const POST_CREATED_AT_KEY;
extern NSString * const POST_PRIVATE_KEY;
extern NSString * const POST_LOCATION_KEY;
extern NSString * const POST_NUM_LIKES_KEY;
extern NSString * const DEFAULT_POST_PREVIEW_IMAGE_NAME;

// Location Properties
extern NSString * const LOCATION_PARSE_CLASS_NAME;
extern NSString * const LOCATION_PLACE_ID_KEY;
extern NSString * const LOCATION_OBJECT_ID_KEY;
extern NSString * const LOCATION_COORDINATE_KEY;
extern NSString * const LOCATION_NUM_POSTS_KEY;
extern NSString * const LOCATION_USERS_WITH_POSTS_KEY;

// Comment Properties
extern NSString * const COMMENT_PARSE_CLASS_NAME;
extern NSString * const COMMENT_POST_ID_KEY;

// User Properties
extern NSString * const USER_PARSE_CLASS_NAME;
extern NSString * const USER_USERNAME_KEY;
extern NSString * const USER_TAGLINE_KEY;
extern NSString * const USER_PROFILE_PICTURE_KEY;
extern NSString * const USER_NUM_FRIENDS_KEY;
extern NSString * const USER_PENDING_FRIENDS_KEY;
extern NSString * const USER_FRIENDS_KEY;
extern NSString * const USER_REQUESTS_SENT_KEY;
extern NSString * const USER_OBJECT_ID_KEY;
extern NSString * const USER_NUM_POSTS_KEY;
extern NSString * const USER_LIKED_POSTS_KEY;

// Cloud Code Requests
extern NSString * const CLOUD_CODE_USER_TO_EDIT_KEY;
extern NSString * const CLOUD_CODE_CURRENT_USER_KEY;
extern NSString * const CLOUD_CODE_FRIEND_KEY;
extern NSString * const CLOUD_CODE_FRIEND_USER_FUNCTION;
extern NSString * const CLOUD_CODE_FRIEND_REQUEST_RESPONSE_FUNCTION;
extern NSString * const CLOUD_CODE_SEND_FRIEND_REQUEST_FUNCTION;

// Label UI Properties
extern NSString * const FRIEND_LABEL_SINGULAR;
extern NSString * const FRIEND_LABEL_PLURAL;
extern NSString * const POST_LABEL_SINGULAR;
extern NSString * const POST_LABEL_PLURAL;
extern NSString * const LIKE_LABEL_SINGULAR;
extern NSString * const LIKE_LABEL_PLURAL;

// MapView Properties
extern CGFloat const MAP_FEED_DEFAULT_ZOOM;
extern CGFloat const LOCATION_VIEW_DEFAULT_ZOOM;

// Segues
extern NSString * const PROFILE_TO_LOCATION_SEGUE;
extern NSString * const CHOOSE_PROFILE_PHOTO_SEGUE;
extern NSString * const PROFILE_TO_FRIEND_REQUESTS_SEGUE;
extern NSString * const CAMERA_SEGUE;
extern NSString * const IMAGE_PICKER_SEGUE;
extern NSString * const AFTER_POST_SEGUE;
extern NSString * const PROFILE_FROM_REQUESTS_SEGUE;
extern NSString * const DETAIL_SEGUE;
extern NSString * const HEADER_TO_PROFILE_SEGUE;
extern NSString * const LOGGED_IN_SEGUE;
extern NSString * const HOME_TO_LOCATION_SEGUE;

// Profile Tab Constants
extern NSString * const MOST_RECENT_POST_PREDICATE;
extern NSString * const GROUP_POSTS_KEY_PATH;
extern NSString * const POSTS_AT_LOCATION_PREDICATE;
extern NSInteger const PROFILE_TAB_INDEX;

// Storyboard Identifiers
extern NSString * const AUTOCOMPLETE_CELL_IDENTIFIER;
extern NSString * const PHOTO_CELL_IDENTIFIER;
extern NSString * const POST_CELL_IDENTIFIER;
extern NSString * const COMMENT_CELL_IDENTIFIER;
extern NSString * const SEARCH_CELL_IDENTIFIER;
extern NSString * const LOGIN_VIEW_CONTROLLER_IDENTIFIER;
extern NSString * const IMAGE_PICKER_CELL_IDENTIFIER;
extern NSString * const TAB_BAR_CONTROLLER_IDENTIFIER;
extern NSString * const FRIEND_REQUEST_CELL_IDENTIFIER;
extern NSString * const STORYBOARD_NAME;

// ImagePicker Selection Limits
extern NSInteger const MAX_NUM_POST_PHOTO_SELECTION;
extern NSInteger const MAX_NUM_PROFILE_PHOTO_SELECTION;

// Date Handling
extern NSString * const DATE_FORMAT;

// User Search Constants
extern NSInteger const INITIAL_USER_QUERY_LIMIT;
extern NSString * const SEARCH_BAR_REGEX_MODIFIERS;

// ImagePicker Constants
extern NSString * const PHOTO_CREATION_DATE_KEY;
extern CGFloat const CAPTURE_PHOTO_ANIMATION_DURATION;
extern CGFloat const FULL_IMAGE_WIDTH;
extern CGFloat const FULL_IMAGE_HEIGHT;
extern CGFloat const IMAGE_THUMBNAIL_WIDTH;
extern CGFloat const IMAGE_THUMBNAIL_HEIGHT;

// Format Strings
extern NSString * const LOCATION_STRING;
extern NSString * const OBJECT_STRING;

// Core Data
extern NSString * const CACHED_USER_CLASS_NAME;
extern NSString * const CACHED_LOCATION_CLASS_NAME;
extern NSString * const CACHED_POST_CLASS_NAME;
extern NSString * const CACHED_COMMENT_CLASS_NAME;
extern NSString * const CACHED_PHOTO_CLASS_NAME;
extern NSString * const CACHED_OBJECT_ID_FILTER_PREDICATE;
extern NSString * const CACHED_PLACE_ID_FILTER_PREDICATE;
extern NSString * const CACHED_POST_CREATED_AT_KEY;
extern NSString * const CACHED_LOCATION_FILTER_PREDICATE;
extern NSString * const CACHED_POST_ID_FILTER_PREDICATE;

// Misc. Constants
extern NSString * const EMPTY_STRING;
extern CGFloat const KEYBOARD_DISTANCE_FROM_TEXT_FIELD;


@interface ProjectColors : NSObject
+ (CGColorRef)tintColor;
+ (UIColor *)tanBackgroundColor;
@end

@interface ProjectNumbers : NSObject
+ (NSNumber *)zero;
+ (NSNumber *)one;
+ (NSNumber *)negativeOne;
@end

@interface ProjectLocations : NSObject
+ (GMSCameraPosition *)defaultLocation;
@end

@interface ProjectFonts : NSObject
+ (UIFont *)searchBarFont;
+ (UIFont *)tabBarFont;
+ (UIFont *)navigationBarFont;
@end

#endif /* Constants_h */
