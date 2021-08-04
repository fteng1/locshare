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

// LocationManager.m
extern NSString * const KEYS_FILE_NAME;
extern NSString * const KEYS_FILE_EXTENSION;
extern NSString * const GOOGLE_API_KEY_NAME;
extern NSString * const PLACES_AUTOCOMPLETE_URL;
extern NSString * const PLACES_AUTOCOMPLETE_RETURNED_DATA_KEY;
extern NSString * const PLACES_NEARBY_RADIUS;
extern NSString * const PLACES_NEARBY_URL;
extern NSString * const PLACES_NEARBY_RETURNED_DATA_KEY;
extern NSString * const PLACES_DETAILS_URL;
extern NSString * const PLACES_DETAILS_RETURNED_DATA_KEY;
extern NSString * const URL_REQUEST_ERROR_TITLE;
extern NSString * const URL_REQUEST_ERROR_MESSAGE;

// AlertManager.m
extern NSString * const OK_ACTION_TITLE;

// UserSearchCell.m
extern CGFloat const BUTTON_CORNER_RADIUS;
extern BOOL const MASKS_TO_BOUNDS;
extern CGFloat const BUTTON_BORDER_WIDTH;
extern CGFloat const PROFILE_PICTURE_CORNER_RADIUS_RATIO;

// Post.m
extern NSString * const POST_PARSE_CLASS_NAME;
extern NSNumber * const ZERO;
extern CGFloat const IMAGE_COMPRESSION_QUALITY;
extern NSString * const IMAGE_DEFAULT_NAME;
extern NSString * const POST_AUTHOR_KEY;
extern NSString * const POST_CREATED_AT_KEY;
extern NSString * const POST_PRIVATE_KEY;
extern NSString * const POST_LOCATION_KEY;
extern NSString * const POST_NUM_LIKES_KEY;

// Location.m
extern NSString * const LOCATION_PARSE_CLASS_NAME;
extern NSString * const LOCATION_PLACE_ID_KEY;
extern NSString * const LOCATION_OBJECT_ID_KEY;

// Comment.m
extern NSString * const COMMENT_PARSE_CLASS_NAME;
extern NSString * const COMMENT_POST_ID_KEY;

// User properties
extern NSString * const USER_PARSE_CLASS_NAME;
extern NSString * const USER_USERNAME_KEY;
extern NSString * const USER_TAGLINE_KEY;
extern NSString * const USER_PROFILE_PICTURE_KEY;
extern NSString * const CLOUD_CODE_USER_TO_EDIT_KEY;
extern NSString * const CLOUD_CODE_CURRENT_USER_KEY;
extern NSString * const CLOUD_CODE_FRIEND_KEY;
extern NSString * const CLOUD_CODE_FRIEND_USER_FUNCTION;
extern NSString * const CLOUD_CODE_FRIEND_REQUEST_RESPONSE_FUNCTION;
extern NSString * const CLOUD_CODE_SEND_FRIEND_REQUEST_FUNCTION;
extern NSString * const USER_NUM_FRIENDS_KEY;
extern NSString * const USER_PENDING_FRIENDS_KEY;
extern NSString * const USER_FRIENDS_KEY;
extern NSString * const USER_REQUESTS_SENT_KEY;
extern NSString * const USER_OBJECT_ID_KEY;
extern NSString * const USER_NUM_POSTS_KEY;
extern NSString * const USER_LIKED_POSTS_KEY;

// ProfileViewController.m
extern NSString * const FRIEND_BUTTON_TITLE_DEFAULT;
extern NSString * const FRIEND_BUTTON_REQUEST_SENT;
extern NSString * const FRIEND_BUTTON_RESPOND_TO_REQUEST;
extern NSString * const FRIEND_BUTTON_ALREADY_FRIENDS;
extern NSString * const UPDATE_USER_ERROR_TITLE;
extern NSString * const UPDATE_USER_ERROR_MESSAGE;
extern NSString * const FRIEND_LABEL_SINGULAR;
extern NSString * const FRIEND_LABEL_PLURAL;
extern NSString * const POST_LABEL_SINGULAR;
extern NSString * const POST_LABEL_PLURAL;
extern NSString * const DEFAULT_PROFILE_PICTURE_NAME;
extern NSString * const RETRIEVING_POSTS_ERROR_TITLE;
extern NSString * const RETRIEVING_POSTS_ERROR_MESSAGE;
extern NSString * const MOST_RECENT_POST_PREDICATE;
extern CGFloat const MAP_FEED_DEFAULT_ZOOM;
extern NSString * const GROUP_POSTS_KEY_PATH;
extern NSString * const POSTS_AT_LOCATION_PREDICATE;
extern NSString * const PROFILE_TO_LOCATION_SEGUE;
extern NSInteger const PROFILE_TAB_INDEX;
extern NSString * const SAVE_SUCCESSFUL_TITLE;
extern NSString * const SAVE_SUCCESSFUL_MESSAGE;
extern NSString * const CHOOSE_PROFILE_PHOTO_SEGUE;
extern NSString * const PROFILE_TO_FRIEND_REQUESTS_SEGUE;
extern NSInteger const MAX_NUM_PROFILE_PHOTO_SELECTION;

