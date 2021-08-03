//
//  Constants.m
//  Locshare
//
//  Created by Felianne Teng on 8/2/21.
//
#import <Foundation/Foundation.h>
#import "Constants.h"

// LocationManager.m
NSString * const KEYS_FILE_NAME = @"Keys";
NSString * const KEYS_FILE_EXTENSION = @"plist";
NSString * const GOOGLE_API_KEY_NAME = @"google_api_key";
NSString * const PLACES_AUTOCOMPLETE_URL = @"https://maps.googleapis.com/maps/api/place/autocomplete/json?input=%@&key=%@";
NSString * const PLACES_AUTOCOMPLETE_RETURNED_DATA_KEY = @"predictions";
NSString * const PLACES_NEARBY_RADIUS = @"1000";
NSString * const PLACES_NEARBY_URL = @"https://maps.googleapis.com/maps/api/place/nearbysearch/json?key=%@&location=%@&radius=%@";
NSString * const PLACES_NEARBY_RETURNED_DATA_KEY = @"results";
NSString * const PLACES_DETAILS_URL = @"https://maps.googleapis.com/maps/api/place/details/json?place_id=%@&key=%@";
NSString * const PLACES_DETAILS_RETURNED_DATA_KEY = @"result";
NSString * const URL_REQUEST_ERROR_TITLE = @"Network Error";
NSString * const URL_REQUEST_ERROR_MESSAGE = @"Could not complete network request";


