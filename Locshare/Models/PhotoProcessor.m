//
//  PhotoProcessor.m
//  Locshare
//
//  Created by Felianne Teng on 7/27/21.
//

#import "PhotoProcessor.h"

@implementation PhotoProcessor

- (void)captureOutput:(AVCapturePhotoOutput *)output didFinishProcessingPhoto:(AVCapturePhoto *)photo error:(NSError *)error {
    [self.returnedPhotos addObject:photo.fileDataRepresentation];
}

@end