// PostViewController.m
extern NSString * const CAPTION_PLACEHOLDER_TEXT;
extern CGFloat const TEXT_FIELD_CORNER_RADIUS;
extern BOOL const CLIPS_TO_BOUNDS;
extern CGFloat const TABLE_VIEW_BORDER_WIDTH;
extern CGFloat const PHOTO_PREVIEW_COLLECTION_VIEW_SPACING;
extern NSString * const CAMERA_SEGUE;
extern NSString * const IMAGE_PICKER_SEGUE;
extern NSString * const POST_ERROR_TITLE;
extern NSString * const POST_ERROR_MESSAGE;
extern NSString * const LOCATION_TAG_TITLE;
extern NSString * const LOCATION_TAG_MESSAGE;
extern NSString * const AFTER_POST_SEGUE;
extern NSString * const POST_FAILED_TITLE;
extern NSString * const POST_FAILED_MESSAGE;
extern NSString * const AUTOCOMPLETE_CELL_IDENTIFIER;
extern NSString * const AUTOCOMPLETE_RESULT_DESCRIPTION_KEY;
extern NSString * const AUTOCOMPLETE_RESULT_NAME_KEY;
extern CGFloat const SEARCH_BAR_ANIMATION_DURATION;
extern CGFloat const SEARCH_BAR_CONSTRAINT_MULTIPLIER;
extern CGFloat const SEARCH_BAR_CONSTRAINT_CONSTANT;
extern CGFloat const SEARCH_BAR_CONSTRAINT_PRIORITY;
extern NSString * const AUTOCOMPLETE_RESULT_PLACE_ID_KEY;
extern NSString * const PHOTO_CELL_IDENTIFIER;
extern NSInteger const MAX_NUM_POST_PHOTO_SELECTION;

// LocationViewController.m
extern CGFloat const POST_PREVIEW_COLLECTION_VIEW_SPACING;
extern CGFloat const POST_PREVIEW_COLLECTION_VIEW_POSTS_PER_LINE;
extern CGFloat const LOCATION_VIEW_DEFAULT_ZOOM;
extern NSString * const UPDATE_LOCATION_ERROR_TITLE;
extern NSString * const UPDATE_LOCATION_ERROR_MESSAGE;
extern NSString * const RETRIEVE_POSTS_ERROR_TITLE;
extern NSString * const RETRIEVE_POSTS_ERROR_MESSAGE;
extern NSString * const POST_CELL_IDENTIFIER;
extern NSString * const DEFAULT_POST_PREVIEW_IMAGE_NAME;
extern NSString * const DETAIL_SEGUE;

// DetailsViewController.m
extern NSString * const LIKE_BUTTON_IMAGE_NORMAL;
extern NSString * const LIKE_BUTTON_IMAGE_SELECTED;
extern NSString * const DATE_FORMAT;
extern NSString * const LIKE_LABEL_SINGULAR;
extern NSString * const LIKE_LABEL_PLURAL;
extern NSString * const FETCH_COMMENT_ERROR_TITLE;
extern NSString * const FETCH_COMMENT_ERROR_MESSAGE;
extern NSString * const EMPTY_STRING;
extern NSString * const PROFILE_ERROR_TITLE;
extern NSString * const PROFILE_ERROR_MESSAGE;
extern NSString * const HEADER_TO_PROFILE_SEGUE;
extern NSString * const COMMENT_CELL_IDENTIFIER;

// SearchViewController.m
extern NSInteger const INITIAL_USER_QUERY_LIMIT;
extern NSString * const SEARCH_ERROR_INITIAL_USERS_TITLE;
extern NSString * const SEARCH_ERROR_INITIAL_USERS_MESSAGE;
extern NSString * const SEARCH_BAR_REGEX_MODIFIERS;
extern NSString * const PERFORM_SEARCH_ERROR_TITLE;
extern NSString * const PERFORM_SEARCH_ERROR_MESSAGE;
extern NSString * const SEARCH_CELL_IDENTIFIER;

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
@end

#endif /* Constants_h */
