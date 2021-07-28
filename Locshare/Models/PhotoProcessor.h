//
//  PhotoProcessor.h
//  Locshare
//
//  Created by Felianne Teng on 7/27/21.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

NS_ASSUME_NONNULL_BEGIN

@interface PhotoProcessor : NSObject <AVCapturePhotoCaptureDelegate>

@property (strong, nonatomic) NSMutableArray *returnedPhotos;

@end

NS_ASSUME_NONNULL_END
